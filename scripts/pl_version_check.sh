#!/bin/bash

#******************************************************************************************************************************
#
#   <pl_version_check.sh> **peter1000** see license at: [pl_helper_scripts](https://github.com/P-Linux/pl_helper_scripts)
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

ms_header "${_MS_GREEN}" "$(gettext "Listing version numbers of some development tools...")"

ms_request_continue

ms_has_tested_version "0.9.0"


#******************************************************************************************************************************
# List bash version / checks
#******************************************************************************************************************************
check_bash() {
    echo
    ms_msg "$(gettext "Checking: Bash")"
    ms_bold_i "$(gettext "bash: %s")" "$(bash --version | head -n1 | cut -d" " -f4-4)"

    ms_msg_i "$(gettext "/bin/sh should be a symbolic or hard link to bash")"
    local _mysh=$(readlink -f /bin/sh)
    if $(echo ${_mysh} | grep -q bash); then
        ms_bold_i "$(gettext "/bin/sh -> %s is a link")" "${_mysh}"
    else
        ms_warn2 "$(gettext "/bin/sh does not point to bash")"
    fi
}


#******************************************************************************************************************************
# List bison version / checks
#******************************************************************************************************************************
check_bison() {
    echo
    ms_msg "$(gettext "Checking: Bison")"
    ms_bold_i "$(gettext "bison: %s")" "$(bison --version | head -n1 | cut -d" " -f2-)"

    ms_msg_i "$(gettext "/usr/bin/yacc should be a link to bison or small script that executes bison")"
    if [[ -h "/usr/bin/yacc" ]]; then
        ms_bold_i "$(gettext "/usr/bin/yacc -> %s")" "$(readlink -f /usr/bin/yacc)"
    elif [[ -x "/usr/bin/yacc" ]]; then
        ms_bold_i "$(gettext "yacc is %s")" "$(/usr/bin/yacc --version | head -n1)"
    else
        ms_warn2 "$(gettext "/usr/bin/yacc not found")"
    fi
}


#******************************************************************************************************************************
# List gawk version / checks
#******************************************************************************************************************************
check_gawk() {
    echo
    ms_msg "$(gettext "Checking: Gawk")"
    ms_bold_i "$(gettext "gawk: %s")" "$(gawk --version | head -n1)"

    ms_msg_i "$(gettext "/usr/bin/awk should be a link to gawk")"
    if [[ -h "/usr/bin/awk" ]]; then
         ms_bold_i "$(gettext "/usr/bin/awk -> %s")" "$(readlink -f /usr/bin/awk)"
    elif [[ -x "/usr/bin/awk" ]]; then
      ms_bold_i "$(gettext "awk is %s")" "$(/usr/bin/awk --version | head -n1)"
    else
        ms_warn2 "$(gettext "/usr/bin/awk not found")"
    fi
}


#******************************************************************************************************************************
# List gcc version / checks
#******************************************************************************************************************************
check_gcc() {
    echo
    ms_msg "$(gettext "Checking: Gcc (including the C++ compiler)")"
    ms_bold_i "$(gettext "gcc: %s")" "$(gcc --version | head -n1 | cut -d" " -f2-)"
    ms_bold_i "$(gettext "g++: %s")" "$(g++ --version | head -n1 | cut -d" " -f2-)"

    ms_msg_i "$(gettext "Testing g++ compilation")"

    echo 'int main() {}' > dummy.c && g++ -o dummy dummy.c
    if [[ -x "dummy" ]]; then
        ms_bold_i "$(gettext "g++ compilation: OK")"
    else
        ms_warn2 "$(gettext "g++ compilation: FAILED")"
    fi
    rm -f dummy.c dummy
}


#******************************************************************************************************************************
# List Bzip2
#******************************************************************************************************************************
list_bzip2() {
    echo
    ms_msg "$(gettext "Checking: Bzip2")"
    ms_bold_i "$(gettext "bzip2: %s")" "$(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f8-)"
}


#******************************************************************************************************************************
# List common version
#******************************************************************************************************************************
list_common() {
    local _name=$1
    local _command=$2
    local _remove_front=${3:-""}

    echo
    ms_msg "$(gettext "Checking: %s")" "$_name"
    if [[ -n ${_remove_front} ]]; then
        ms_bold_i "$(gettext "%s: %s")" "$_command" "$($_command --version | head -n1 | cut -d" " -f${_remove_front}-)"
    else
        ms_bold_i "$(gettext "%s: %s")" "$_command" "$($_command --version | head -n1)"
    fi
}

#******************************************************************************************************************************
#   MAIN - RUN IT
#******************************************************************************************************************************
export LC_ALL=C

check_bash
check_bison
check_gawk
check_gcc

echo
ms_msg "$(gettext "Checking: Linux Kernel")"
ms_bold_i "$(gettext "Linux Kernel: %s")" "$(cat /proc/version | cut -d" " -f3-3)"

echo
ms_msg "$(gettext "Checking: Perl")"
ms_bold_i "$(gettext "perl: %s")" "$(perl -V:version)"

echo
ms_msg "$(gettext "Checking: Ncurses")"
ms_bold_i "$(gettext "tput: %s")" "$(tput -V | head -n1 | cut -d" " -f2-)"

list_bzip2

list_common "Binutils" "ld" "3"
list_common "Coreutils" "chown" "2"
list_common "Diffutils" "diff" "2"
list_common "Findutils" "find" "2"
list_common "Glibc" "ldd" "2"
list_common "Grep" "grep" "2"
list_common "Gzip" "gzip" "2"
list_common "M4" "m4" "2"
list_common "Make" "make"
list_common "Patch" "patch"
list_common "Sed" "sed" "2"
list_common "Tar" "tar" "2"
list_common "Makeinfo" "makeinfo" "2"
list_common "Xz" "xz" "4"
list_common "Util-linux" "mountpoint" "3"
list_common "Wget" "wget"
list_common "Curl" "curl" "2"
list_common "Git" "git" "3"
list_common "Subversion" "svn" "3"
list_common "Mercurial" "hg" "4"
list_common "Bazaar" "bzr" "3"
list_common "Inetutils" "ping" "2"
list_common "Bsdtar" "bsdtar" "2"


#******************************************************************************************************************************
# End of file
#******************************************************************************************************************************
