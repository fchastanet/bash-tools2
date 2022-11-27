#!/usr/bin/env bash

LIB_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)
# shellcheck disable=SC2034
ROOT_DIR="$(cd "${LIB_DIR}/.." && pwd)"

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

# Display message using warning color (yellow)
# @param {String} $1 message
Log::displayWarning() {
  echo -e "${__WARNING_COLOR}WARN    - ${1}\e[0m"
}

# Display message using error color (red)
# @param {String} $1 message
Log::displayError() {
  echo -e "${__ERROR_COLOR}ERROR   - ${1}\e[0m"
}

# Retry a command several times depending on parameters
# @param {int}    $1 max retries
# @param {int}    $2 delay between attempt
# @param {String} $3 message to display to describe the attempt
# @param ...      $@ rest of parameters, the command to run
# @return 0 on success, 1 if max retries count reached
Retry::parameterized() {
  local maxRetries=$1
  local delayBetweenTries=$2
  local message="$3"
  local retriesCount=1
  shift 3
  while true; do
    Log::displayInfo "Attempt ${retriesCount}/${maxRetries}: ${message}"
    if "$@"; then
      break
    elif [[ ${retriesCount} -le ${maxRetries} ]]; then
      Log::displayWarning "Command failed. Wait for ${delayBetweenTries} seconds"
      ((retriesCount++))
      sleep "${delayBetweenTries}"
    else
      Log::displayError "The command has failed after ${retriesCount} attempts."
      return 1
    fi
  done
  return 0
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

# Display message using info color (bg light blue/fg white)
# @param {String} $1 message
Log::displayInfo() {
  echo -e "${__INFO_COLOR}INFO    - ${1}${__RESET_COLOR}"
}

# Display message using success color (bg green/fg white)
# @param {String} $1 message
Log::displaySuccess() {
  echo -e "${__SUCCESS_COLOR}SUCCESS - ${1}${__RESET_COLOR}"
}

# Display message using error color (red) and exit immediately with error status 1
# @param {String} $1 message
Log::fatal() {
  Log::displayError "$1"
  exit 1
}

# Retry a command 5 times with a delay of 15 seconds between each attempt
# @param          $@ the command to run
# @return 0 on success, 1 if max retries count reached
Retry::default() {
  Retry::parameterized 5 15 "" "$@"
}

# draw a line with the character passed in parameter repeated depending on terminal width
# @param {String} $1 character to use as separator (default value #)
UI::drawLine() {
  local character="${1:-#}"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "${character}"
}

if [[ "$(id -u)" = "0" ]]; then
  Log::fatal "this script should be executed as normal user"
  exit 1
fi

Log::displayInfo "install docker required packages"
Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
Retry::default sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2

Log::displayInfo "install docker apt source list"
source /etc/os-release

Retry::default curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list

Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true

Log::displayInfo "install docker"
Retry::default sudo apt-get install -y \
  containerd.io \
  docker-ce \
  docker-ce-cli

USERNAME="$(id -un)"
Log::displayInfo "allowing user '${USERNAME}' to use docker"
sudo getent group docker >/dev/null || sudo groupadd docker || true
sudo usermod -aG docker "${USERNAME}" || true

Log::displayInfo "Configure dockerd"
# see https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9
# see https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html
DOCKER_DIR="/var/run/docker-data"
DOCKER_SOCK="${DOCKER_DIR}/docker.sock"
DOCKER_HOST="unix://${DOCKER_SOCK}"
export DOCKER_HOST
# shellcheck disable=SC2207
WSL_DISTRO_NAME="$(
  IFS='/'
  x=($(wslpath -m /))
  echo "${x[${#x[@]} - 1]}"
)"

if [[ -z "${WSL_DISTRO_NAME}" ]]; then
  Log::fatal "impossible to deduce distribution name"
fi

if [[ ! -d "${DOCKER_DIR}" ]]; then
  sudo mkdir -pm o=,ug=rwx "${DOCKER_DIR}" || exit 1
fi
sudo chgrp docker "${DOCKER_DIR}"
if [[ ! -d "/etc/docker" ]]; then
  sudo mkdir -p /etc/docker || exit 1
fi

# shellcheck disable=SC2174
if [[ ! -f "/etc/docker/daemon.json" ]]; then
  Log::displayInfo "Creating /etc/docker/daemon.json"
  LOCAL_DNS1="$(grep nameserver </etc/resolv.conf | cut -d ' ' -f 2)"
  LOCAL_DNS2="$(ip --json --family inet addr show eth0 | jq -re '.[].addr_info[].local')"
  (
    echo "{"
    echo "  \"hosts\": [\"${DOCKER_HOST}\"],"
    echo "  \"dns\": [\"${LOCAL_DNS1}\", \"${LOCAL_DNS2}\", \"8.8.8.8\", \"8.8.4.4\"]"
    echo "}"
  ) | sudo tee /etc/docker/daemon.json
fi

dockerIsStarted() {
  DOCKER_PS="$(docker ps 2>&1 || true)"
  [[ -S "${DOCKER_SOCK}" && ! "${DOCKER_PS}" =~ "Cannot connect to the Docker daemon" ]]
}
Log::displayInfo "Checking if docker is started ..."
if dockerIsStarted; then
  Log::displaySuccess "Docker connection success"
else
  Log::displayInfo "Starting docker ..."
  sudo rm -f "${DOCKER_SOCK}" || true
  wsl.exe -d "${WSL_DISTRO_NAME}" sh -c "nohup sudo -b dockerd < /dev/null > '${DOCKER_DIR}/dockerd.log' 2>&1"
  if ! dockerIsStarted; then
    Log::fatal "Unable to start docker"
  fi
fi

Log::displayInfo "Installing docker-compose v1"
[[ -f /usr/local/bin/docker-compose ]] && cp /usr/local/bin/docker-compose /tmp/docker-compose
upgradeGithubRelease \
  "docker/compose" \
  "/tmp/docker-compose" \
  "https://github.com/docker/compose/releases/download/v@latestVersion@/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
  defaultVersion

sudo mv /tmp/docker-compose /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

Log::displayInfo "Installing docker-compose v2"
# create the docker plugins directory if it doesn't exist yet
mkdir -p "${HOME}/.docker/cli-plugins"
sudo ln -sf /usr/local/bin/docker-compose "${HOME}/.docker/cli-plugins/docker-compose"

echo
UI::drawLine "-"
Log::displayInfo "docker executable path $(command -v docker)"
Log::displayInfo "docker version $(docker --version)"
Log::displayInfo "docker-compose version $(docker-compose --version)"

echo
if [[ "${SHELL}" = "/usr/bin/bash" ]]; then
  Log::displayInfo "Please add these lines at the end of your ~/.bashrc"
elif [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
  Log::displayInfo "Please add these lines at the end of your ~/.zshrc"
else
  Log::displayInfo "Please add these lines at the end of your shell entrypoint (${SHELL})"
fi
echo
echo "export DOCKER_HOST='${DOCKER_HOST}'"
echo "if [[ ! -S '${DOCKER_SOCK}' ]]; then"
echo "   sudo mkdir -pm o=,ug=rwx '${DOCKER_DIR}'"
echo "   sudo chgrp docker '${DOCKER_DIR}'"
echo "   /mnt/c/Windows/system32/wsl.exe -d '${WSL_DISTRO_NAME}' sh -c 'nohup sudo -b dockerd < /dev/null > \"${DOCKER_DIR}/dockerd.log\" 2>&1'"
echo "fi"
