#!/usr/bin/env bash
#
#
# author: Norman Köster
# date: 23.09.2021
# description: Generates localized MPS configurations and corresponding scripts
# version: 1.0
#


# some defaults
LOG_LEVEL=${LOG_LEVEL:-6}

# prefix information
read -r -d '' MPS_CONFIG_BASE_PATH <<-'EOF' || true # exits non-zero when EOF encountered
#!/usr/bin/env bash
#
#
# author: mpsZooKeeper.sh
# date: GENERATION_DATE
# description: This file automatically generated. Do not modify.
#
#
export CONFIG_BASE_PATH="PREFIX/SUFFIX"
export CONFIG_MPS_PATH="MPS_BIN_PATH"
export CONFIG_TMUX_SESSION_NAME="SUFFIX"
EOF

# idea properties
read -r -d '' MPS_LOCALIZED_IDEA_PROPERTIES <<-'EOF' || true # exits non-zero when EOF encountered
#
#
# author: mpsZooKeeper.sh
# date: GENERATION_DATE
# description: This file automatically generated. Do not modify.
#
#
idea.config.path=PREFIX/SUFFIX/config
idea.system.path=PREFIX/SUFFIX/system
idea.scratch.path=PREFIX/SUFFIX/scratch
idea.plugins.path=PREFIX/SUFFIX/plugins
idea.log.path=PREFIX/SUFFIX/log

idea.max.intellisense.filesize=100000
idea.jars.nocopy=false
idea.no.launcher=false
idea.xdebug.key=-Xdebug
idea.cycle.buffer.size=1024
sun.java2d.noddraw=true
sun.java2d.d3d=false
sun.java2d.pmoffscreen=false
EOF

# light mode by default (tested for MPS 2021.1+)
read -r -d '' MPS_COLOR_SCHEME_LAF <<-'EOF' || true # exits non-zero when EOF encountered
<application>
  <component name="LafManager" autodetect="false">
    <laf class-name="com.intellij.ide.ui.laf.IntelliJLaf" themeId="JetBrainsLightTheme" />
  </component>
</application>
EOF

# light mode by default (tested for MPS 2021.1+)
read -r -d '' MPS_COLOR_SCHEME <<-'EOF' || true # exits non-zero when EOF encountered
<application>
  <component name="EditorColorsManagerImpl">
    <global_color_scheme name="IntelliJ Light" />
  </component>
</application>
EOF

# vmoptions
read -r -d '' MPS_CUSTOM_VMOPTIONS <<-'EOF' || true # exits non-zero when EOF encountered
#
#
# author: mpsZooKeeper.sh
# date: GENERATION_DATE
# description: This file automatically generated. Do not modify.
#
#
-Xmx2048m
-XX:ReservedCodeCacheSize=240m
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-XX:CICompilerCount=2
-Dsun.io.useCanonPrefixCache=false
-Djava.net.preferIPv4Stack=true
-Djdk.http.auth.tunneling.disabledSchemes=
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-Djdk.attach.allowAttachSelf
-Dkotlinx.coroutines.debug=off
-Djdk.module.illegalAccess.silent=true
-Dawt.useSystemAAFontSettings=lcd
-Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine
-Dsun.tools.attach.tmp.only=true
-client
-Xss1024k
-XX:NewSize=256m
-Dfile.encoding=UTF-8
-Dapple.awt.graphics.UseQuartz=true
-Dide.mac.message.dialogs.as.sheets=false
-Dintellij.config.imported.in.current.session=true
-Didea.invalidate.caches.invalidates.vfs=true
-Dperformance.watcher.freeze.report=false
-Didea.log.config.file=log.xml
-Didea.indices.psi.dependent.default=false
-Didea.initially.ask.config=true
DEBUGENABLE-agentlib:jdwp=transport=dt_socket,server=y,suspend=SUSPEND,address=DEBUGPORT
EOF

