#!/bin/bash

#******************************************************************************************************************************
#
#   <pl_library_check.sh> **peter1000** see license at: [pl_helper_scripts](https://github.com/P-Linux/pl_helper_scripts)
#
#******************************************************************************************************************************
unset GREP_OPTIONS
shopt -s extglob

declare -r _PL_VERSION_CHECK_SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
declare -r _PL_BASH_FUNCTIONS_MAIN_CONF_FILE_PATH="$(dirname "${_PL_VERSION_CHECK_SCRIPT_PATH}")/main_conf.sh"
if ! source "${_PL_BASH_FUNCTIONS_MAIN_CONF_FILE_PATH}"; then
    printf "$(gettext "Could not source: <%s>")" "${_PL_BASH_FUNCTIONS_MAIN_CONF_FILE_PATH}"
    exit 1
fi

if ! source "${_PL_BASH_FUNCTIONS_DIR}/trap_exit.sh" &> /dev/null; then
    printf "$(gettext "Could not source: <%s>")" "${_PL_BASH_FUNCTIONS_DIR}/trap_exit.sh"
    exit 1
fi

for _signal in TERM HUP QUIT; do trap "tr_trap_exit \"${_signal}\"" "${_signal}"; done
trap "tr_trap_exit_interrupted" INT
trap "tr_trap_exit_unknown_error" ERR

if ! source "${_PL_BASH_FUNCTIONS_DIR}/msg.sh" &> /dev/null; then
    printf "$(gettext "Could not source: <%s>")" "${_PL_BASH_FUNCTIONS_DIR}/msg.sh"
    exit 1
fi

ms_format "${_PL_VERSION_CHECK_SCRIPT_PATH}"

ms_header "${_MS_GREEN}" "$(gettext "Checking for some library consistency...")"

ms_request_continue

ms_has_tested_version "0.9.2"


#******************************************************************************************************************************
# Check for some library consistency
#******************************************************************************************************************************
check_library_consistency() {
    local _fn="check_library_consistency"
    declare -i _present=0
    declare -i _absent=0
    local _msg1=$(gettext "The files identified by this script SHOULD be all PRESENT")
    local _msg2=$(gettext "            or all ABSENT, but not only one or two present.")
    local _msg3=$(gettext "      [ %s ]: Library consistency: PRESENT: '%s' ABSENT: '%s'")
    local _lib

    for _lib in lib{gmp,mpfr,mpc}.la; do
        if $(find /usr/lib* -name ${_lib} | grep -q ${_lib}); then
            ms_bold2 "$(gettext "%s: found")" "${_lib}"
            (( _present++ ))
        else
            ms_bold2 "$(gettext "%s: not found")" "${_lib}"
            (( _absent++ ))
        fi
    done

    echo
    ms_msg "$(gettext "NOTE....")"

    ms_header_i "${_MS_MAGENTA}" "${_msg1}\n    #${_msg2}"

    if (( _present > 0 )) && (( _absent > 0 )); then
        ms_color "${_MS_YELLOW}" "${_msg3}\n\n" "NOT OK" "$_present" "$_absent"
        ms_abort "$_fn" "$(gettext "[ NOT OK ] Problems with library consistency: PRESENT: '%s' ABSENT: '%s'")" "${_present}" \
            "${_absent}"
    else
        ms_color "${_MS_YELLOW}" "${_msg3}\n\n" "OK" "${_present}" "${_absent}"
    fi
}


#******************************************************************************************************************************
#   MAIN - RUN IT
#******************************************************************************************************************************
check_library_consistency


#******************************************************************************************************************************
# End of file
#******************************************************************************************************************************
