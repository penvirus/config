#!/bin/bash

_get_all_devices() {
  _all_serial_ids=()
  _all_transport_ids=()

  while read -r line; do
    if [[ ${line} =~ transport_id:([0-9]+) ]]; then
      read -r serial _ <<< "${line}"
      _all_serial_ids+=("${serial}")

      _all_transport_ids+=("${BASH_REMATCH[1]}")
    fi
  done < <(adb devices -l)
}

_adb_completion() {
  local cur="${COMP_WORDS[${COMP_CWORD}]}"
  local pre=
  if [[ ${#COMP_WORDS[@]} -gt 1 ]]; then
    pre="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  fi

  if [[ "${pre}" == "-s" ]]; then
    _get_all_devices
    COMPREPLY=($(compgen -W "${_all_serial_ids[*]}" -- "${cur}"))
  elif [[ "${pre}" == "-t" ]]; then
    _get_all_devices
    COMPREPLY=($(compgen -W "${_all_transport_ids[*]}" -- "${cur}"))
  else
    COMPREPLY=($(compgen -W "-s -t connect devices kill-server shell" -- "${cur}"))
  fi
}
complete -F _adb_completion adb

_scrcpy_completion() {
  local cur="${COMP_WORDS[${COMP_CWORD}]}"
  local pre=
  if [[ ${#COMP_WORDS[@]} -gt 1 ]]; then
    pre="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  fi

  if [[ "${pre}" == "-s" ]]; then
    _get_all_devices
    COMPREPLY=($(compgen -W "${_all_serial_ids[*]}" -- "${cur}"))
  else
    COMPREPLY=($(compgen -W "-s" -- "${cur}"))
  fi
}
complete -F _scrcpy_completion scrcpy