# localized launch script
read -r -d '' MPS_LOCALIZED_STARTUP_SCRIPT <<-'EOF' || true # exits non-zero when EOF encountered
#!/usr/bin/env bash
#
#
# author: mpsZooKeeper.sh
# date: GENERATION_DATE
# description: This file automatically generated. Do not modify.
#
#
# usage: [startLocalizedMPS.sh] [MODE]
#
# Supported modes are:
#              -  If unset or unknown start MPS directly in this terminal.
#     tmuxD    -  Start MPS in a detached tmux session.
#     tmuxA    -  Start MPS in a detached tmux session and attach this terminal directly to it.
#     tmuxLD   -  Opens a new terminal with a 'tail -F' on the idea.log and MPS
#                 itself will be started in a detached tmux session.
#     tmuxLA   -  Opens a new terminal with a 'tail -F' on the idea.log and MPS
#                 itself will be started in a detached tmux session and attach this terminal to it.

# go to location of this script
CURRENT_BASE_PATH=$(dirname "$0")
cd "${CURRENT_BASE_PATH}"

# read our environment
# gives us
#    $CONFIG_BASE_PATH
#    $CONFIG_MPS_PATH
#    $CONFIG_TMUX_SESSION_NAME
source prefixEnvironment.env

function testPaths {
    echo -n "Checking path 'tegrity ... "

    # We could double check via this. But thats would be overkill. Might be helpful for someone.
    # IDEA_BASE_PATH=$(head -n 1 idea.properties | cut -d "=" -f2 | awk -F'/config' '{print $1}')

    if [[ "${CONFIG_BASE_PATH}" != "${CURRENT_BASE_PATH}" ]] && [[ "${CURRENT_BASE_PATH}" != "." ]]; then
        echo "fail."
        echo "The base path seems to be broken"
        echo "    configured path:         ${CONFIG_BASE_PATH}"
        echo "    current actual path:     ${CURRENT_BASE_PATH}"
        echo ""
        read -p "Automatically fix it? [yN] " ANSWER
        if [[ "${ANSWER}" == "y" ]] || [[ "${ANSWER}" == "Y" ]]
        then
            echo "Replacing all wrong paths in 'idea.properties'"
            sed -i 's~'"${CONFIG_BASE_PATH}"'~'"${CURRENT_BASE_PATH}"'~g' idea.properties

            echo "Replacing all wrong paths in 'prefixEnvironment.env'"
            sed -i 's~'"${CONFIG_BASE_PATH}"'~'"${CURRENT_BASE_PATH}"'~g' prefixEnvironment.env

            # reload to get the new paths
            source prefixEnvironment.env
        else
            echo "Will not update paths."
            echo ""
            echo "WARNING: Starting MPS will most likely fail. The configured path ${CURRENT_BASE_PATH} does not exist anymore. MPS will fall back to the default configuration path."
            read -n 1 -s -r -p "Press any key to continue"
        fi
    else
        echo "ok."
    fi
}

function tmuxd {
    echo "Spawning tmux session with name '${CONFIG_TMUX_SESSION_NAME}'"
    tmux new-session -d -s "$CONFIG_TMUX_SESSION_NAME" "MPS_PROPERTIES=$CONFIG_BASE_PATH/idea.properties IDEA_VM_OPTIONS=$CONFIG_BASE_PATH/mps64.vmoptions  $CONFIG_MPS_PATH/mps.sh"
}

function tmuxa {
    tmux list-sessions
    tmux attach-session -t $CONFIG_TMUX_SESSION_NAME
}

function followLog {
    touch $CONFIG_BASE_PATH/log/idea.log
    $TERMINAL --title="MPS-LOG" -e tail -F $CONFIG_BASE_PATH/log/idea.log&
}

# run path test
testPaths

# start in the chosen mode
if [[ "$1" == "tmuxD" ]]; then
    tmuxd
elif [[ "$1" == "tmuxA" ]]; then
    tmuxd
    tmuxa
elif [[ "$1" == "tmuxLD" ]]; then
    followLog
    tmuxd
elif [[ "$1" == "tmuxLA" ]]; then
    followLog
    tmuxd
    tmuxa
