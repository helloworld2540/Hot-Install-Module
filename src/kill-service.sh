#!/system/bin/sh
# kill-service.sh
# kill all binary or shell script service/daemon process from a root directory

MODDIR=${0%/*}
ROOT_DIR="$1"
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/utils.sh" # import utils

# skip hot-install
if [ "$MODULE_NAME" = "hot-install" ]; then
    exit 0
fi
files_list=$(get_relative_files "$ROOT_DIR")

for file in $files_list; do
    
    PID=$(pgrep -f "$ROOT_DIR/$file") && kill -9 "$PID"
done