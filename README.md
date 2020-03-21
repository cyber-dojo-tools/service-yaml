
- The source for the [cyberdojo/service-yaml](https://hub.docker.com/r/cyberdojo/service-yaml/tags) Docker image.
- Prints yaml for specified cyber-dojo services ready to be consumed by `docker-compose --file -`.
- Also tees `stdin` to `stdout` allowing the 'base' docker-compose.yml to become part of `stdout`.
- This is because `docker-compose` [cannot](https://github.com/docker/compose/issues/6124) *combine* named (`-f|--file`) yml files with yml from from `stdin`.

For example:

```bash
$ cat docker-compose.yml \
   | docker run --rm --interactive cyberdojo/service-yaml \
          custom-start-points \
       exercises-start-points \
       languages-start-points \
                      creator \
   | tee /tmp/peek.yml \
   | docker-compose --file - up --detach
```

```bash
$ cat docker-compose.yml

version: '3.7'

services:
  creator-client:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_CREATOR_CLIENT_PORT ]
      context: src/client
    container_name: test-creator-client
    depends_on:
      - custom-start-points
      - exercises-start-points
      - languages-start-points
      - creator
    image: cyberdojo/creator-client
    ...
```

```bash
$ cat /tmp/peek.yml

version: '3.7'

services:

  creator-client:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_CREATOR_CLIENT_PORT ]
      context: src/client
    container_name: test-creator-client
    depends_on:
      - custom-start-points
      - exercises-start-points
      - languages-start-points
      - creator
    image: cyberdojo/creator-client
    ...

  custom-start-points:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_CUSTOM_START_POINTS_IMAGE}:${CYBER_DOJO_CUSTOM_START_POINTS_TAG}
    init: true
    ports: [ "${CYBER_DOJO_CUSTOM_START_POINTS_PORT}:${CYBER_DOJO_CUSTOM_START_POINTS_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody


  exercises-start-points:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}
    init: true
    ports: [ "${CYBER_DOJO_EXERCISES_START_POINTS_PORT}:${CYBER_DOJO_EXERCISES_START_POINTS_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody


  languages-start-points:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_LANGUAGES_START_POINTS_IMAGE}:${CYBER_DOJO_LANGUAGES_START_POINTS_TAG}
    init: true
    ports: [ "${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}:${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody


  creator:
    depends_on:
      - custom-start-points
      - exercises-start-points
      - languages-start-points
      - saver
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_CREATOR_IMAGE}:${CYBER_DOJO_CREATOR_TAG}
    init: true
    ports: [ "${CYBER_DOJO_CREATOR_PORT}:${CYBER_DOJO_CREATOR_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
```
