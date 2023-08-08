#!/usr/bin/env bash

# Display message using info color (bg light blue/fg white)
# @param {String} $1 message
Log::displayHelp() {
  local type="${2:-HELP}"
  echo -e "${__HELP_COLOR}${type}    - ${1}${__RESET_COLOR}" >&2
  Log::logHelp "$1" "${type}"
}
