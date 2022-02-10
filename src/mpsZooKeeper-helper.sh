#
#
# author: Norman Köster
# date: 23.09.2021
# description: Helper file for the mpsZooKeeper.sh
# version: 1.0
#
# The content of this helper file is based on a template by BASH3 Boilerplate v2.4.1
# Copyright (c) 2013 Kevin van Zonneveld and contributors
#
# https://github.com/kvz/bash3boilerplate
# http://bash3boilerplate.sh/#authors
#
#


# before sourcing this you need to define a usage such as:
#
#
#[[ "${__usage+x}" ]] || read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
#  -f --file  [arg] Filename to process. Required.
#  -t --temp  [arg] Location of tempfile. Default="/tmp/bar"
#  -v               Enable verbose mode, print script as it is executed
#  -d --debug       Enables debug mode
#  -h --help        This page
#  -n --no-color    Disable color output
#  -1 --one         Do just one thing
#  -i --input [arg] File to process. Can be repeated.
#  -x               Specify a flag. Can be repeated.
#EOF

# also set a help text in advance:
#
# shellcheck disable=SC2015
# [[ "${__helptext+x}" ]] || read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
#  This is Bash3 Boilerplate's help text. Feel free to add any description of your
#  program or elaborate more on command-line arguments. This section is not
#  parsed and will be added as-is to the help.
# EOF



# to ensure required args are set in your code use this:
# [[ "${arg_f:-}" ]]     || help      "Setting a filename with -f or --file is required"


# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace


if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  __i_am_main_script="0" # false

  if [[ "${__usage+x}" ]]; then
    if [[ "${BASH_SOURCE[1]}" = "${0}" ]]; then
      __i_am_main_script="1" # true
    fi

    __external_usage="true"
    __tmp_source_idx=1
  fi
else
  __i_am_main_script="1" # true
  [[ "${__usage+x}" ]] && unset -v __usage
  [[ "${__helptext+x}" ]] && unset -v __helptext
fi

# Set magic variables for current file, directory, os, etc.
__dir="$(cd "$(dirname "${BASH_SOURCE[${__tmp_source_idx:-0}]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[${__tmp_source_idx:-0}]}")"
__base="$(basename "${__file}" .sh)"
__invocation="$(printf %q "${__file}")$( (($#)) && printf ' %q' "$@" || true)"




##############################################################################
### Logging
##############################################################################

# Define the environment variables (and their defaults) that this script depends on
LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency
NO_COLOR="${NO_COLOR:-}"    # true = disable color. otherwise autodetected

function __log () {
  local log_level="${1}"
  shift

  # shellcheck disable=SC2034
  local color_debug="\\x1b[35m"
  # shellcheck disable=SC2034
  local color_info="\\x1b[32m"
  # shellcheck disable=SC2034
  local color_notice="\\x1b[34m"
  # shellcheck disable=SC2034
  local color_warning="\\x1b[33m"
  # shellcheck disable=SC2034
  local color_error="\\x1b[31m"
  # shellcheck disable=SC2034
  local color_critical="\\x1b[1;31m"
  # shellcheck disable=SC2034
  local color_alert="\\x1b[1;37;41m"
  # shellcheck disable=SC2034
  local color_emergency="\\x1b[1;4;5;37;41m"

  local colorvar="color_${log_level}"

  local color="${!colorvar:-${color_error}}"
  local color_reset="\\x1b[0m"

  if [[ "${NO_COLOR:-}" = "true" ]] || { [[ "${TERM:-}" != "xterm"* ]] && [[ "${TERM:-}" != "screen"* ]]; } || [[ ! -t 2 ]]; then
    if [[ "${NO_COLOR:-}" != "false" ]]; then
      # Don't use colors on pipes or non-recognized terminals
      color=""; color_reset=""
    fi
  fi

  # all remaining arguments are to be printed
  local log_line=""

  while IFS=$'\n' read -r log_line; do
    echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" "${log_level}")${color_reset} ${log_line}" 1>&2
  done <<< "${@:-}"
}

function log_emergency () {                                __log emergency "${@}"; exit 1; }
function log_alert ()     { [[ "${LOG_LEVEL:-0}" -ge 1 ]] && __log alert "${@}"; true; }
function log_critical ()  { [[ "${LOG_LEVEL:-0}" -ge 2 ]] && __log critical "${@}"; true; }
function log_error ()     { [[ "${LOG_LEVEL:-0}" -ge 3 ]] && __log error "${@}"; true; }
function log_warning ()   { [[ "${LOG_LEVEL:-0}" -ge 4 ]] && __log warning "${@}"; true; }
function log_notice ()    { [[ "${LOG_LEVEL:-0}" -ge 5 ]] && __log notice "${@}"; true; }
function log_info ()      { [[ "${LOG_LEVEL:-0}" -ge 6 ]] && __log info "${@}"; true; }
function log_debug ()     { [[ "${LOG_LEVEL:-0}" -ge 7 ]] && __log debug "${@}"; true; }


