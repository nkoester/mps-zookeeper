#/usr/bin/env bash

MPS_BASE_PATH=${MPS_BASE_PATH:-/vol/mps/}
AVAILABLE_MPS_VERSIONS=""

__get_MPS_versions()
{
    # if the MPS base path does not exist we will provide default completion for this arguemnt
    if [[ ! -d "${MPS_BASE_PATH}" ]]; then
        AVAILABLE_MPS_VERSIONS="-1"
    else
        AVAILABLE_MPS_VERSIONS=$(find /${MPS_BASE_PATH}/MPS-* -maxdepth 1 -type d -prune -printf '%f ' 2>/dev/null  | sed 's/MPS-//g') || true
    fi
}

__mpsZooKeeper_completions()
{
    # Assigned variable by _init_completion (bash internal)
    #   cur    Current argument
    #   prev   Previous argument
    #   words  Argument array
    #   cword  Argument array size
    local cur prev words cword
    _init_completion || return

    # Flag for checking if arguments is used or not.
    # mps settings
    local used_mps_version=0
    local used_mps_base_path=0

    # configuration settings
    local used_cfg_folder=0
    local used_identifier=0

    # debug settings
    local used_debug_enable=0
    local used_debug_enable_suspend=0
    local used_debug_port=0

    local used_plugins=0
    local used_darktheme=0
    local used_run=0

    # generic settings
    local used_help=0
    local used_debug=0
    local used_no_color=0
    local used_verbose=0

    # local used_=0
    # local used_=0
    # local used_=0

    # Check used argument.
    local word
    for ((index=0; index <= ${#words[@]}; index++)); do
        word=${words[index]}
        case ${word} in
            # mps settings
            -m|--mps-version)
                used_mps_version=1
                ;;
            -b|--mps-base-path)
                used_mps_base_path=1
                MPS_BASE_PATH=${words[index+1]}
                ;;
            # configuration settings
            -f|--cfg-folder) used_cfg_folder=1;;
            -i|--identifier) used_identifier=1;;
            # debug settings
            -x|--debug-enable) used_debug_enable=1;;
            -s|--debug-enable-suspend) used_debug_enable_suspend=1;;
            -p|--debug-port) used_debug_port=1;;
            # misc
            -t|--darktheme) used_darktheme=1;;
            -l|--plugins) used_plugins=1;;
            # run
            -r|--run) used_run=1;;
            # generics
            -h|--help) used_help=1 ;;
            -d|--debug) used_debug=1 ;;
            -n|--no-color) used_no_color=1 ;;
            -v|--verbose) used_verbose=1 ;;
        esac
    done


    # Create argument list with checking previous argument.
    local args=""
    case "${prev}" in
        -m | --mps-version)
            __get_MPS_versions
            args=${AVAILABLE_MPS_VERSIONS}
            ;;
        -b | --mps-base-path)
            args="-1"
            ;;
        -l | --plugins)
            args="plugins"
            ;;
        *)
            # mps settings
            [ ${used_mps_version} -eq 0 ] && args="${args} --mps-version"
            [ ${used_mps_base_path} -eq 0 ] && args="${args} --mps-base-path"
            # config settings
            [ ${used_cfg_folder} -eq 0 ] && args="${args} --cfg-folder"
            [ ${used_identifier} -eq 0 ] && args="${args} --identifier"
            # debug settings
            [ ${used_debug_enable} -eq 0 ] && args="${args} --debug-enable"
            [ ${used_debug_enable_suspend} -eq 0 ] && args="${args} --debug-enable-suspend"
            [ ${used_debug_port} -eq 0 ] && args="${args} --debug-port"
            #
            [ ${used_darktheme} -eq 0 ] && args="${args} --darktheme"
            [ ${used_plugins} -eq 0 ] && args="${args} --plugins"
            [ ${used_run} -eq 0 ] && args="${args} --run"
            # generics
            [ ${used_help} -eq 0 ] && args="${args} --help"
            [ ${used_debug} -eq 0 ] && args="${args} --debug"
            [ ${used_no_color} -eq 0 ] && args="${args} --no-color"
            [ ${used_verbose} -eq 0 ] && args="${args} --verbose"
            ;;
    esac
    # echo ""
    # echo "args: ${args}"
    # echo "ccompgen -W '${args}' ${cur}"
    # echo ""
    # if [[ "${COMP_CWORD}" == "-1" ]]; then
    # fi

    # we do normal completion, alternatively we complete with our own args
    if [[ "${args}" == "-1" ]] || [[ "${args}" == "plugins" ]]; then
        # see https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files
        COMPREPLY=($(compgen -S"/" -d "${cur}"))
        # old way with no tailing slashes
        # COMPREPLY=($(compgen -o default -- "${cur}"))
    else
        COMPREPLY=($(compgen -W "${args}" -- "${cur}"))
    fi
    # COMPREPLY=($(compgen -W "${args}" "${COMP_WORDS[1]}"))
    # COMPREPLY=(${args})
}

complete -o nospace -F __mpsZooKeeper_completions mpsZooKeeper.sh

