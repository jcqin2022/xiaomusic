#!/bin/bash
# /etc/init.d/xiaomusic

#APP
HOME_BASE="/home/alic"
LOG_FILE="$HOME_BASE/log.txt"
APP_PATH="$HOME_BASE/miservice/dist"
APP_BIN="xiaomusic"
SCRIPT_NAME="xiaomusic_init.sh"
INIT_DIR="/etc/init.d"

case "$1" in
    start)
        #start xiaomusic
        pushd $APP_PATH
        nohup "./$APP_BIN" > /dev/null 2>&1 &
        echo -e "`date`:started xiaomusic:8090" >> $LOG_FILE
        popd
        ;;
    stop)
        pkill -f "$APP_BIN"
        ;;
    restart)
        pkill -f "$APP_BIN"
        sleep 1
        $FILEBROWSER_BIN -c $CONFIG_FILE -d $DB_FILE &
        ;;
    status)
        pgrep -f "$APP_BIN" > /dev/null
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