#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM <% $REPOSITORY_URL %>/tree/master/<% $SRC_FILE_PATH %>
# DO NOT EDIT IT
#####################################

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}
REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2034
CURRENT_DIR="$(cd "$(readlink -e "${REAL_SCRIPT_FILE%/*}")" && pwd -P)"
BIN_DIR="${CURRENT_DIR}"
# PERSISTENT_TMPDIR is not deleted by traps
PERSISTENT_TMPDIR="${TMPDIR:-/tmp}/bash-framework"
export PERSISTENT_TMPDIR
mkdir -p "${PERSISTENT_TMPDIR}"

# shellcheck disable=SC2034
TMPDIR="$(mktemp -d -p "${PERSISTENT_TMPDIR:-/tmp}" -t bash-framework-$$-XXXXXX)"
export TMPDIR

# FUNCTIONS

Env::pathPrepend "${BIN_DIR}"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_commonHeader.sh"

# prepare bin directory for eventual bin files generated by Embed::includeFile
mkdir -p "${TMPDIR:-/tmp}/bin"
Env::pathPrepend "${TMPDIR:-/tmp}/bin"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_colors.sh"