##############################################################################
### Handle arguments
##############################################################################
### Parse commandline options
##############################################################################

# Commandline options. This defines the usage page, and is used to parse cli
# opts & defaults from. The parsing is unforgiving so be precise in your syntax
# - A short option must be preset for every long option; but every short option
#   need not have a long option
# - `--` is respected as the separator between options and arguments
# - We do not bash-expand defaults, so setting '~/app' as a default will not resolve to ${HOME}.
#   you can use bash variables to work around this (so use ${HOME} instead)

function help () {
  echo "" 1>&2
  echo "  ${*}" 1>&2
  echo "" 1>&2
  exit 1
}

function helptxt () {
  echo "  ${*}" 1>&2

  if [[ "${__usage_minimal:-}" ]]; then
    echo "${__usage_minimal}" 1>&2
  fi

  echo "" 1>&2
  echo "    ${__usage:-No usage available}" 1>&2

  if [[ "${__helptext:-}" ]]; then
    echo "" 1>&2
    echo "   ${__helptext}" 1>&2
    echo "" 1>&2
  fi

  exit 1
}



# Translate usage string -> getopts arguments, and set $arg_<flag> defaults
while read -r __b3bp_tmp_line; do
  if [[ "${__b3bp_tmp_line}" =~ ^- ]]; then
    # fetch single character version of option string
    __b3bp_tmp_opt="${__b3bp_tmp_line%% *}"
    __b3bp_tmp_opt="${__b3bp_tmp_opt:1}"

    # fetch long version if present
    __b3bp_tmp_long_opt=""

    if [[ "${__b3bp_tmp_line}" = *"--"* ]]; then
      __b3bp_tmp_long_opt="${__b3bp_tmp_line#*--}"
      __b3bp_tmp_long_opt="${__b3bp_tmp_long_opt%% *}"
    fi

    # map opt long name to+from opt short name
    printf -v "__b3bp_tmp_opt_long2short_${__b3bp_tmp_long_opt//-/_}" '%s' "${__b3bp_tmp_opt}"
    printf -v "__b3bp_tmp_opt_short2long_${__b3bp_tmp_opt}" '%s' "${__b3bp_tmp_long_opt//-/_}"

    # check if option takes an argument
    if [[ "${__b3bp_tmp_line}" =~ \[.*\] ]]; then
      __b3bp_tmp_opt="${__b3bp_tmp_opt}:" # add : if opt has arg
      __b3bp_tmp_init=""  # it has an arg. init with ""
      printf -v "__b3bp_tmp_has_arg_${__b3bp_tmp_opt:0:1}" '%s' "1"
    elif [[ "${__b3bp_tmp_line}" =~ \{.*\} ]]; then
      __b3bp_tmp_opt="${__b3bp_tmp_opt}:" # add : if opt has arg
      __b3bp_tmp_init=""  # it has an arg. init with ""
      # remember that this option requires an argument
      printf -v "__b3bp_tmp_has_arg_${__b3bp_tmp_opt:0:1}" '%s' "2"
    else
      __b3bp_tmp_init="0" # it's a flag. init with 0
      printf -v "__b3bp_tmp_has_arg_${__b3bp_tmp_opt:0:1}" '%s' "0"
    fi
    __b3bp_tmp_opts="${__b3bp_tmp_opts:-}${__b3bp_tmp_opt}"

    if [[ "${__b3bp_tmp_line}" =~ ^Can\ be\ repeated\. ]] || [[ "${__b3bp_tmp_line}" =~ \.\ *Can\ be\ repeated\. ]]; then
      # remember that this option can be repeated
      printf -v "__b3bp_tmp_is_array_${__b3bp_tmp_opt:0:1}" '%s' "1"
    else
      printf -v "__b3bp_tmp_is_array_${__b3bp_tmp_opt:0:1}" '%s' "0"
    fi
  fi

  [[ "${__b3bp_tmp_opt:-}" ]] || continue

  if [[ "${__b3bp_tmp_line}" =~ ^Default= ]] || [[ "${__b3bp_tmp_line}" =~ \.\ *Default= ]]; then
    # ignore default value if option does not have an argument
    __b3bp_tmp_varname="__b3bp_tmp_has_arg_${__b3bp_tmp_opt:0:1}"
    if [[ "${!__b3bp_tmp_varname}" != "0" ]]; then
      # take default
      __b3bp_tmp_init="${__b3bp_tmp_line##*Default=}"
      # strip double quotes from default argument
      __b3bp_tmp_re='^"(.*)"$'
      if [[ "${__b3bp_tmp_init}" =~ ${__b3bp_tmp_re} ]]; then
        __b3bp_tmp_init="${BASH_REMATCH[1]}"
      else
        # strip single quotes from default argument
        __b3bp_tmp_re="^'(.*)'$"
        if [[ "${__b3bp_tmp_init}" =~ ${__b3bp_tmp_re} ]]; then
          __b3bp_tmp_init="${BASH_REMATCH[1]}"
        fi
      fi
    fi
  fi

  if [[ "${__b3bp_tmp_line}" =~ ^Required\. ]] || [[ "${__b3bp_tmp_line}" =~ \.\ *Required\. ]]; then
    # remember that this option requires an argument
    printf -v "__b3bp_tmp_has_arg_${__b3bp_tmp_opt:0:1}" '%s' "2"
  fi

  # Init var with value unless it is an array / a repeatable
  __b3bp_tmp_varname="__b3bp_tmp_is_array_${__b3bp_tmp_opt:0:1}"
  [[ "${!__b3bp_tmp_varname}" = "0" ]] && printf -v "arg_${__b3bp_tmp_opt:0:1}" '%s' "${__b3bp_tmp_init}"
