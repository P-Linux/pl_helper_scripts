#!/bin/bash

#******************************************************************************************************************************
#
#   <pl_version_check.sh> **peter1000** see license at: [pl_helper_scripts](https://github.com/P-Linux/pl_helper_scripts)
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


i_header "${_BF_GREEN}" "$(_g "Listing version numbers of some development tools...")"

i_ask_continue

i_has_tested_version "0.9.4"


#******************************************************************************************************************************
# List bash version / checks
#******************************************************************************************************************************
check_bash() {
    local _mysh

    echo
    i_msg "$(_g "Checking: Bash")"
    i_bold_i "$(_g "bash: %s")" "$(bash --version | head -n1 | cut -d" " -f4-4)"

    i_msg_i "$(_g "/bin/sh should be a symbolic or hard link to bash")"

    _mysh=$(readlink -f /bin/sh)
    if $(echo ${_mysh} | grep -q bash); then
        i_bold_i "$(_g "/bin/sh -> %s is a link")" "${_mysh}"
    else
        m_warn2 "$(_g "/bin/sh does not point to bash")"
    fi
}


#******************************************************************************************************************************
# List bison version / checks
#******************************************************************************************************************************
check_bison() {
    echo
    i_msg "$(_g "Checking: Bison")"
    i_bold_i "$(_g "bison: %s")" "$(bison --version | head -n1 | cut -d" " -f2-)"

    i_msg_i "$(_g "/usr/bin/yacc should be a link to bison or small script that executes bison")"
    if [[ -h "/usr/bin/yacc" ]]; then
        i_bold_i "$(_g "/usr/bin/yacc -> %s")" "$(readlink -f /usr/bin/yacc)"
    elif [[ -x "/usr/bin/yacc" ]]; then
        i_bold_i "$(_g "yacc is %s")" "$(/usr/bin/yacc --version | head -n1)"
    else
        m_warn2 "$(_g "/usr/bin/yacc not found")"
    fi
}


#******************************************************************************************************************************
# List gawk version / checks
#******************************************************************************************************************************
check_gawk() {
    echo
    i_msg "$(_g "Checking: Gawk")"
    i_bold_i "$(_g "gawk: %s")" "$(gawk --version | head -n1)"

    i_msg_i "$(_g "/usr/bin/awk should be a link to gawk")"
    if [[ -h "/usr/bin/awk" ]]; then
         i_bold_i "$(_g "/usr/bin/awk -> %s")" "$(readlink -f /usr/bin/awk)"
    elif [[ -x "/usr/bin/awk" ]]; then
      i_bold_i "$(_g "awk is %s")" "$(/usr/bin/awk --version | head -n1)"
    else
        m_warn2 "$(_g "/usr/bin/awk not found")"
    fi
}


#******************************************************************************************************************************
# List gcc version / checks
#******************************************************************************************************************************
check_gcc() {
    echo
    i_msg "$(_g "Checking: Gcc (including the C++ compiler)")"
    i_bold_i "$(_g "gcc: %s")" "$(gcc --version | head -n1 | cut -d" " -f2-)"
    i_bold_i "$(_g "g++: %s")" "$(g++ --version | head -n1 | cut -d" " -f2-)"

    i_msg_i "$(_g "Testing g++ compilation")"

    echo 'int main() {}' > dummy.c
    g++ -o dummy dummy.c
    if [[ -x "dummy" ]]; then
        i_bold_i "$(_g "g++ compilation: OK")"
    else
        m_warn2 "$(_g "g++ compilation: FAILED")"
    fi
    rm -f dummy.c dummy
}


#******************************************************************************************************************************
# List Bzip2
#******************************************************************************************************************************
list_bzip2() {
    echo
    i_msg "$(_g "Checking: Bzip2")"
    i_bold_i "$(_g "bzip2: %s")" "$(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f8-)"
}


#******************************************************************************************************************************
# List common version
#******************************************************************************************************************************
list_common() {
    local _name=$1
    local _command=$2
    local _rm_front=${3:-""}

    echo
    i_msg "$(_g "Checking: %s")" "$_name"
    if [[ -n ${_rm_front} ]]; then
        i_bold_i "$(_g "%s: %s")" "$_command" "$($_command --version | head -n1 | cut -d" " -f${_rm_front}-)"
    else
        i_bold_i "$(_g "%s: %s")" "$_command" "$($_command --version | head -n1)"
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
i_msg "$(_g "Checking: Linux Kernel")"
i_bold_i "$(_g "Linux Kernel: %s")" "$(cat /proc/version | cut -d" " -f3-3)"

echo
i_msg "$(_g "Checking: Perl")"
i_bold_i "$(_g "perl: %s")" "$(perl -V:version)"

echo
i_msg "$(_g "Checking: Ncurses")"
i_bold_i "$(_g "tput: %s")" "$(tput -V | head -n1 | cut -d" " -f2-)"

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
list_common "Gettext" "gettext" "2"
list_common "PROCPS-NG" "ps" "3"


#******************************************************************************************************************************
# End of file
#******************************************************************************************************************************
