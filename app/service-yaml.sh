#!/bin/bash -Eeu

readonly first_service="${1}"
readonly stdin="$(</dev/stdin)"
echo "${stdin}"

#- - - - - - - - - - - - - - - - - - - - - -
service_yaml()
{
  for service in "$@"; do
    echo
    case "${service}" in
         custom-start-points)       start_point_yaml "${service}" ;;
      exercises-start-points)       start_point_yaml "${service}" ;;
      languages-start-points)       start_point_yaml "${service}" ;;
                    avatars )           avatars_yaml ;;
                     creator)           creator_yaml ;;
                       model)             model_yaml ;;
                       saver)             saver_yaml ;;
                    selenium)          selenium_yaml ;;
                      runner)            runner_yaml ;;
    esac
    add_test_volume_on_first_service "${service}"
  done
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
start_point_yaml()
{
  local -r name="${1}"
  local -r upname=$(uppercase "${name}")
  cat <<- END
  ${name}:
    image: \${CYBER_DOJO_${upname}_IMAGE}:\${CYBER_DOJO_${upname}_TAG}
    user: nobody
    ports: [ "\${CYBER_DOJO_${upname}_PORT}:\${CYBER_DOJO_${upname}_PORT}" ]
    environment: [ NO_PROMETHEUS ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
END
}

#- - - - - - - - - - - - - - - - - - - - - -
uppercase()
{
  echo "${1}" | tr a-z A-Z | tr '-' '_'
}

#- - - - - - - - - - - - - - - - - - - - - -
saver_yaml()
{
  cat <<- END
  saver:
    image: \${CYBER_DOJO_SAVER_IMAGE}:\${CYBER_DOJO_SAVER_TAG}
    user: saver
    ports: [ "\${CYBER_DOJO_SAVER_PORT}:\${CYBER_DOJO_SAVER_PORT}" ]
    environment: [ NO_PROMETHEUS ]
    init: true
    read_only: true
    restart: "no"
    tmpfs:
      - /cyber-dojo:uid=19663,gid=65533
      - /tmp:uid=19663,gid=65533
END
}

#- - - - - - - - - - - - - - - - - - - - - -
avatars_yaml()
{
  cat <<- END
  avatars:
    image: \${CYBER_DOJO_AVATARS_IMAGE}:\${CYBER_DOJO_AVATARS_TAG}
    user: nobody
    ports: [ "\${CYBER_DOJO_AVATARS_PORT}:\${CYBER_DOJO_AVATARS_PORT}" ]
    environment: [ NO_PROMETHEUS=true ]
    read_only: true
    restart: 'no'
    tmpfs: /tmp
END
}

#- - - - - - - - - - - - - - - - - - - - - -
runner_yaml()
{
  cat <<- END
  runner:
    image: \${CYBER_DOJO_RUNNER_IMAGE}:\${CYBER_DOJO_RUNNER_TAG}
    user: root
    ports: [ "\${CYBER_DOJO_RUNNER_PORT}:\${CYBER_DOJO_RUNNER_PORT}" ]
    environment: [ NO_PROMETHEUS ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
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
      - runner
      - model
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_CREATOR_IMAGE}:\${CYBER_DOJO_CREATOR_TAG}
    ports: [ "\${CYBER_DOJO_CREATOR_PORT}:\${CYBER_DOJO_CREATOR_PORT}" ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    user: nobody
END
}

#- - - - - - - - - - - - - - - - - - - - - -
model_yaml()
{
  cat <<- END
  model:
    depends_on:
      - saver
    environment: [ NO_PROMETHEUS ]
    image: \${CYBER_DOJO_MODEL_IMAGE}:\${CYBER_DOJO_MODEL_TAG}
    ports: [ "\${CYBER_DOJO_MODEL_PORT}:\${CYBER_DOJO_MODEL_PORT}" ]
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
service_yaml "$@"
