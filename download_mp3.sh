#!/bin/bash

### BEGIN INFO
# Goal: download video, mp3 from bilibili or yourtube.
# 11/19/2024: init version.
### END INFO

#APP
HOME_BASE="/home/alic"
NAME="xiaomusic"
LOG_FILE="$HOME_BASE/log.txt"
SRC_PATH="$HOME_BASE/$NAME"
VENV_NAME=".env"
ENV_PATH="$SRC_PATH/$VENV_NAME"
DEFAULT_VER="3.10.15"

DEBUG_LOG="debug.log"
DEBUG_DAEMON="strace -f -t -o $DEBUG_LOG -e trace=file"

SEARCH_PREFIX="bilisearch:"
EXTRACT_AUDIO="-x"
AUDIO_FORMAT="--audio-format"
DOWNLOAD_PATH="--paths"
DOWNLOAD_PATH_VALUE="./music/download"
OUTPUT_FILE="-o"
FFMPEG_PATH="--ffmpeg-location"
FFMPEG_PATH_VALUE="./ffmpeg/bin/"
PLAY_LIST="--no-playlist"
APP_BIN="yt-dlp"
# APP_ARGS="$EXTRACT_AUDIO $SEARCH_PREFIX $AUDIO_FORMAT $DOWNLOAD_PATH $OUTPUT_FILE $FFMPEG_PATH $PLAY_LIST"
function check() {
    if ! command -v $APP_BIN &> /dev/null; then
        echo "$APP_BIN is not installed. Do you want to install it? (yes/no)"
        read answer
        if [ "$answer" == "y" ]; then
            pip install -y $APP_BIN
        else
            echo "$APP_BIN is required to proceed. Exiting."
            exit 1
        fi
    else
        $APP_BIN --version
        echo "$APP_BIN is already installed."
    fi
}

function download() {
    file_name=$1
    if [ -z "$file_name" ]; then
        echo "download file name is empty $file_name"
        exit 0
    else
        echo "start downloading $file_name"
    fi
    app_args="$SEARCH_PREFIX$file_name\
        $EXTRACT_AUDIO\
        $AUDIO_FORMAT mp3\
        $DOWNLOAD_PATH $DOWNLOAD_PATH_VALUE\
        $OUTPUT_FILE $file_name.mp3\
        $FFMPEG_PATH $FFMPEG_PATH_VALUE\
        $PLAY_LIST"
    echo "download args: $app_args"
    #app_args="$SEARCH_PREFIX$file_name $EXTRACT_AUDIO"
    $ENV_PATH/bin/$APP_BIN $app_args
}

function download_debug() {
    file_name=$1
    if [ -z "$file_name" ]; then
        echo "download file name is empty $file_name"
        exit 0
    else
        echo "start download debug: $file_name"
    fi
    app_args="$SEARCH_PREFIX$file_name\
        $EXTRACT_AUDIO\
        $AUDIO_FORMAT mp3\
        $DOWNLOAD_PATH $DOWNLOAD_PATH_VALUE\
        $OUTPUT_FILE $file_name.mp3\
        $FFMPEG_PATH $FFMPEG_PATH_VALUE\
        $PLAY_LIST"
    echo "download args: $app_args"
    #$DEBUG_DAEMON $ENV_PATH/bin/$APP_BIN $app_args
    $DEBUG_DAEMON $APP_BIN $app_args
    echo "please reference $DEBUG_LOG"
}

# activate_path=$SRC_PATH/$VENV_NAME/bin/activate
# source $activate_path
case "$1" in
    check)
        check
        ;;
    download)
        download $2
        ;;
    debug)
        echo "debug"
        download_debug "有风无风皆自由"
        ;;
    test)
        echo "test"
        whereis yt-dlp
        download "有风无风皆自由"
        ;;
    *)
        echo "Usage: $0 {check|download|debug|test}"
        exit 1
        ;;
esac
# deactivate
