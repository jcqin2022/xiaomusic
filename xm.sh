#!/bin/bash

# ==use venv in ubuntu 22.04 (Note3, Azure)
# 1. sudo apt-get install python3-pip
# 2. sudo pip3 install virtualenv 
# 3. virtualenv mypyls
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

# == python3 for ubuntu - Beikeyun
# a. sudo apt-get install python3.10-venv
# b. sudo apt install python3-pip -y
# c. Python3 --version or Pip3 --version
# d. sudo apt-get install gcc python3-dev

#APP
HOME_BASE="/home/alic"
LOG_FILE="$HOME_BASE/log.txt"
SRC_PATH="$HOME_BASE/miservice"
APP_PATH="$HOME_BASE/miservice/dist"
APP_BIN="xiaomusic"
SCRIPT_NAME="xiaomusic_init.sh"
INIT_DIR="/etc/init.d"

case "$1" in
    env)
        #start xiaomusic
        pushd "$APP_PATH"
        nohup "./$APP_BIN" > /dev/null 2>&1 &
        echo -e "`date`:started xiaomusic:8090" >> $LOG_FILE
        popd
        ;;
    stop)
        pkill -f "$APP_BIN$"
        ;;
    restart)
        pkill -f "$APP_BIN$"
        sleep 1
        pushd "$APP_PATH"
        nohup "./$APP_BIN" > /dev/null 2>&1 &
        echo -e "`date`:started xiaomusic:8090" >> $LOG_FILE
        popd
        ;;
    status)
        pgrep -laf "$APP_BIN$"
        if [ $? -eq 0 ]; then
            echo -e "$APP_BIN is running."
        else
            echo -e "$APP_BIN is not running."
        fi
        ;;
    reload)
        pkill -SIGHUP -f "$APP_BIN"
        ;;
    install)
        sudo cp -f "./$SCRIPT_NAME" "$INIT_DIR/$APP_BIN"
        ls -al "$INIT_DIR"|grep "$APP_BIN"
        ;;
    *)
        echo "Usage: $0 {install|start|stop|restart|status|reload}"
        exit 1
        ;;
esac

exit 0
