#!/usr/bin/env bash

set -x
CURRENT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)
BATS_TEST_TMPDIR=/tmp/bats
mkdir -p /tmp/bats

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}
BIN_DIR="${CURRENT_DIR}"
srcDir="$(cd "${CURRENT_DIR}/../src" && pwd -P)"
BATS_TEST_DIRNAME="${srcDir}/Embed"
FRAMEWORK_ROOT_DIR="$(cd "${srcDir}/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR

# PERSISTENT_TMPDIR is not deleted by traps
PERSISTENT_TMPDIR="${TMPDIR:-/tmp}/bash-framework"
export PERSISTENT_TMPDIR
mkdir -p "${PERSISTENT_TMPDIR}"

# shellcheck disable=SC2034
TMPDIR="$(mktemp -d -p "${PERSISTENT_TMPDIR:-/tmp}" -t bash-framework-$$-XXXXXX)"
export TMPDIR

# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"
# shellcheck source=src/Embed/embedFrameworkFunction.sh
source "${srcDir}/Embed/embedFrameworkFunction.sh"
# shellcheck source=src/Embed/extractFileFromBase64.sh
source "${srcDir}/Embed/extractFileFromBase64.sh"
# shellcheck source=src/_includes/_commonHeader.sh
source "${srcDir}/_includes/_commonHeader.sh"
# shellcheck source=src/_includes/_colors.sh
source "${srcDir}/_includes/_colors.sh"
# shellcheck source=src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

Env::pathPrepend "${BIN_DIR}"

declare -agx _COMPILE_FILE_ARGUMENTS=(
  # srcFile     : file that needs to be compiled
  "" # any value will be replaced by the generated file
  # templateDir : directory from which bash-tpl templates will be searched
  --template-dir "${srcDir}/_includes"
  # binDir      : fallback bin directory in case BIN_FILE has not been provided
  --bin-dir "${BATS_TEST_TMPDIR}"
  # rootDir     : directory used to compute src file relative path
  --root-dir "${FRAMEWORK_ROOT_DIR}"
  # srcDirs : (optional) you can provide multiple directories
  --src-dir "${srcDir}"
)
# shellcheck disable=SC2031
export KEEP_TEMP_FILES=1

Embed::embedFrameworkFunction \
  "Filters::bashFrameworkFunctions" \
  "bashFrameworkFunctions" \
  >"${BATS_TEST_TMPDIR}/functionEmbedded"

# shellcheck source=/dev/null
source "${BATS_TEST_TMPDIR}/functionEmbedded"

bashFrameworkFunctions \
  "${srcDir}/Embed/testsData/embedFrameworkFunction.txt" \
  >"${BATS_TEST_TMPDIR}/embedFrameworkFunction.result.txt"

diff \
  "${BATS_TEST_TMPDIR}/embedFrameworkFunction.result.txt" \
  "${BATS_TEST_DIRNAME}/testsData/embedFrameworkFunction.expected.txt"
