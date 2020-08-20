
- The source for the [cyberdojo/service-yaml](https://hub.docker.com/r/cyberdojo/service-yaml/tags) Docker image.
- Prints yaml for specified cyber-dojo services to `stdout`.
- Tees `stdin` to `stdout` allowing catted yml files to be blended into `stdout`.
- The `stdout` then becomes piped `stdin` and is consumed by `docker-compose --file -`
  (rather than from a *named* yml file).
- This design is because `docker-compose` [cannot combine](https://github.com/docker/compose/issues/6124)
    *named* yml files with yml from `stdin`.
  - So, instead, you must cat the yml files and pipe `stdin`
    into the `docker run ... cyberdojo/service-yaml` command
    (see the `cat` in the example below).
- Adds a `./test` dir volume-mount for the *first* named service (`custom-start-points` in the example below).
  - This is for the same reason. Viz, because `docker-compose` cannot combine named
    yml files with yml from `stdin` for an *individual* service.
- Note that a `docker-compose` command receiving its yaml from `stdin` cannot base
  relative paths (in volume-mounts) from the directory of the yml file (since there isn't one).
  Instead it uses the current working directory. Caveat emptor.

Example:

```bash
$ cat docker-compose.yml \
   | docker run --rm --interactive cyberdojo/service-yaml \
          custom-start-points \
       exercises-start-points \
       languages-start-points \
                      creator \
                     selenium \
   | tee /tmp/augmented-docker-compose.peek.yml \
   | docker-compose \
       --file -     \
       up           \
       --detach
```

Here's docker-compose.yml
```bash
$ cat docker-compose.yml

version: '3.7'

services:
  client:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_CREATOR_CLIENT_PORT ]
      context: src/client
    depends_on:
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
      - selenium
    image: cyberdojo/creator-client
    ...

  custom-start-points:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_CUSTOM_START_POINTS_IMAGE}:${CYBER_DOJO_CUSTOM_START_POINTS_TAG}
    ports: [ "${CYBER_DOJO_CUSTOM_START_POINTS_PORT}:${CYBER_DOJO_CUSTOM_START_POINTS_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody

  exercises-start-points:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}:${CYBER_DOJO_EXERCISES_START_POINTS_TAG}
    ports: [ "${CYBER_DOJO_EXERCISES_START_POINTS_PORT}:${CYBER_DOJO_EXERCISES_START_POINTS_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody


  languages-start-points:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_LANGUAGES_START_POINTS_IMAGE}:${CYBER_DOJO_LANGUAGES_START_POINTS_TAG}
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
    ports: [ "${CYBER_DOJO_CREATOR_PORT}:${CYBER_DOJO_CREATOR_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody

  saver:
    environment: [ NO_PROMETHEUS ]
    image: ${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}
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
