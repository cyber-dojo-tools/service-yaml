#!/bin/bash -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR="$(mktemp -d /tmp/service-yaml.XXXXXXX)"
remove_tmp_dir() { rm -rf "${TMP_DIR}" > /dev/null; }
trap remove_tmp_dir INT EXIT

# - - - - - - - - - - - - - - - - - - - - - - - -
build_docker_images()
{
  docker build \
    --build-arg COMMIT_SHA="$(git_commit_sha)" \
    --tag "$(image_name)" \
    "${ROOT_DIR}/app"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r name="${1}"
  local -r expected="${2}"
  local -r actual="${3}"
  echo
  echo "expected: ${name}='${expected}'"
  echo "  actual: ${name}='${actual}'"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: unexpected ${name} inside image $(image_name):latest"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_image()
{
  local -r image="$(image_name)"
  local -r tag="$(image_tag)"
  docker tag "${image}:latest" "${image}:${tag}"
  echo
  echo "$(git_commit_sha)"
  echo "${tag}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo cyberdojo/service-yaml
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha="$(git_commit_sha)"
  echo "${sha:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --entrypoint="" --rm $(image_name):latest sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_image()
{
  echo
  if ! on_ci; then
    echo 'not on CI so not publishing tagged image'
    return
  fi
  echo 'on CI so publishing tagged image'
  local -r image="$(image_name)"
  local -r tag="$(image_tag)"
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push ${image}:latest
  docker push ${image}:${tag}
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_docker_images
assert_equal SHA "$(git_commit_sha)" "$(image_sha)"
tag_image
on_ci_publish_tagged_image
