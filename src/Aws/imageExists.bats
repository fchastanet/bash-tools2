#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Aws/imageExists.sh
source "${BATS_TEST_DIRNAME}/imageExists.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"
# shellcheck source=/src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=/src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=/src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"

teardown() {
  unstub_all
}

function Docker::imageExistsWithoutTags { #@test
  run Aws::imageExists "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" 2>&1
  assert_failure
  assert_output "ERROR   - At least one tag should be provided"
}

function Docker::imageExistsWith1Tag { #@test
  stub aws \
    'ecr describe-images --repository-name="id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" --image-ids=imageTag="tag1" : true'
  run Aws::imageExists "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1"
  assert_success
}

function Docker::imageExistsWith2Tags { #@test
  stub aws \
    'ecr describe-images --repository-name="id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" --image-ids=imageTag="tag1" : true' \
    'ecr describe-images --repository-name="id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" --image-ids=imageTag="tag2" : true'
  run Aws::imageExists \
    "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1" "tag2"
  assert_success
}

function Docker::imageDoesNotExistWith1Tag { #@test
  stub aws \
    'ecr describe-images --repository-name="id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" --image-ids=imageTag="tag1" : exit 1'
  run Aws::imageExists "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1"
  assert_failure
  assert_output "ERROR   - image with tag id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag1 does not exists"
}

function Docker::imageDoesNotExistWith2Tags { #@test
  stub aws \
    'ecr describe-images --repository-name="id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" --image-ids=imageTag="tag1" : true' \
    'ecr describe-images --repository-name="id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" --image-ids=imageTag="tag2" : exit 1'
  run Aws::imageExists \
    "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools" "tag1" "tag2"
  assert_failure
  assert_output "ERROR   - image with tag id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:tag2 does not exists"
}
