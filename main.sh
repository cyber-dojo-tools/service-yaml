#!/bin/bash -Eeu

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
  echo
  echo "  ${name}:"
  echo '    environment: [ NO_PROMETHEUS ]'
  echo "    image: \${CYBER_DOJO_${upname}_IMAGE}:\${CYBER_DOJO_${upname}_TAG}"
  echo '    init: true'
  echo "    ports: [ \"\${CYBER_DOJO_${upname}_PORT}:\${CYBER_DOJO_${upname}_PORT}\" ]"
  echo '    read_only: true'
  echo '    restart: "no"'
  echo '    tmpfs: /tmp'
  echo '    user: nobody'
  echo
}

#- - - - - - - - - - - - - - - - - - - - - -
saver_yaml()
{
  echo
  echo '  saver:'
  echo '    environment: [ NO_PROMETHEUS ]'
  echo '    image: ${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}'
  echo '    init: true'
  echo '    ports: [ "${CYBER_DOJO_SAVER_PORT}:${CYBER_DOJO_SAVER_PORT}" ]'
  echo '    read_only: true'
  echo '    restart: "no"'
  echo '    tmpfs:'
  echo '      - /cyber-dojo:uid=19663,gid=65533'
  echo '      - /tmp:uid=19663,gid=65533'
  echo '    user: saver'
}

#- - - - - - - - - - - - - - - - - - - - - -
creator_yaml()
{
  echo
  echo '  creator:'
  echo '    depends_on:'
  echo '      - custom-start-points'
  echo '      - exercises-start-points'
  echo '      - languages-start-points'
  echo '      - saver'
  echo '    environment: [ NO_PROMETHEUS ]'
  echo '    image: ${CYBER_DOJO_CREATOR_IMAGE}:${CYBER_DOJO_CREATOR_TAG}'
  echo '    init: true'
  echo '    ports: [ "${CYBER_DOJO_CREATOR_PORT}:${CYBER_DOJO_CREATOR_PORT}" ]'
  echo '    read_only: true'
  echo '    restart: "no"'
  echo '    tmpfs: /tmp'
  echo '    user: nobody'
}

#- - - - - - - - - - - - - - - - - - - - - -
custom_chooser_yaml()
{
  echo
  echo '  custom-chooser:'
  echo '    build:'
  echo '      args: [ COMMIT_SHA, CYBER_DOJO_CUSTOM_CHOOSER_PORT ]'
  echo '      context: src/server'
  echo '    depends_on:'
  echo '      - custom-start-points'
  echo '      - creator'
  echo '    environment: [ NO_PROMETHEUS ]'
  echo '    image: ${CYBER_DOJO_CUSTOM_CHOOSER_IMAGE}'
  echo '    init: true'
  echo '    ports: [ "${CYBER_DOJO_CUSTOM_CHOOSER_PORT}:${CYBER_DOJO_CUSTOM_CHOOSER_PORT}" ]'
  echo '    read_only: true'
  echo '    restart: "no"'
  echo '    tmpfs: /tmp'
  echo '    user: nobody'
}

#- - - - - - - - - - - - - - - - - - - - - -
add_test_volume_on_first_service()
{
  local -r first_service="${1}"
  local -r service_name="${2}"
  if [ "${service_name}" == "${first_service}" ]; then
    echo '    volumes: [ "./test:/test/:ro" ]'
  fi
}

#- - - - - - - - - - - - - - - - - - - - - -
for service in "$@"; do
  case "${service}" in
            custom-chooser) custom_chooser_yaml              ;;
       custom-start-points)    start_point_yaml "${service}" ;;
    exercises-start-points)    start_point_yaml "${service}" ;;
    languages-start-points)    start_point_yaml "${service}" ;;
                   creator)        creator_yaml              ;;
                     saver)          saver_yaml              ;;
  esac
  add_test_volume_on_first_service "${1}" "${service}"
done
