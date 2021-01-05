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
                     creator)           creator_yaml ;;
                   dashboard)         dashboard_yaml ;;
                      differ)            differ_yaml ;;
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
    env_file: [ .env ]
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
    env_file: [ .env ]
    init: true
    read_only: true
    restart: "no"
    tmpfs:
      - /cyber-dojo:uid=19663,gid=65533
      - /tmp:uid=19663,gid=65533
END
}

#- - - - - - - - - - - - - - - - - - - - - -
runner_yaml()
{
  cat <<- END
  runner:
    image: \${CYBER_DOJO_RUNNER_IMAGE}:\${CYBER_DOJO_RUNNER_TAG}
    user: root
    env_file: [ .env ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
END
}

#- - - - - - - - - - - - - - - - - - - - - -
differ_yaml()
{
  cat <<- END
  differ:
    depends_on:
      - model
    image: \${CYBER_DOJO_DIFFER_IMAGE}:\${CYBER_DOJO_DIFFER_TAG}
    user: nobody
    env_file: [ .env ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
END
}

#- - - - - - - - - - - - - - - - - - - - - -
dashboard_yaml()
{
  cat <<- END
  dashboard:
    depends_on:
      - model
    image: \${CYBER_DOJO_DASHBOARD_IMAGE}:\${CYBER_DOJO_DASHBOARD_TAG}
    user: nobody
    env_file: [ .env ]
    read_only: true
    restart: "no"
    tmpfs: /tmp
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
    env_file: [ .env ]
    image: \${CYBER_DOJO_CREATOR_IMAGE}:\${CYBER_DOJO_CREATOR_TAG}
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
    env_file: [ .env ]
    image: \${CYBER_DOJO_MODEL_IMAGE}:\${CYBER_DOJO_MODEL_TAG}
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
