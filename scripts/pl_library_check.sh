#!/bin/bash

#******************************************************************************************************************************
#
#   <pl_library_check.sh> **peter1000** see license at: [pl_helper_scripts](https://github.com/P-Linux/pl_helper_scripts)
#
#******************************************************************************************************************************
declare -r _PL_VERSION_CHECK_SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
declare -r _PL_BASH_FUNCTIONS_MAIN_CONF_FILE_PATH="$(dirname "${_PL_VERSION_CHECK_SCRIPT_PATH}")/main_conf.sh"

if ! source "${_PL_BASH_FUNCTIONS_MAIN_CONF_FILE_PATH}"; then
    printf "Could not source: <%s>" "${_PL_BASH_FUNCTIONS_MAIN_CONF_FILE_PATH}"
    exit 1
fi

if ! source "${_PL_BASH_FUNCTIONS_DIR}/init_conf.sh" &> /dev/null; then
    printf "Could not source: <%s>" "${_PL_BASH_FUNCTIONS_DIR}/init_conf.sh"
    exit 1
fi

for _signal in TERM HUP QUIT; do trap 'i_trap_s ${?} "${_signal}"' "${_signal}"; done
trap 'i_trap_i ${?}' INT
trap 'i_trap_err ${?} "${BASH_COMMAND}" ${LINENO}' ERR


i_header "${_BF_GREEN}" "$(_g "Checking for some library consistency...")"

i_ask_continue

i_has_tested_version "0.9.4"


#******************************************************************************************************************************
# Check for some library consistency
#******************************************************************************************************************************
check_library_consistency() {
    declare -i _present=0
    declare -i _absent=0
    local _m1=$(gettext "The files identified by this script SHOULD be all PRESENT")
    local _m2=$(gettext "            or all ABSENT, but not only one or two present.")
    local _m3=$(gettext "      [ %s ]: Library consistency: PRESENT: '%s' ABSENT: '%s'")
    local _lib

    for _lib in lib{gmp,mpfr,mpc}.la; do
        if $(find /usr/lib* -name ${_lib} | grep -q ${_lib}); then
            i_bold2 "$(_g "%s: found")" "${_lib}"
            _present+=1
        else
            i_bold2 "$(_g "%s: not found")" "${_lib}"
            _absent+=1
        fi
    done

    echo
    i_msg "$(_g "NOTE....")"

    i_header_i "${_BF_MAGENTA}" "${_m1}\n    #${_m2}"

    if (( _present > 0 )) && (( _absent > 0 )); then
        i_color "${_BF_YELLOW}" "${_m3}\n\n" "NOT OK" "$_present" "$_absent"
        i_exit ${?} ${LINENO} "$(_g "[ NOT OK ] Problems with library consistency: PRESENT: '%s' ABSENT: '%s'")" \
            "${_present}"  "${_absent}"
    else
        i_color "${_BF_YELLOW}" "${_m3}\n\n" "OK" "${_present}" "${_absent}"
    fi
}


#******************************************************************************************************************************
#   MAIN - RUN IT
#******************************************************************************************************************************
check_library_consistency


#******************************************************************************************************************************
# End of file
#******************************************************************************************************************************
