#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$(dirname "${0}")" && pwd )"

cat "${MY_DIR}/docker-compose.yml" \
  | "${MY_DIR}/main.sh" \
       custom-start-points \
    exercises-start-points \
    languages-start-points    
