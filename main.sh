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
for service in "$@"; do
  case "${service}" in
       custom-start-points) start_point_yaml "${service}" ;;
    exercises-start-points) start_point_yaml "${service}" ;;
    languages-start-points) start_point_yaml "${service}" ;;
  esac
done
