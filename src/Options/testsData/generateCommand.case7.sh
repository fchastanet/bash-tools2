#!/usr/bin/env bash

Options::command() {
  local options_parse_cmd="$1"
  shift || true

  if [[ "${options_parse_cmd}" = "parse" ]]; then
    help="0"
    local -i options_parse_optionParsedCountHelp
    ((options_parse_optionParsedCountHelp = 0)) || true
    local -i options_parse_argParsedCountSubCommand
    ((options_parse_argParsedCountSubCommand = 0)) || true
    local -i options_parse_parsedArgIndex=0
    while (($# > 0)); do
      local options_parse_arg="$1"
      local argOptDefaultBehavior=0
      case "${options_parse_arg}" in
        # Option 1/1
        # Option help --help|-h variableType Boolean min 0 max 1 authorizedValues '' regexp ''
        --help | -h)
          help="1"
          if ((options_parse_optionParsedCountHelp >= 1)); then
            Log::displayError "Command ${SCRIPT_NAME} - Option ${options_parse_arg} - Maximum number of option occurrences reached(1)"
            return 1
          fi
          ((++options_parse_optionParsedCountHelp))
          helpCallback "${options_parse_arg}"
          ;;
        -*)
          if [[ "${argOptDefaultBehavior}" = "0" ]]; then
            Log::displayError "Command ${SCRIPT_NAME} - Invalid option ${options_parse_arg}"
            return 1
          fi
          ;;
        *)
          if ((0)); then
            # Technical if - never reached
            :
          # Argument 1/1
          # Argument subCommand min 1 max 1 authorizedValues 'run|exec|ps|build|pull|push|images|login|logout|search|version|info' regexp ''
          elif ((options_parse_parsedArgIndex >= 0 && options_parse_parsedArgIndex < 1)); then
            if [[ ! "${options_parse_arg}" =~ run|exec|ps|build|pull|push|images|login|logout|search|version|info ]]; then
              Log::displayError "Command ${SCRIPT_NAME} - Argument subCommand - value '${options_parse_arg}' is not part of authorized values(run|exec|ps|build|pull|push|images|login|logout|search|version|info)"
              return 1
            fi
            if ((options_parse_argParsedCountSubCommand >= 1)); then
              Log::displayError "Command ${SCRIPT_NAME} - Argument subCommand - Maximum number of argument occurrences reached(1)"
              return 1
            fi
            ((++options_parse_argParsedCountSubCommand))
            subCommand="${options_parse_arg}"
            subCommandCallback "${subCommand}" -- "${@:2}"
          else
            if [[ "${argOptDefaultBehavior}" = "0" ]]; then
              Log::displayError "Command ${SCRIPT_NAME} - Argument - too much arguments provided: $*"
              return 1
            fi
          fi
          ((++options_parse_parsedArgIndex))
          ;;
      esac
      shift || true
    done
    export help
    if ((options_parse_argParsedCountSubCommand < 1)); then
      Log::displayError "Command ${SCRIPT_NAME} - Argument 'subCommand' should be provided at least 1 time(s)"
      return 1
    fi
    export subCommand
    Log::displayDebug "Command ${SCRIPT_NAME} - parse arguments: ${BASH_FRAMEWORK_ARGV[*]}"
    Log::displayDebug "Command ${SCRIPT_NAME} - parse filtered arguments: ${BASH_FRAMEWORK_ARGV_FILTERED[*]}"
  elif [[ "${options_parse_cmd}" = "help" ]]; then
    echo -e "$(Array::wrap " " 80 0 "${__HELP_TITLE_COLOR}DESCRIPTION:${__RESET_COLOR}" "super command")"
    echo

    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "${SCRIPT_NAME}" "[OPTIONS]" "[ARGUMENTS]")"
    echo -e "$(Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" \
      "${SCRIPT_NAME}" \
      "[--help|-h]")"
    echo
    echo -e "${__HELP_TITLE_COLOR}ARGUMENTS:${__RESET_COLOR}"
    echo -e "  ${__HELP_OPTION_COLOR}subCommand${__HELP_NORMAL} {single} (mandatory)"
    echo -e """
      ${__HELP_TITLE_COLOR}Common Commands:${__RESET_COLOR}
      run         Create and run a new container from an image
      exec        Execute a command in a running container
      ps          List containers
      build       Build an image from a Dockerfile
      pull        Download an image from a registry
      push        Upload an image to a registry
      images      List images
      login       Log in to a registry
      logout      Log out from a registry
      search      Search Docker Hub for images
      version     Show the Docker version information
      info        Display system-wide information
      """
    echo
    echo -e "${__HELP_TITLE_COLOR}OPTIONS:${__RESET_COLOR}"
    printf "  %b\n" "${__HELP_OPTION_COLOR}--help${__HELP_NORMAL}, ${__HELP_OPTION_COLOR}-h${__HELP_NORMAL} (optional) (at most 1 times)"
    echo -e "    help"
  else
    Log::displayError "Command ${SCRIPT_NAME} - Option command invalid: '${options_parse_cmd}'"
    return 1
  fi
}
