#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Array/wrap2.sh
source "${srcDir}/Array/wrap2.sh"
# shellcheck source=/src/Filters/removeAnsiCodes.sh
source "${srcDir}/Filters/removeAnsiCodes.sh"

function Array::wrap2::noArg { #@test
  run Array::wrap2
  assert_success
  assert_output ""
}

function Array::wrap2::glue { #@test
  run Array::wrap2 ":"
  assert_success
  assert_output ""
}

function Array::wrap2::glueAndLength { #@test
  run Array::wrap2 ":" 12
  assert_success
  assert_output ""
}

function Array::wrap2::glueLengthAndIndent { #@test
  run Array::wrap2 ":" 12 2
  assert_success
  assert_output ""
}

function Array::wrap2::OneArrayElement::noWrap { #@test
  run Array::wrap2 ":" 80 0 "hello"
  assert_success
  assert_output "hello"
}

function Array::wrap2::OneArrayElement::wrap { #@test
  run Array::wrap2 ":" 80 0 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac elit id massa condimentum finibus."
  assert_success
  assert_lines_count 2
  assert_line --index 0 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac elit id ma"
  assert_line --index 1 "ssa condimentum finibus."
}

function Array::wrap2::4ArrayElement::wrap40 { #@test
  run Array::wrap2 ":" 40 0 \
    "Lorem ipsum dolor sit amet," \
    "consectetur adipiscing elit." \
    "Curabitur ac elit id massa" \
    "condimentum finibus."
  assert_success

  assert_lines_count 4
  assert_line --index 0 "Lorem ipsum dolor sit amet,"
  assert_line --index 1 "consectetur adipiscing elit."
  assert_line --index 2 "Curabitur ac elit id massa"
  assert_line --index 3 "condimentum finibus."
}

function Array::wrap2::4ArrayElement::wrap20 { #@test
  run Array::wrap2 ":" 20 0 \
    "Lorem ipsum dolor sit amet," \
    "consectetur adipiscing elit." \
    "Curabitur ac elit id massa" \
    "condimentum finibus."
  assert_success
  assert_lines_count 7
  assert_line --index 0 "Lorem ipsum dolor si"
  assert_line --index 1 "t amet,"
  assert_line --index 2 "consectetur adipisci"
  assert_line --index 3 "ng elit."
  assert_line --index 4 "Curabitur ac elit id"
  assert_line --index 5 "massa"
  assert_line --index 6 "condimentum finibus."
}

function Array::wrap2::realExample::noIndent { #@test
  run Array::wrap2 " " 80 0 \
    "Usage:  Options::generateCommand" \
    "--help <String|Function>" \
    "[--command-name <String|Function>]" \
    "[--version <String|Function>]" \
    "[--author <String|Function>]" \
    "[--License <String|Function>]" \
    "[--copyright <String|Function>]" \
    "[--help-template <String>]"
  assert_success
  assert_lines_count 4
  assert_line --index 0 "Usage:  Options::generateCommand --help <String|Function>"
  assert_line --index 1 "[--command-name <String|Function>] [--version <String|Function>]"
  assert_line --index 2 "[--author <String|Function>] [--License <String|Function>]"
  assert_line --index 3 "[--copyright <String|Function>] [--help-template <String>]"
}

function Array::wrap2::realExample::indent2 { #@test
  run Array::wrap2 " " 80 2 \
    "Usage:  Options::generateCommand" \
    "--help <String|Function>" \
    "[--command-name <String|Function>]" \
    "[--version <String|Function>]" \
    "[--author <String|Function>]" \
    "[--License <String|Function>]" \
    "[--copyright <String|Function>]" \
    "[--help-template <String>]"
  assert_success
  assert_lines_count 4
  assert_line --index 0 "Usage:  Options::generateCommand --help <String|Function>"
  assert_line --index 1 "  [--command-name <String|Function>] [--version <String|Function>]"
  assert_line --index 2 "  [--author <String|Function>] [--License <String|Function>]"
  assert_line --index 3 "  [--copyright <String|Function>] [--help-template <String>]"
}

function Array::wrap2::realExample::indent3 { #@test
  Array::wrap2 " " 80 0 "\e[32mDescription:\e[0m" "lint awk files
\n

Lint all files with .awk extension in specified folder.
Filters out eventual .history folder
Result in checkstyle format." >"${BATS_TEST_TMPDIR}/result"
  diff -u "${BATS_TEST_TMPDIR}/result" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap2_indent3.expected.result") >&3
}

function Array::wrap2::realExample::indent4 { #@test
  run Array::wrap2 " " 80 0 "USAGE: awkLint" "[--display-level <String>]" \
    "[--help|-h]" "[--log-level <String>]" "[--no-color]" "[--quiet|-q]" \
    "[--verbose|-v]" "[--version]"
  assert_lines_count 2
  assert_line --index 0 "USAGE: awkLint [--display-level <String>] [--help|-h] [--log-level <String>]"
  assert_line --index 1 "[--no-color] [--quiet|-q] [--verbose|-v] [--version]"
}

function Array::wrap2::help { #@test
  run Array::wrap2 " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "test" "[--help|-h]" "[--src-dirs|-s <String>]" "[--verbose|-v]" "[--quiet|-q]"
  assert_output "$(echo -e "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR} test [--help|-h] [--src-dirs|-s <String>] [--verbose|-v] [--quiet|-q]")"
}

function Array::wrap2::emptyArgShouldCreateNewLines { #@test
  run Array::wrap2 " " 80 2 "line1" "" "line2"
  assert_lines_count 2
  assert_line --index 0 "line1"
  assert_line --index 1 "  line2"
}

function Array::wrap2::argWithForcedNewLines { #@test
  Array::wrap2 " " 80 2 "line1" $'\n' "line2" >"${BATS_TEST_TMPDIR}/result"
  diff -u "${BATS_TEST_TMPDIR}/result" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap2_emptyLinesWithForcedNewLines.expected.result") >&3
}

function Array::wrap2::argFunction { #@test
  help() {
    echo "container should be the name of a profile from profile list,"
    echo "check containers list below." $'\n'
    echo "If not provided, it will load the container specified in default configuration." $'\n'
  }

  Array::wrap2 ' ' 76 4 "$(help)" >"${BATS_TEST_TMPDIR}/result2"
  diff -u "${BATS_TEST_TMPDIR}/result2" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap2_argFunction.expected.result") >&3
}

function Array::wrap2::multilineArg { #@test
  local -a helpArray=($'\n  Common Commands:\n  run         Create and run a new container from an image\n  exec        Execute a command in a running container\n  ps          List containers\n  build       Build an image from a Dockerfile\n  pull        Download an image from a registry\n  push        Upload an image to a registry\n  images      List images\n  login       Log in to a registry\n  logout      Log out from a registry\n  search      Search Docker Hub for images\n  version     Show the Docker version information\n  info        Display system-wide information')

  Array::wrap2 " " 76 4 "${helpArray[@]}" >"${BATS_TEST_TMPDIR}/result3"
  diff -u <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap2_multilineArg.expected.result") "${BATS_TEST_TMPDIR}/result3" >&3

  echo -e "$(Array::wrap2 " " 76 4 "${helpArray[@]}")" >"${BATS_TEST_TMPDIR}/result4"
  diff -u "${BATS_TEST_TMPDIR}/result4" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap2_multilineArg.expected.result") >&3
}

function Array::wrap2::OneArrayElement::wrapAvoidsSpaceOnNewline { #@test
  run Array::wrap2 ":" 10 0 "Lorem ipsu dolor sit"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "Lorem ipsu"
  assert_line --index 1 "dolor sit"
}