else
    echo " (!)"
    echo " --> No/unknown argument ('${1}') given - startig MPS directly in this terminal"
    echo "     Alternative arguments are: tmuxD, tmuxA, tmuxLD, and tmuxLA"
    echo " (!)"
    MPS_PROPERTIES=$CONFIG_BASE_PATH/idea.properties IDEA_VM_OPTIONS=$CONFIG_BASE_PATH/mps64.vmoptions  $CONFIG_MPS_PATH/mps.sh
fi
EOF

# script arguments
read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
    -m --mps-version [arg]      The MPS version to launch.
    -b --mps-base-path [arg]    The path where MPS versions reside. Default="/vol/mps"

    -f --cfg-folder [arg]       The prefix path to which the configuration is written. Default="/tmp"
    -i --identifier [arg]       An identifying string put in the configuration folder name. Will use the current date and time if unset.

    -x --debug-enable           Enables debugging of MPS instance via vmoptions.
    -s --debug-enable-suspend   Sets 'suspend=y' in MPS vmoptions.
    -p --debug-port [arg]       Changes the debug port in MPS vmoptions.  Default="51337"

    -l --plugins [arg]          Copies all sub folders from the given path into the plugin folder of the new prefix. Default="none"
    -r --run                    Runs the created configuration using tmux.
    -t --darktheme              Use default dark theme (works for MPS versions > 2019.x).

    -h --help                   This page.
    -d --debug                  Enables debug mode for this script.
    -n --no-color               Disable color output.
    -v --verbose                Enable verbose mode, print script as it is executed
EOF

read -r -d '' __usage_minimal <<-'EOF' || true # exits non-zero when EOF encountered
Usage: mpsZooKeeper.sh -m mpsVersion [-b mpsInstallPath] [-f prefixPath] [-i identifier] [-x] [-s] [-p port]
EOF

read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
Creates MPS configurations and consequently allows you to run multiple instances of various MPS versions without a shared module (i.e. language/solution) pool.

  The mpsZooKeeper.sh writes a self-contained minimal configuration. This configuration is structured similarly to:

      .mpsconfig/
    └──   MPS-2021.1.3-linux-210926-135815-UTC/
        ├──   config/
        │   └──   options/
        │       └──   laf.xml
        ├──   log/
        ├──   plugins/
        ├──   system/
        ├──   idea.properties
        ├──   mps64.vmoptions
        ├──   prefixEnvironment.env
        └──   startLocalizedMPS.sh

  The created start script allows you to run MPS with this configuration folder. You can place such a configuration within your project root folder for project specific independent configurations.

  In case you put your configuration in your git root, it is advisable to add the alias 'cleanxdf = clean -xdf -e .mpsconfig' to your global git config.

  WARNING: Do not have any '--' within paths or identifiers - it will break MPS.
EOF

# source the scripts doing the nice meta
source mpsZooKeeper-helper.sh

log_info "Starting mpsZooKeeper ..."

ARG_MPS_TARGET_VERSION=${arg_m}
ARG_MPS_BASE_PATH=${arg_b}
CURRENT_DATE=$(date)
ARG_IDENTIFIER=${arg_i:-$(date -u +"%y%m%d-%H%M%S-UTC")}
# MPS_CONFIG_PREFIX="/tmp/.mpsconfig/${MPS_VERSION}-$(uuidgen)"
ARG_PLUGIN_SOURCE=${arg_l}

if [[ ! ${arg_l} == "none" ]] && [[ ! -d "${ARG_PLUGIN_SOURCE}" ]]; then
    log_error "Cannot find plugins at path ${ARG_PLUGIN_SOURCE}! Aborting."
    exit 1
fi

MPS_VERSION="MPS-${ARG_MPS_TARGET_VERSION}"
MPS_BIN_PATH="${ARG_MPS_BASE_PATH}//MPS-${ARG_MPS_TARGET_VERSION}/bin"

