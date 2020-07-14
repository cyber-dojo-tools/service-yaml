#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$(dirname "${0}")" && pwd )"

cat "${MY_DIR}/docker-compose.yml" \
  | docker run --rm --interactive cyberdojo/service-yaml \
       custom-start-points \
    exercises-start-points \
    languages-start-points \
                   creator \
                   runner
