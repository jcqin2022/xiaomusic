#!/bin/bash

### BEGIN INFO
# Goal: download video, mp3 from bilibili or yourtube.
# 11/19/2024: init version.
# 11/20/2024: ffmpeg issue is caused by its version not path, just re-install.
### END INFO

#APP
HOME_BASE="/home/alic"
NAME="xiaomusic"
LOG_FILE="$HOME_BASE/log.txt"
SRC_PATH="$HOME_BASE/$NAME"
# update path for different devices
if [ ! -d "$SRC_PATH" ]; then
    SRC_PATH="$HOME_BASE/miservice/$NAME"
fi
VENV_NAME=".env"
ENV_PATH="$SRC_PATH/$VENV_NAME"
if [ ! -d "$ENV_PATH" ]; then
    VENV_NAME=".venv"
    ENV_PATH="$SRC_PATH/$VENV_NAME"
fi
echo "ENV_PATH: $ENV_PATH"
# end update.
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
FFMPEG_BIN="$SRC_PATH/ffmpeg/bin/ffmpeg"

#VIDEO_FORMAT="-f"
#VIDEO_FORMAT_VALUE="'bv[ext=mp4]+ba[ext=best]'"
VIDEO_FORMAT=""
VIDEO_FORMAT_VALUE=""
EMBED_METADATA="--embed-metadata"
MERGE_FORMAT="--merge-output-format"
MERGE_FORMAT_VALUE="mp4"
OUTPUT_FILE_FOMAT="'%(title)s.%(ext)s'"
LIST_FORMAT="--list-formats"

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
    if ! command -v $FFMPEG_BIN &> /dev/null; then
        echo "ffmpeg is not installed."
        install_dependency
    fi
}

function install_dependency() {
    echo "installing ffmpeg"
    bash $SRC_PATH/install_dependencies.sh
}

function download_mp3() {
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

function download_video() {
    url=$1
    if [ -z "$url" ]; then
        echo "download url is empty $url"
        exit 0
    else
        echo "start downloading $url"
    fi
    echo "available formats for: $url"
    $ENV_PATH/bin/$APP_BIN $url $LIST_FORMAT
    app_args="$url\
        $VIDEO_FORMAT $VIDEO_FORMAT_VALUE\
        $EMBED_METADATA\
        $MERGE_FORMAT $MERGE_FORMAT_VALUE\
        $DOWNLOAD_PATH $DOWNLOAD_PATH_VALUE\
        $OUTPUT_FILE $OUTPUT_FILE_FOMAT\
        $FFMPEG_PATH $FFMPEG_PATH_VALUE"
    echo "Prepare to download:"
    echo "download args: $app_args"
    #app_args="$SEARCH_PREFIX$file_name $EXTRACT_AUDIO"
    $ENV_PATH/bin/$APP_BIN $app_args
}

function download_mp3_debug() {
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
    dm)
        download_mp3 $2
        ;;
    dv)
        download_video $2
        ;;
    debug)
        echo "debug"
        download_mp3_debug "有风无风皆自由"
        ;;
    test)
        echo "test"
        #whereis yt-dlp
        #download_mp3 "有风无风皆自由"
        download_video "https://www.bilibili.com/video/BV1XnDnY2E6m"

        ;;
    *)
        echo "Usage: $0 {check|dm-mp3|dv-video|debug|test}"
        exit 1
        ;;
esac
# deactivate
