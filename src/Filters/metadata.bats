#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/metadata.sh
source "${BATS_TEST_DIRNAME}/metadata.sh"

function Filters::metadata::keepOnlyMetadata { #@test
  run Filters::metadata "${FILTER_META_DATA_KEEP_ONLY_HEADERS}" "${BATS_TEST_DIRNAME}/testsData/metadata.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/metadata.invert0.expected.txt")"
}

function Filters::metadata::removeOnlyMetadata { #@test
  run Filters::metadata "${FILTER_META_DATA_REMOVE_HEADERS}" "${BATS_TEST_DIRNAME}/testsData/metadata.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/metadata.invert1.expected.sh")"
}

function Filters::metadata::defaultInvertValue { #@test
  {
    run Filters::metadata
    assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/metadata.invert0.expected.txt")"
  } <"${BATS_TEST_DIRNAME}/testsData/metadata.sh"
}

function Filters::metadata::noMetadata { #@test
  run Filters::metadata "${FILTER_META_DATA_REMOVE_HEADERS}" "${BATS_TEST_DIRNAME}/testsData/noMetadata.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/noMetadata.sh")"
}
