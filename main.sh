#!/bin/bash -Eeu

readonly first_service="${1}"
readonly stdin="$(</dev/stdin)"
echo "${stdin}"

#- - - - - - - - - - - - - - - - - - - - - -
uppercase()
{
  echo "${1}" | tr a-z A-Z | tr '-' '_'
}

#- - - - - - - - - - - - - - - - - - - - - -
start_point_yaml()
{
  local -r name="${1}"
  local -r upname=$(uppercase "${name}")
  cat <<- END
  ${name}:
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_${upname}_IMAGE}:\${CYBER_DOJO_${upname}_TAG}
    init: true
    ports: [ "\${CYBER_DOJO_${upname}_PORT}:\${CYBER_DOJO_${upname}_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
END
}

#- - - - - - - - - - - - - - - - - - - - - -
saver_yaml()
{
  cat <<- END
  saver:
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_SAVER_IMAGE}:\${CYBER_DOJO_SAVER_TAG}
    init: true
    ports: [ "\${CYBER_DOJO_SAVER_PORT}:\${CYBER_DOJO_SAVER_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs:
      - /cyber-dojo:uid=19663,gid=65533
      - /tmp:uid=19663,gid=65533
    user: saver
END
}

#- - - - - - - - - - - - - - - - - - - - - -
creator_yaml()
{
  cat <<- END
  creator:
    depends_on:
      - custom-start-points
      - exercises-start-points
      - languages-start-points
      - saver
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_CREATOR_IMAGE}:\${CYBER_DOJO_CREATOR_TAG}
    init: true
    ports: [ "\${CYBER_DOJO_CREATOR_PORT}:\${CYBER_DOJO_CREATOR_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
END
}

#- - - - - - - - - - - - - - - - - - - - - -
custom_chooser_yaml()
{
  local -r tag='\${CYBER_DOJO_CUSTOM_CHOOSER_TAG}'
  cat  <<- END
  custom-chooser:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_CUSTOM_CHOOSER_PORT ]
      context: src/server
    depends_on:
      - custom-start-points
      - creator
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_CUSTOM_CHOOSER_IMAGE}:$(image_tag custom-chooser ${tag})
    init: true
    ports: [ "\${CYBER_DOJO_CUSTOM_CHOOSER_PORT}:\${CYBER_DOJO_CUSTOM_CHOOSER_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
END
}

#- - - - - - - - - - - - - - - - - - - - - -
exercises_chooser_yaml()
{
  local -r tag='\${CYBER_DOJO_EXERCISES_CHOOSER_TAG}'
  cat <<- END
  exercises-chooser:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_EXERCISES_CHOOSER_PORT ]
      context: src/server
    depends_on:
      - exercises-start-points
      - creator
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_EXERCISES_CHOOSER_IMAGE}:$(image_tag exercises-chooser ${tag})
    init: true
    ports: [ "\${CYBER_DOJO_EXERCISES_CHOOSER_PORT}:\${CYBER_DOJO_EXERCISES_CHOOSER_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
END
}

#- - - - - - - - - - - - - - - - - - - - - -
languages_chooser_yaml()
{
  local -r tag='\${CYBER_DOJO_LANGUAGES_CHOOSER_TAG}'
  cat <<- END
  languages-chooser:
    build:
      args: [ COMMIT_SHA, CYBER_DOJO_LANGUAGES_CHOOSER_PORT ]
      context: src/server
    depends_on:
      - languages-start-points
      - creator
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_LANGUAGES_CHOOSER_IMAGE}:$(image_tag languages-chooser ${tag})
    init: true
    ports: [ "\${CYBER_DOJO_LANGUAGES_CHOOSER_PORT}:\${CYBER_DOJO_LANGUAGES_CHOOSER_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
END
}

#- - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r service_name="${1}"
  local -r true_tag="${2}"
  if [ "${service_name}" == "${first_service}" ]; then
    echo latest
  else
    echo "${true_tag}"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - -
selenium_yaml()
{
  echo '  selenium:'
  echo '    image: selenium/standalone-firefox'
  echo '    ports: [ "4444:4444" ]'
}

#- - - - - - - - - - - - - - - - - - - - - -
add_test_volume_on_first_service()
{
  local -r service_name="${1}"
  if [ "${service_name}" == "${first_service}" ]; then
    echo '    volumes: [ "./test:/test/:ro" ]'
  fi
}

#- - - - - - - - - - - - - - - - - - - - - -
for service in "$@"; do
  echo
  case "${service}" in
            custom-chooser)    custom_chooser_yaml ;;
         exercises-chooser) exercises_chooser_yaml ;;
         languages-chooser) languages_chooser_yaml ;;
       custom-start-points)    start_point_yaml "${service}" ;;
    exercises-start-points)    start_point_yaml "${service}" ;;
    languages-start-points)    start_point_yaml "${service}" ;;
                   creator)        creator_yaml ;;
                     saver)          saver_yaml ;;
                  selenium)       selenium_yaml ;;
  esac
  add_test_volume_on_first_service "${service}"
done
