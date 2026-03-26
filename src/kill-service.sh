#!/system/bin/sh
# kill-service.sh
# kill all binary or shell script service/daemon process from a root directory

MODDIR=${0%/*}
ROOT_DIR="$1"
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/utils.sh" # import utils

files_list=$(get_relative_files "$ROOT_DIR")

for file in $files_list; do
    if PID=$(pgrep -f "$ROOT_DIR/$file"); then
        for pid in $PID; do
            kill -9 "$pid"
        done
    fi
done