#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/build/publishDeepsourceArtifact.sh
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

FILE="$1"
(
  cd "${ROOT_DIR}" || exit 1
  # Install deepsource CLI
  curl https://deepsource.io/cli | sh

  # Report coverage artifact to 'test-coverage' analyzer
  ./bin/deepsource report --analyzer shell --key shellcheck --value-file "${FILE}"
)
