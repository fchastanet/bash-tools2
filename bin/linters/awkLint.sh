#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/linters/awkLint.sh
# DO NOT EDIT IT
#####################################

ROOT_DIR="/home/wsl/projects/bash-tools2"
# shellcheck disable=SC2034
LIB_DIR="${ROOT_DIR}/lib"
# shellcheck disable=SC2034

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

awkLintScript="$(
  cat <<'EOF'
BEGIN {
  file=""
  lineNumber=0
  lineIdx=0
  previousLineNumber=0
  message=""
  column=0
  severity="warning"
  errorNumber=0
}
{
  line=$0

  # awk: bin/mysql2puml.awk:181:     if (length(currentLine) < 2 || match(currentLine, "^--") > 0) {
  # awk: bin/mysql2puml.awk:181:     ^ syntax error
  # awk: warning: function uml_parse_line called but never defined

  if (match(line, /^awk: ([^:]+):([^:]+): ([ ]*)(.+)$/, arr)) {
      file=arr[1]
      oldLineNumber=lineNumber
      lineNumber=arr[2]
      if ( \
        oldLineNumber != lineNumber \
        && !(oldLineNumber ",message" in lineDetails) \
      ) {
        # special case where lineNumber is presented only once
        # eg: awk: bin/mysql2puml.awk:14: BEGIN blocks must have an action part
        lineDetails[oldLineNumber ",severity"] = "error"
        lineDetails[oldLineNumber ",message"] = lineDetails[oldLineNumber ",source"]
        delete lineDetails[oldLineNumber ",source"]
      }

      if (oldLineNumber == lineNumber) {
        lineDetails[lineNumber ",message"] = arr[4]
        lineDetails[lineNumber ",columnNumber"] = length(arr[3]) + 1
        lineDetails[lineNumber ",severity"] = (index(arr[4], "error") == 0)?"warning":"error"
      } else if (match(arr[4], /^warning:/)) {
        lineDetails[lineNumber ",message"] = arr[4]
        lineDetails[lineNumber ",columnNumber"] = -1
        lineDetails[lineNumber ",severity"] = "warning"
        lines[lineIdx++]=lineNumber
      } else {
        lineDetails[lineNumber ",source"]=arr[4]
        lines[lineIdx++]=lineNumber
      }
  } else if (match(line, /^awk: (warning:) (.+)$/, arr)) {
    errorNumber--
    lines[lineIdx++]=errorNumber
    lineDetails[errorNumber ",message"] = arr[2]
    lineDetails[errorNumber ",columnNumber"] = 0
    lineDetails[errorNumber ",lineNumber"] = 0
    lineDetails[errorNumber ",severity"] = (index(arr[2], "warning") == 0)?"error":"warning"
  } else {
    errorNumber--
    lines[lineIdx++]=errorNumber
    lineDetails[errorNumber ",message"] = line
    lineDetails[errorNumber ",columnNumber"] = 0
    lineDetails[errorNumber ",lineNumber"] = 0
    lineDetails[errorNumber ",severity"] = (index(line, "warning") == 0)?"error":"warning"
  }
}

END {
  for (lineIdx in lines) {
    lineNumber = lines[lineIdx]
    message=""
    if (lineNumber ",source" in lineDetails) {
      message = message lineDetails[lineNumber ",source"];
      message = message " "
    }
    message = message lineDetails[lineNumber ",message"]

    printf("<error line=\"%s\" column=\"%s\" severity=\"%s\" message=\"%s\" />\n",  \
      lineNumber, \
      lineDetails[lineNumber ",columnNumber"], \
      lineDetails[lineNumber ",severity"], \
      escapeXmlAttribute(message) \
    )
  }
}

# quote function for attribute values
#  escape every character, which can
#  cause problems in attribute value
#  strings; we have no information,
#  whether attribute values were
#  enclosed in single or double quotes
function escapeXmlAttribute(str)
{
    gsub(/&/, "\\&amp;", str)
    gsub(/</, "\\&lt;", str)
    gsub(/"/, "\\&quot;", str)
    gsub(/'/, "\\&apos;", str)
    return str
}
EOF
)"

(
  cd "${ROOT_DIR}" || exit 1
  # <?xml version='1.0' encoding='UTF-8'?>
  # <checkstyle version='4.3'>
  # <file name='./tests/bash&#45;framework/ManualTest.sh' >
  # <error line='9' column='8' severity='warning' message='Can&#39;t follow non&#45;constant source. Use a directive to specify location.' source='ShellCheck.SC1090' />
  # <error line='17' column='5' severity='warning' message='Use &#39;cd ... &#124;&#124; exit&#39; or &#39;cd ... &#124;&#124; return&#39; in case cd fails.' source='ShellCheck.SC2164' />
  # <error line='27' column='5' severity='warning' message='Use &#39;cd ... &#124;&#124; exit&#39; or &#39;cd ... &#124;&#124; return&#39; in case cd fails.' source='ShellCheck.SC2164' />
  # </file>
  # </checkstyle>
  echo "<?xml version='1.0' encoding='UTF-8'?>"
  echo "<checkstyle>"
  find . -type f -name '*.awk' -not -path './.history/*' | while IFS='' read -r file; do
    echo "<file name='${file}'>"
    awk --source "BEGIN { exit(0) } END { exit(0) }" --lint=no-ext -f "${file}" 2>&1 </dev/null |
      awk --source "${awkLintScript}" -
    echo "</file>"
  done
  echo "</checkstyle>"
)
