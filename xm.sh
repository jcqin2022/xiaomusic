#!/bin/bash

# ==use venv in ubuntu (Note3 22.04, Azure 18.04, VM 20.04)
# 1. sudo apt-get install python3-pip
# 2. sudo pip3 install virtualenv 
# 3. virtualenv mypy
# 4. source mypy/bin/activate
# 5. pip install pyinstaller psutil py-cpuinfo beautifulsoup4 requests
# 6. deactivate
# 7. change python version - pyenv
#     a. curl https://pyenv.run | bash
#     b. update bash
#         echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
#         echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
#         echo 'eval "$(pyenv init -)"' >> ~/.bashrc
#     c. install and swtich: pyenv install -l
#         pyenv install 3.10
#         pyenv global 3.10
# https://medium.com/@AgnesMbiti/creating-a-python-virtual-environment-on-ubuntu-22-04-5efc173ce655

# == python3 for ubuntu - Beikeyun, ubuntu 24.04
# a. sudo apt-get install python3.10/12-venv
# b. sudo apt install python3-pip -y
# c. Python3 --version or Pip3 --version
# d. python3 -m venv .venv (project folder)
# e. source .venv/bin/activate
# f. pip install pyinstaller pdm
# g. deactivate
# f. sudo apt-get install gcc python3-dev

# == pdm
# pdm init
# pdm install
# pdm add openai

### BEGIN INFO
# Old: support Samsung Note3, Azure VM, VMWare VM.
# 11/04/2024: support ubuntu 20.04 with steps (install, src, env, build, run). Note: before debuging, web login is necessary.
### END INFO

#APP
HOME_BASE="/home/alic"
NAME="xiaomusic"
LOG_FILE="$HOME_BASE/log.txt"
SRC_PATH="$HOME_BASE/$NAME"
APP_PATH="$HOME_BASE/$NAME/dist"
APP_BIN="xiaomusic"
ENV_PATH="$SRC_PATH/.env"
DEFAULT_VER="3.10.15"
VENV_NAME=".env"


function apply_python() {
    if [ -z "$1" ]; then
        version=$DEFAULT_VER
    else
        version="$1"
    fi
    echo "apply python version to $version"
    sudo apt install -y zlib1g zlib1g-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev
    pyenv install $version
    pyenv global $version
}

case "$1" in
    install)
        echo "install dependencies for $NAME"
        echo "installing pyenv:"
        curl https://pyenv.run | bash
        if [ $? -eq 0 ]; then
            echo "update .bashrc:"
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
            echo 'eval "$(pyenv init -)"' >> ~/.bashrc
            source ~/.bashrc
        else
            echo "pyenv installation failed"
            exit 1
        fi
        apply_python
        echo "installing pip and env:"
        sudo apt-get install -y python3-pip
        sudo pip3 install virtualenv
        ;;
    python)
        apply_python $2
        ;;
    env)
        echo "prepare env for $NAME"
        if [ -z "$2" ]; then
            version=$DEFAULT_VER
        else
            version="$2"
        fi
        echo "python env $version"
        virtualenv -p python$version $ENV_PATH
        source $ENV_PATH/bin/activate
        pip install pyinstaller psutil py-cpuinfo beautifulsoup4 requests pdm
        pdm install
        deactivate
        ;;
    src)
        echo "clone src for $NAME"
        # jcqin2022, j3
        echo "git clone $NAME"
        git clone git@github.com:jcqin2022/xiaomusic.git
        ;;
    build)
        echo "build src for $NAME"
        if [ -n "$2" ]; then
            venv_name="$2"
        else
            venv_name=$VENV_NAME
        fi
        activate_path=$SRC_PATH/$venv_name/bin/activate
        if [ ! -f "$activate_path" ]; then
            echo "Error: $activate_path does not exist."
            echo ".env or .venv?"
            exit 1
        fi
        source $activate_path
        pdm install
        deactivate
        ;;
    installer)
        echo "create installer for $NAME"
        source $ENV_PATH/bin/activate
        pyinstaller $SRC_PATH/$NAME.spec
        deactivate
        ;;
    run)
        echo "run $NAME"
        $APP_PATH/$APP_BIN
        ;;
    *)
        echo "Usage: $0 {install|python|env|src|build|run|installer}"
        exit 1
        ;;
esac