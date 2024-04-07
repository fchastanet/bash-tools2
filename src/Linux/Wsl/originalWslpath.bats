#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Wsl/originalWslpath.sh
source "${srcDir}/Linux/Wsl/originalWslpath.sh"

teardown() {
  unstub_all
}

function Linux::Wsl::originalWslpath::noArg { #@test
  stub wslpath 'dd : exit 1'
  run Linux::Wsl::originalWslpath dd
  assert_failure 1
  assert_output ""
}

function Linux::Wsl::originalWslpath::path { #@test
  stub wslpath '/path : echo "/path"'
  run Linux::Wsl::originalWslpath /path
  assert_success
  assert_output "/path"
}
