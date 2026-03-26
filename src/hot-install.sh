#!/system/bin/sh
# hot-install.sh
# Hot Install a Module

if [ -z "$1" ]; then
    echo "Usage: $0 MODULE_PATH"
    echo "Hot Install a Module"
    exit 1
fi
export MODULE_PATH="$1"

start_hot_install(){
    # install
    cp -a "$MODULE_UPDATE_ROOT/$MODULE_NAME" "$MODULE_REALPATH"
    if [ "$MODULE_DISABLED" = "1" ]; then
        touch "$MODULE_REALPATH/disable"
    fi
    if [ "$MODULE_SKIPMOUNT" = "1" ]; then
        touch "$MODULE_REALPATH/skip_mount"
    fi
    # clean up
    rm -rf "${MODULE_UPDATE_ROOT:?}/$MODULE_NAME"
    # restart service.sh
    if [ -e "$MODULE_REALPATH/service.sh" ]; then
        export HOT_INSTALLED=1
        "$MODULE_REALPATH/service.sh" &
    fi
}


MODDIR=${0%/*}
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/assert.sh" # assert can hot-install
. "$MODDIR/utils.sh" # import utils

if [ "$MODULE_INSTALLED" = "1" ]; then
    if [ "$MODULE_NAME" = "hot-install" ]; then
        echo -e "[-] Detected hot installing 'Hot Install Module'..."
        echo -e "[-] Skip kill service."
    else
        "$MODDIR/kill-service.sh" "$MODULE_REALPATH"
    fi
    rm -rf "$MODULE_REALPATH"
fi
start_hot_install