done <<< "${__usage:-}"

# run getopts only if options were specified in __usage
if [[ "${__b3bp_tmp_opts:-}" ]]; then
  # Allow long options like --this
  __b3bp_tmp_opts="${__b3bp_tmp_opts}-:"

  # Reset in case getopts has been used previously in the shell.
  OPTIND=1

  # start parsing command line
  set +o nounset # unexpected arguments will cause unbound variables
                 # to be dereferenced
  # Overwrite $arg_<flag> defaults with the actual CLI options
  while getopts "${__b3bp_tmp_opts}" __b3bp_tmp_opt; do
    [[ "${__b3bp_tmp_opt}" = "?" ]] && help "Invalid use of script: ${*} "

    if [[ "${__b3bp_tmp_opt}" = "-" ]]; then
      # OPTARG is long-option-name or long-option=value
      if [[ "${OPTARG}" =~ .*=.* ]]; then
        # --key=value format
        __b3bp_tmp_long_opt=${OPTARG/=*/}
        # Set opt to the short option corresponding to the long option
        __b3bp_tmp_varname="__b3bp_tmp_opt_long2short_${__b3bp_tmp_long_opt//-/_}"
        printf -v "__b3bp_tmp_opt" '%s' "${!__b3bp_tmp_varname}"
        OPTARG=${OPTARG#*=}
      else
        # --key value format
        # Map long name to short version of option
        __b3bp_tmp_varname="__b3bp_tmp_opt_long2short_${OPTARG//-/_}"
        printf -v "__b3bp_tmp_opt" '%s' "${!__b3bp_tmp_varname}"
        # Only assign OPTARG if option takes an argument
        __b3bp_tmp_varname="__b3bp_tmp_has_arg_${__b3bp_tmp_opt}"
        __b3bp_tmp_varvalue="${!__b3bp_tmp_varname}"
        [[ "${__b3bp_tmp_varvalue}" != "0" ]] && __b3bp_tmp_varvalue="1"
        printf -v "OPTARG" '%s' "${@:OPTIND:${__b3bp_tmp_varvalue}}"
        # shift over the argument if argument is expected
        ((OPTIND+=__b3bp_tmp_varvalue))
      fi
      # we have set opt/OPTARG to the short value and the argument as OPTARG if it exists
    fi

    __b3bp_tmp_value="${OPTARG}"

    __b3bp_tmp_varname="__b3bp_tmp_is_array_${__b3bp_tmp_opt:0:1}"
    if [[ "${!__b3bp_tmp_varname}" != "0" ]]; then
      # repeatables
      # shellcheck disable=SC2016
      if [[ -z "${OPTARG}" ]]; then
        # repeatable flags, they increcemnt
        __b3bp_tmp_varname="arg_${__b3bp_tmp_opt:0:1}"
        log_debug "cli arg ${__b3bp_tmp_varname} = (${__b3bp_tmp_default}) -> ${!__b3bp_tmp_varname}"
          # shellcheck disable=SC2004
        __b3bp_tmp_value=$((${!__b3bp_tmp_varname} + 1))
        printf -v "${__b3bp_tmp_varname}" '%s' "${__b3bp_tmp_value}"
      else
        # repeatable args, they get appended to an array
        __b3bp_tmp_varname="arg_${__b3bp_tmp_opt:0:1}[@]"
        log_debug "cli arg ${__b3bp_tmp_varname} append ${__b3bp_tmp_value}"
        declare -a "${__b3bp_tmp_varname}"='("${!__b3bp_tmp_varname}" "${__b3bp_tmp_value}")'
      fi
    else
      # non-repeatables
      __b3bp_tmp_varname="arg_${__b3bp_tmp_opt:0:1}"
      __b3bp_tmp_default="${!__b3bp_tmp_varname}"

      if [[ -z "${OPTARG}" ]]; then
        __b3bp_tmp_value=$((__b3bp_tmp_default + 1))
      fi

      printf -v "${__b3bp_tmp_varname}" '%s' "${__b3bp_tmp_value}"

      log_debug "cli arg ${__b3bp_tmp_varname} = (${__b3bp_tmp_default}) -> ${!__b3bp_tmp_varname}"
    fi
  done
  set -o nounset # no more unbound variable references expected

  shift $((OPTIND-1))

  if [[ "${1:-}" = "--" ]] ; then
    shift
  fi
fi

### Automatic validation of required option arguments
##############################################################################

for __b3bp_tmp_varname in ${!__b3bp_tmp_has_arg_*}; do
  # validate only options which required an argument
  [[ "${!__b3bp_tmp_varname}" = "2" ]] || continue

  __b3bp_tmp_opt_short="${__b3bp_tmp_varname##*_}"
  __b3bp_tmp_varname="arg_${__b3bp_tmp_opt_short}"
  [[ "${!__b3bp_tmp_varname}" ]] && continue

  __b3bp_tmp_varname="__b3bp_tmp_opt_short2long_${__b3bp_tmp_opt_short}"
  printf -v "__b3bp_tmp_opt_long" '%s' "${!__b3bp_tmp_varname}"
  [[ "${__b3bp_tmp_opt_long:-}" ]] && __b3bp_tmp_opt_long=" (--${__b3bp_tmp_opt_long//_/-})"

  help "Option -${__b3bp_tmp_opt_short}${__b3bp_tmp_opt_long:-} requires an argument"
done


### Cleanup Environment variables
##############################################################################

for __tmp_varname in ${!__b3bp_tmp_*}; do
  unset -v "${__tmp_varname}"
done

unset -v __tmp_varname








##############################################################################
### Signal trapping and backtracing
##############################################################################
function __b3bp_cleanup_before_exit () {
  log_info "Cleaning up. Done"
}
trap __b3bp_cleanup_before_exit EXIT

# requires `set -o errtrace`
__b3bp_err_report() {
    local error_code=${?}
    log_error "Error in ${__file} in function ${1} on line ${2}"
    exit ${error_code}
}
# Uncomment the following line for always providing an error backtrace
# trap '__b3bp_err_report "${FUNCNAME:-.}" ${LINENO}' ERR




##############################################################################
### Command-line argument switches (like -d for debugmode, -h for showing helppage)
##############################################################################

# debug mode
if [[ "${arg_d:?}" = "1" ]]; then
  set -o xtrace
  PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  LOG_LEVEL="7"
  # Enable error backtracing
  trap '__b3bp_err_report "${FUNCNAME:-.}" ${LINENO}' ERR
fi

# verbose mode
if [[ "${arg_v:?}" = "1" ]]; then
  set -o verbose
fi

# no color mode
if [[ "${arg_n:?}" = "1" ]]; then
  NO_COLOR="true"
fi

# help mode
if [[ "${arg_h:?}" = "1" ]]; then
  # Help exists with code 1
  helptxt
fi

##############################################################################
### Feedback about run config
##############################################################################

log_debug "__file: ${__file}"
log_debug "__dir: ${__dir}"
log_debug "__base: ${__base}"
log_debug "OSTYPE: ${OSTYPE}"

log_debug "arg_d: ${arg_d}"
log_debug "arg_v: ${arg_v}"
log_debug "arg_h: ${arg_h}"

# shellcheck disable=SC2015
if [[ -n "${arg_i:-}" ]] && declare -p arg_i 2> /dev/null | grep -q '^declare \-a'; then
  log_debug "arg_i:"
  for input_file in "${arg_i[@]}"; do
    log_debug " - ${input_file}"
  done
elif [[ -n "${arg_i:-}" ]]; then
  log_debug "arg_i: ${arg_i}"
else
  log_debug "arg_i: 0"
fi

# shellcheck disable=SC2015
if [[ -n "${arg_x:-}" ]] && declare -p arg_x 2> /dev/null | grep -q '^declare \-a'; then
  log_debug "arg_x: ${#arg_x[@]}"
elif [[ -n "${arg_x:-}" ]]; then
  log_debug "arg_x: ${arg_x}"
else
  log_debug "arg_x: 0"
fi
