
- The source for the [cyberdojo/service-yaml](https://hub.docker.com/r/cyberdojo/service-yaml/tags) Docker image.
- Prints yaml for specified cyber-dojo services ready to be consumed by `docker-compose --file -`.
- Tees `stdin` to `stdout` allowing the 'base' docker-compose.yml to become part of `stdout`.
  - This is because `docker-compose` [cannot](https://github.com/docker/compose/issues/6124)
    *combine* named (`-f|--file`) yml files with yml from `stdin`.
  - Instead, you must pipe the 'base' docker-compose.yml file into stdin
    (see the `cat` in the example below).
- Adds a `test/` dir volume-mount for the *first* service name (`custom-chooser` in the example below).
  - This is for the same reason. Viz, because `docker-compose` cannot combine named
    (`-f|--file`) yml files with yml from `stdin` for an *individual* service.

Example:

```bash
$ cat docker-compose.yml \
   | docker run --rm --interactive cyberdojo/service-yaml \
               custom-chooser \
          custom-start-points \
       exercises-start-points \
       languages-start-points \
                      creator \
                     selenium \
   | tee /tmp/augmented-docker-compose.peek.yml \
   | docker-compose \
       --file -     \
       up            \
       --detach
```

Here's the 'base' docker-compose.yml
```bash
$ cat docker-compose.yml

version: '3.7'

services:
  client:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_CREATOR_CLIENT_PORT ]
      context: src/client
    depends_on:
      - custom-chooser
      - selenium
    image: cyberdojo/creator-client
    ...
```

Here's the generated yml
```bash
$ cat /tmp/augmented-docker-compose.peek.yml

version: '3.7'

services:

  client:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_CREATOR_CLIENT_PORT ]
      context: src/client
    depends_on:
      - custom-chooser
      - selenium
    image: cyberdojo/creator-client
    ...

  custom-chooser:
      build:
        args: [ COMMIT_SHA, CYBER_DOJO_CUSTOM_CHOOSER_PORT ]
        context: src/server
      depends_on:
        - custom-start-points
        - creator
      environment: [ NO_PROMETHEUS ]
      image: ${CYBER_DOJO_CUSTOM_CHOOSER_IMAGE}
      init: true
      ports: [ "${CYBER_DOJO_CUSTOM_CHOOSER_PORT}:${CYBER_DOJO_CUSTOM_CHOOSER_PORT}" ]
      read_only: true
      restart: "no"
      tmpfs: /tmp
      user: nobody
      volumes: [ "./test:/test/:ro" ]

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

  saver:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}
    init: true
    ports: [ "${CYBER_DOJO_SAVER_PORT}:${CYBER_DOJO_SAVER_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs:
      - /cyber-dojo:uid=19663,gid=65533
      - /tmp:uid=19663,gid=65533
    user: saver

  selenium:
    image: selenium/standalone-firefox
    ports: [ "4444:4444" ]    
```