MPS_CONFIG_PREFIX=$(realpath "${arg_f}/.mpsconfig/")
MPS_CONFIG_SUFFIX="${MPS_VERSION}-${ARG_IDENTIFIER}"
MPS_CONFIG_SUFFIX=${MPS_CONFIG_SUFFIX//./-}
MPS_CONFIG_FULL="${MPS_CONFIG_PREFIX}/${MPS_CONFIG_SUFFIX}"

# replace values in the idea and vmoption files
MPS_LOCALIZED_IDEA_PROPERTIES=${MPS_LOCALIZED_IDEA_PROPERTIES//GENERATION_DATE/${CURRENT_DATE}}
MPS_LOCALIZED_IDEA_PROPERTIES=${MPS_LOCALIZED_IDEA_PROPERTIES//PREFIX/${MPS_CONFIG_PREFIX}}
MPS_LOCALIZED_IDEA_PROPERTIES=${MPS_LOCALIZED_IDEA_PROPERTIES//SUFFIX/${MPS_CONFIG_SUFFIX}}

# set defaults
MPS_CUSTOM_VMOPTIONS=${MPS_CUSTOM_VMOPTIONS//GENERATION_DATE/${CURRENT_DATE}}
MPS_CUSTOM_VMOPTIONS=${MPS_CUSTOM_VMOPTIONS//DEBUGPORT/${arg_p}}

# set paths in environmet
MPS_CONFIG_BASE_PATH=${MPS_CONFIG_BASE_PATH//GENERATION_DATE/${CURRENT_DATE}}
MPS_CONFIG_BASE_PATH=${MPS_CONFIG_BASE_PATH//PREFIX/${MPS_CONFIG_PREFIX}}
MPS_CONFIG_BASE_PATH=${MPS_CONFIG_BASE_PATH//SUFFIX/${MPS_CONFIG_SUFFIX}}
MPS_CONFIG_BASE_PATH=${MPS_CONFIG_BASE_PATH//MPS_BIN_PATH/${MPS_BIN_PATH}}

# set date in start script
MPS_LOCALIZED_STARTUP_SCRIPT=${MPS_LOCALIZED_STARTUP_SCRIPT//GENERATION_DATE/${CURRENT_DATE}}

#   ____  ___
#  / ___|/ _ \
# | |  _| | | |
# | |_| | |_| |
#  \____|\___/
#

# Create a MPS configuration
log_info "Checking conditions to create prefix ..."

# get available MPS versions
AVAILABLE_MPS_VERSIONS=$(find /${ARG_MPS_BASE_PATH}/MPS-* -maxdepth 1 -type d -prune -printf '%f ' 2>/dev/null  | sed 's/MPS-//g') || true
if [[ -z "${AVAILABLE_MPS_VERSIONS}" ]]; then
    log_error "Unable to find any MPS versions at '${ARG_MPS_BASE_PATH}'. Set -b / --mps-base-path?"
    exit 1
fi

# ensure the required arguments are set with custom message
# [[ "${arg_m:-}" ]]     || help      "Setting an MPS version with -m or --mps is required!"
if [[ -z "${arg_m:-}" ]];then
    log_error "Setting an MPS version with -m or --mps-version is required!"
    log_notice "Available versions are"
    log_notice "${AVAILABLE_MPS_VERSIONS}"
    exit 1
fi

# check that MPS exists
if [[ ! -d "${MPS_BIN_PATH}" ]]; then
    log_error "Unable to find MPS version 'MPS-${ARG_MPS_TARGET_VERSION}' in '${ARG_MPS_BASE_PATH}'"
    log_notice "Available versions are"
    log_notice "${AVAILABLE_MPS_VERSIONS}"
    exit 1
fi

# ensure we do not overwrite existing stuff
if [[ -d $MPS_CONFIG_FULL ]]; then
    log_warning "Configuration prefix folder already exists: ${MPS_CONFIG_FULL}"
    read -p "Overwrite this existing config? [yN] " ANSWER
    if [[ "${ANSWER}" == "y" ]] || [[ "${ANSWER}" == "Y" ]]
    then
        # good luck
        log_info "Forcing write to folder."
    else
        log_error "Aborting."
        exit 1
    fi
fi

# add debugging
if [[ "${arg_x:-}" == 1 ]]; then
    log_info "Debuging enabled on port ${arg_p}"
    MPS_CUSTOM_VMOPTIONS=${MPS_CUSTOM_VMOPTIONS/DEBUGENABLE/}
else
    MPS_CUSTOM_VMOPTIONS=${MPS_CUSTOM_VMOPTIONS/DEBUGENABLE/#}
fi

# debugging suspend
if [[ "${arg_s:-}" == 1 ]]; then
    log_info "Debuging suspend enabled"
    MPS_CUSTOM_VMOPTIONS=${MPS_CUSTOM_VMOPTIONS/SUSPEND/y}
else
    MPS_CUSTOM_VMOPTIONS=${MPS_CUSTOM_VMOPTIONS//SUSPEND/n}
fi


log_info "Writing configuration to ${MPS_CONFIG_FULL}"

# create folders
mkdir -p ${MPS_CONFIG_FULL}/{'plugins','config/options','system','log'}

# write idea.properties and vmoption file
echo "${MPS_LOCALIZED_IDEA_PROPERTIES}" > ${MPS_CONFIG_FULL}/idea.properties

# write color scheme xml
if [[ "${arg_t:-}" == 1 ]]; then
    log_info "Will not overwrite dark mode with light theme"
else
    echo "${MPS_COLOR_SCHEME_LAF}" > ${MPS_CONFIG_FULL}/config/options/laf.xml
    echo "${MPS_COLOR_SCHEME}" > ${MPS_CONFIG_FULL}/config/options/colors.scheme.xml
fi

# write mps64.vmoptions
echo "${MPS_CUSTOM_VMOPTIONS}" > ${MPS_CONFIG_FULL}/mps64.vmoptions
# write base path environment file
echo "${MPS_CONFIG_BASE_PATH}" > ${MPS_CONFIG_FULL}/prefixEnvironment.env
# write startup script
echo "${MPS_LOCALIZED_STARTUP_SCRIPT}" > ${MPS_CONFIG_FULL}/startLocalizedMPS.sh
# make script executable
chmod +x ${MPS_CONFIG_FULL}/startLocalizedMPS.sh

# install plugins
if [[ ! ${arg_l} == "none" ]] && [[ -d "${ARG_PLUGIN_SOURCE}" ]]; then
  log_info "Adding $(ls -d ${ARG_PLUGIN_SOURCE}/* | wc -l | cut -f 1) plugins to the mix ..."
    cp -r ${ARG_PLUGIN_SOURCE}/* ${MPS_CONFIG_FULL}/plugins/
fi


log_info "Configuration is all set :>"
log_info "--------------------"
log_notice "Environment file: ${MPS_CONFIG_FULL}/prefixEnvironment.env"
log_notice "Plugin path:      ${MPS_CONFIG_FULL}/config/plugins/"
log_notice "idea.properties:  ${MPS_CONFIG_FULL}/idea.properties"
log_notice "mps64.vmoptions:  ${MPS_CONFIG_FULL}/mps64.vmoptions"
log_notice "Startup script:   ${MPS_CONFIG_FULL}/startLocalizedMPS.sh"
log_notice "                  The startup script can be started with different arguments for different modes:"
log_notice "                               -  If unset or unknown start MPS directly in this terminal."
log_notice "                      tmuxD    -  Start MPS in a detached tmux session."
log_notice "                      tmuxA    -  Start MPS in a detached tmux session and attach this terminal directly to it."
log_notice "                      tmuxLD   -  Opens a new terminal with a 'tail -F' on the idea.log and MPS itself will be started in a detached tmux session."
log_notice "                      tmuxLA   -  Opens a new terminal with a 'tail -F' on the idea.log and MPS itself will be started in a detached tmux session and attach this terminal to it."
log_info "--------------------"

# run the script if needed
if [[ "${arg_r:-}" == 1 ]]; then
    log_info "Will now launch MPS with the new configuration"
    eval "${MPS_CONFIG_FULL}/startLocalizedMPS.sh tmuxlog"
fi


