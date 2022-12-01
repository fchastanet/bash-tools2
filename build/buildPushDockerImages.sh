#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/build/buildPushDockerImages.sh
# DO NOT EDIT IT
#####################################

ROOT_DIR="/home/wsl/projects/bash-tools2"
# shellcheck disable=SC2034
LIB_DIR="${ROOT_DIR}/lib"
# shellcheck disable=SC2034

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases
set -o pipefail
set -o errexit
# a log is generated when a command fails
set -o errtrace
# use nullglob so that (file*.php) will return an empty array if no file matches the wildcard
shopt -s nullglob
export TERM=xterm-256color

#avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# FUNCTIONS

# Display message using error color (red)
# @param {String} $1 message
Log::displayError() {
  echo -e "${__ERROR_COLOR}ERROR   - ${1}\e[0m"
}

# check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
export readonly __ERROR_COLOR='\e[31m'   # Red
export readonly __INFO_COLOR='\e[44m'    # white on lightBlue
export readonly __SUCCESS_COLOR='\e[32m' # Green
export readonly __WARNING_COLOR='\e[33m' # Yellow
export readonly __SKIPPED_COLOR='\e[93m' # Light Yellow
# shellcheck disable=SC2034
export readonly __TEST_COLOR='\e[100m' # Light magenta
# shellcheck disable=SC2034
export readonly __TEST_ERROR_COLOR='\e[41m' # white on red
# shellcheck disable=SC2034
export readonly __SKIPPED_COLOR='\e[33m' # Yellow
export readonly __DEBUG_COLOR='\e[37m'   # Grey
# Internal: reset color
export readonly __RESET_COLOR='\e[0m' # Reset Color
# shellcheck disable=SC2155,SC2034
export readonly __HELP_TITLE="$(echo -e "\e[1;37m")"
# shellcheck disable=SC2155,SC2034
export readonly __HELP_NORMAL="$(echo -e "\033[0m")"

# Display message using error color (red) and exit immediately with error status 1
# @param {String} $1 message
Log::fatal() {
  Log::displayError "$1"
  exit 1
}

VENDOR="$1"
BASH_TAR_VERSION="$2"
BASH_BASE_IMAGE="$3"
PULL_IMAGE="${4:-true}"
PUSH_IMAGE="${5:-}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

if [[ -z "${VENDOR}" || -z "${BASH_TAR_VERSION}" || -z "${BASH_BASE_IMAGE}" ]]; then
  Log::fatal "please provide these parameters VENDOR, BASH_TAR_VERSION, BASH_BASE_IMAGE"
fi

cd "${ROOT_DIR}" || exit 1

# pull image if needed
if [[ "${PULL_IMAGE}" == "true" ]]; then
  docker pull "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" || true
fi

# build image and push it ot registry
# shellcheck disable=SC2086
DOCKER_BUILDKIT=1 docker build \
  ${DOCKER_BUILD_OPTIONS} \
  -f ".docker/Dockerfile.${VENDOR}" \
  --cache-from "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg BASH_TAR_VERSION="${BASH_TAR_VERSION}" \
  --build-arg BASH_IMAGE="${BASH_BASE_IMAGE}" \
  -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  -t "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  ".docker"
docker run --rm "bash-tools-${VENDOR}-${BASH_TAR_VERSION}" bash --version

if [[ "${PUSH_IMAGE}" == "push" ]]; then
  docker push "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}"
fi
