#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Docker/testContainer.sh
source "${BATS_TEST_DIRNAME}/testContainer.sh"
# shellcheck source=/src/Log/displayInfo.sh
source "${srcDir}/Log/displayInfo.sh"
# shellcheck source=/src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=/src/Log/displaySuccess.sh
source "${srcDir}/Log/displaySuccess.sh"
# shellcheck source=/src/Log/logInfo.sh
source "${srcDir}/Log/logInfo.sh"
# shellcheck source=/src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=/src/Log/logSuccess.sh
source "${srcDir}/Log/logSuccess.sh"
# shellcheck source=/src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"
# shellcheck source=/src/Retry/parameterized.sh
source "${srcDir}/Retry/parameterized.sh"
# shellcheck source=/src/Assert/dirExists.sh
source "${srcDir}/Assert/dirExists.sh"

teardown() {
  unstub_all
}

function Docker::testContainerDirNotExists { #@test
  callbackSuccess() {
    echo "callback success"
  }

  run Docker::testContainer "invalid" "containerName" "title" callbackSuccess
  assert_failure 1
  assert_output "ERROR   - Directory invalid does not exist"
}

function Docker::testContainerCallbackInvalid { #@test
  run Docker::testContainer "." "containerName" "title" "invalidCallback"
  assert_failure 4
  assert_output "ERROR   - testCallBack parameter should be a function"
}

function Docker::testContainerDockerComposeUpFailure { #@test
  stub docker-compose \
    "up -d : echo 'docker-compose up' && exit 1" \
    "down : exit 1"

  callbackSuccess() {
    echo "callback success"
  }
  run Docker::testContainer "." "containerName" "title" callbackSuccess
  assert_failure 3
  assert_line --index 0 "INFO    - Launching title ..."
  assert_line --index 1 "docker-compose up"
  assert_line --index 2 "INFO    - Shuting down title ..."
}

function Docker::testContainerWithCallbackOK { #@test
  stub docker-compose \
    "up -d : echo 'docker-compose is up'" \
    "down : echo 'docker-compose down'"

  callbackSuccess() {
    echo "callback success"
  }
  run Docker::testContainer "." "containerName" "title" callbackSuccess
  assert_success
  assert_line --index 0 "INFO    - Launching title ..."
  assert_line --index 1 "docker-compose is up"
  assert_line --index 2 "callback success"
  assert_line --index 3 "SUCCESS - title tested successfully"
  assert_line --index 4 "INFO    - Shuting down title ..."
}

function Docker::testContainerWithCallbackError { #@test
  stub docker-compose \
    "up -d : echo 'docker-compose is up'" \
    "logs containerName : echo 'docker-compose logs of containerName'" \
    "down : echo 'docker-compose down'"

  callbackFailure() {
    echo "callback failure"
    return 1
  }
  run Docker::testContainer "." "containerName" "title" callbackFailure
  assert_failure 2
  assert_line --index 0 "INFO    - Launching title ..."
  assert_line --index 1 "docker-compose is up"
  assert_line --index 2 "callback failure"
  assert_line --index 3 "docker-compose logs of containerName"
  assert_line --index 4 "ERROR   - title initialization has failed, check above logs"
  assert_line --index 5 "INFO    - Shuting down title ..."
}
