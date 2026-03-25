#!/system/bin/sh
# kill-service.sh
# kill all binary or shell script service/daemon process from a root directory

MODDIR=${0%/*}
ROOT_DIR="$1"
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/utils.sh" # import utils

files_list=$(get_relative_files "$ROOT_DIR")
SELF_PATH=$(realpath "$0")

for file in $files_list; do
    # allow hot install self
    if [ "$ROOT_DIR/$file" != "$SELF_PATH" ]; then
        PID=$(pgrep -f "$ROOT_DIR/$file") && kill -9 "$PID"
    fi
done