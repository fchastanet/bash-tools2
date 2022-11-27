#!/usr/bin/env bash

# add the line ip hostname at the end of /etc/hosts only if hostname does not exists yet in this file
# if wsl do the same in ${BASE_MNT_C}/Windows/System32/drivers/etc/hosts
# @param hostName
# @param ip (optional, default value: 127.0.0.1)
Dns::addHost() {
  local hostName="$1"
  local ip="${2:-127.0.0.1}"

  if ! grep -q -E "[[:space:]]${hostName}([[:space:]]|$)" /etc/hosts; then
    backupFile /etc/hosts
    printf '%s\t%s\n' "${ip}" "${hostName}" >>/etc/hosts
    Log::displaySuccess "Host ${hostName} added to /etc/hosts"
  fi
  if Functions::isWsl; then
    [[ -f "${BASE_MNT_C}/Windows/System32/drivers/etc/hosts" ]] || return 1
    if ! dos2unix <"${BASE_MNT_C}/Windows/System32/drivers/etc/hosts" | grep -q -E "[[:space:]]${hostName}([[:space:]]|$)"; then
      backupFile "${BASE_MNT_C}/Windows/System32/drivers/etc/hosts"
      cmd=(
        -ExecutionPolicy Bypass
        -NoProfile
        -Command Add-Content -Path "c:/Windows/System32/drivers/etc/hosts"
        -Value "'${ip} ${hostName}'"
      )
      ${POWERSHELL_BIN:-powershell.exe} -Command "Start-Process powershell \"${cmd[*]}\" -Verb RunAs"
      Log::displaySuccess "Host ${hostName} added to ${BASE_MNT_C}/Windows/System32/drivers/etc/hosts"
    fi
  fi
}
