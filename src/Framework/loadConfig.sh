#!/usr/bin/env bash

# @arg $@ string[] the src directories in which .framework-config file will be searched
# @stdout the config file path loaded if any
# @exitcode 0 if .framework-config file has been found in srcDirs provided
Framework::loadConfig() {
  # shellcheck disable=SC2034
  local -n loadedConfigFile=$1
  shift || true
  Conf::loadNearestFile ".framework-config" loadedConfigFile "$@"
}
