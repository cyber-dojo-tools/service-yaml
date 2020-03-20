#!/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${0}")" && pwd)"

docker build --tag cyberdojo/service-yaml "${MY_DIR}"
