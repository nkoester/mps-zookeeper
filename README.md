# mpsZooKeeper.sh


## Short description

Helper script for Jetbrains MPS to generate an isolated configuration prefix for isolated MPS instances


## Detailed description

### Installation

This script can be installed via `cmake`. To install to `${HOME}/local` simply call

```
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${HOME}/local
make install
```

(Note: Alternatively you can copy `mpsZooKeeper.sh` and `mpsZooKeeper-helper.sh` into your `$PATH`. Also copy `completions-mpsZooKeeper.sh` into your completion folder.)


### `$PATH` and bash completion

In order to use the tool from your shell, add `$YOUR-PREFIX/bin` to your `$PATH` variable. Further, completions are provided and installed to `$YOUR-PREFIX/bashcompletions`.

Assuming you installed to `${HOME}/local/`, add the follwing to your `.bashrc`:

```
# add local prefix to path
export PATH=${HOME}/local/bin:${PATH}

# enable bash completion in interactive shells
if ! shopt -oq posix; then
    # load personal completions
    if [[ -d ${HOME}/local/bashcompletions ]];then
        source ${HOME}/local/bashcompletions/*
    fi
fi

```

## Tool help

Help using /home/nkoester/local/bin/mpsZooKeeper.sh

    SCRIPT -m mpsVersion [-b mpsInstallPath] [-f prefixPath] [-i identifier] [-x] [-s] [-p port]


  -m --mps-version [arg]      The MPS version to launch.
  -b --mps-base-path [arg]    The path where MPS versions reside. Default="/vol/mps"

  -f --cfg-folder [arg]       The prefix path to which the configuration is written. Default="/tmp"
  -i --identifier [arg]       An identifying string put in the configuration folder name. Will use the current date and time if unset.

  -x --debug-enable           Enables debugging of MPS instance via vmoptions.
  -s --debug-enable-suspend   Sets 'suspend=y' in MPS vmoptions.
  -p --debug-port [arg]       Changes the debug port in MPS vmoptions.  Default="51337"

  -l --plugins [arg]          Copies iets3.opensource+mbeddr into the prefix plugin folder from /vol/mps/plugins/[arg]. Default="none"
  -r --run                    Runs the created configuration using tmux.

  -h --help                   This page
  -d --debug                  Enables debug mode for this script.
  -n --no-color               Disable color output
  -v --verbose                Enable verbose mode, print script as it is executed

   This tool creates MPS configurations and consequently allows you to run multiple instances of various MPS versions without a shared module (i.e. language/solution) pool.

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
