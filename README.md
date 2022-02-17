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

Assuming you installed to `${HOME}/local/`, add the following to your `.bashrc`:

``` bash
# add local prefix to path
export PATH=${HOME}/local/bin:${PATH}

# enable bash completion in interactive shells
if ! shopt -oq posix; then
    # load personal completions
    if [[ -d ${HOME}/local/bashcompletions ]];then
        for f in ${HOME}/local/bashcompletions/*; do
            source ${f}
        done
    fi
fi
```

### Usage examples

Create a temporary MPS configuration in /tmp and run it.
``` bash
$ mpsZooKeeper.sh --mps-version 2020.3.5-linux --run
```

Create a temporary MPS configuration in /tmp, copy some existing plugins into it and run it.
``` bash
$ mpsZooKeeper.sh --mps-version 2020.3.5-linux --plugins /vol/mps/plugins/MPS-2020.3.4/myOwnPlugin/ --plugins /vol/mps/plugins/MPS-2020.3.4/iets3-2020.3.5116.6bd9f15/ --run
```

Create a temporary MPS configuration in /tmp, with custom debugging settings.
``` bash
$ mpsZooKeeper.sh --mps-version 2020.3.5-linux --debug-enable --debug-enable-suspend --debug-port 20203
```

Run a generated script and open the log in a new window
``` bash
/tmp/.mpsconfig/MPS-2020-3-5-linux-220217-152625-UTC/startLocalizedMPS.sh tmuxLA
```


### MPS base path (`$MPS_BASE_PATH`)

To have completions for your installed MPS versions put your MPS installations into the current default at `/vol/mps/MPS-{YOUR-VERSIONS-HERE}`. For example:

``` bash
/vol/mps
├── MPS-2019.1.6-linux
├── MPS-2019.3.7-linux
├── MPS-2020.3.5-linux
├── MPS-2020.3.6-linux
├── MPS-2021.1.3-linux
├── MPS-2021.2.2-linux
└── MPS-2021.2.3-linux
```

Alternatively, you can change the default path where your MPS versions lie by setting the environment variable `$MPS_BASE_PATH` before sourcing the completion file.


### Layout of generated configuration

The mpsZooKeeper.sh writes a self-contained minimal configuration. This configuration is structured similarly to:

``` bash
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
```



## Full help text

``` bash
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
```
