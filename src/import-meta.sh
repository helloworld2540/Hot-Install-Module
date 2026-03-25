#!/system/bin/sh
# import-meta.sh
# this script is used as source file
# MODULE_PATH must export by module script

# variables
MAGISK_ROOT="/data/adb/modules" 
SELF_MODDIR="${0%/*}" # /data/adb/modules/hot-install
SELF_MODROOT="${SELF_MODDIR%/*}" # /data/adb/modules
SELF_INSTALLED=$([ "$SELF_MODROOT" = "$MAGISK_ROOT" ] && echo 1 || echo 0)

# export variables
export MAGISK_ROOT
export SELF_MODDIR
export SELF_MODROOT
export SELF_INSTALLED

if [ -z "$MODULE_PATH" ]; then
    MODULE_UPDATE_ROOT="/data/adb/modules_update"
    export MODULE_UPDATE_ROOT
else
    MODULE_PATH=${MODULE_PATH%/} # remove last /
    MODULE_UPDATE_ROOT=${MODULE_PATH%/*} # /data/adb/modules_update/
    MODULE_NAME=${MODULE_PATH##*/} # module_name
    MODULE_REALPATH="$MAGISK_ROOT/$MODULE_NAME" # /data/adb/modules/module_name
    MODULE_INSTALLED=$([ -e "$MODULE_REALPATH" ] && echo 1 || echo 0)
    MODULE_UPDATE_SKIPMOUNT=$([ -e "$MODULE_UPDATE_ROOT/$MODULE_NAME/skip_mount" ] && echo 1 || echo 0)
    MODULE_ISMETA=$(grep -q "metamodule=1" "$MODULE_UPDATE_ROOT/$MODULE_NAME/module.prop" && echo 1 || echo 0)
    # export
    export MODULE_PATH
    export MODULE_UPDATE_ROOT
    export MODULE_NAME
    export MODULE_REALPATH
    export MODULE_INSTALLED
    export MODULE_UPDATE_SKIPMOUNT
    export MODULE_ISMETA
    
    if [ "$MODULE_INSTALLED" = "1" ]; then
        MODULE_DISABLED=$([ -e "$MODULE_REALPATH/disable" ] && echo 1 || echo 0)
        MODULE_SKIPMOUNT=$([ -e "$MODULE_REALPATH/skip_mount" ] && echo 1 || echo 0)
        MODULE_REMOVED=$([ -e "$MODULE_REALPATH/remove" ] && echo 1 || echo 0)
        MODULE_REAL_ISMETA=$(grep -q "metamodule=1" "$MODULE_REALPATH/module.prop" && echo 1 || echo 0)
        # export
        export MODULE_DISABLED
        export MODULE_SKIPMOUNT
        export MODULE_REMOVED
        export MODULE_REAL_ISMETA
    fi
fi



