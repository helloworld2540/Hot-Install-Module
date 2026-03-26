#!/system/bin/sh
# assert.sh
# assert a module can be hot-install

MODDIR=${0%/*}
# MODULE_PATH must export by module script
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/utils.sh" # import utils

if [ "$SELF_INSTALLED" = "0" ]; then
    echo "[!] Reboot required to install Hot Install Module"
    exit 1
fi

assert_failed(){
    if [ -z "$1" ]; then
        echo -e "[!] Cannot hot install '$MODULE_NAME'."
    else
        echo -e "[!] Cannot hot install '$MODULE_NAME': $1"
    fi
    exit 1
}

assert_not_exists(){
    FILENAME=$1
    TYPE_REQUIRED=$2
    # the variables set by user:
    # ALLOW_SAME: allow same file exists
    # ALLOW_REMOVE: allow remove file
    
    # variables set up
    UPDATE="$MODULE_PATH/$FILENAME"
    ORIGINAL="$MODULE_REALPATH/$FILENAME"
    
    # get realpath of UPDATE and ORIGINAL
    if ! UPDATE=$(realpath "$UPDATE"); then
        UPDATE="$MODULE_PATH/$FILENAME"
    fi
    if ! ORIGINAL=$(realpath "$ORIGINAL"); then
        ORIGINAL="$MODULE_REALPATH/$FILENAME"
    fi
    
    if [ -e "$UPDATE" ]; then
        UPDATE_EXISTS=1
        UPDATE_TYPE="$(get_type "$UPDATE")"
        UPDATE_TYPE_SAME=$([ "$TYPE_REQUIRED" = "$UPDATE_TYPE" ] && echo 1 || echo 0)
    else
        UPDATE_EXISTS=0
    fi
    if [ -e "$ORIGINAL" ]; then
        ORIGINAL_EXISTS=1
        ORIGINAL_TYPE="$(get_type "$ORIGINAL")"
        ORIGINAL_TYPE_SAME=$([ "$TYPE_REQUIRED" = "$ORIGINAL_TYPE" ] && echo 1 || echo 0)
    else
        ORIGINAL_EXISTS=0
    fi
    if [ "$UPDATE_EXISTS" = "1" ]; then
        if [ "$UPDATE_TYPE_SAME" = "1" ]; then
            if [ "$ALLOW_SAME" = "1" ]; then
                if [ "$ORIGINAL_EXISTS" = "1" ]; then
                    if [ "$ORIGINAL_TYPE_SAME" = "1" ]; then
                        if [ "$TYPE_REQUIRED" = "dir" ]; then
                            if is_hash_same_dir "$ORIGINAL" "$UPDATE"; then
                                # assert success
                                return 0
                            else
                                assert_failed "module that required mount is not supported to hot-install: '$FILENAME' is found."
                            fi
                        else
                            if is_hash_same_file "$ORIGINAL" "$UPDATE"; then
                                # assert success
                                return 0
                            else
                                assert_failed "file '$FILENAME' is not supported to hot-install."
                            fi
                        fi
                    fi
                else
                    assert_failed "file '$FILENAME' is not supported to hot-install."
                fi
            else
                assert_failed "file '$FILENAME' is not supported to hot-install."
            fi
        else
            assert_failed "file '$FILENAME' is not supported to hot-install."
        fi
    else
        if [ "$ALLOW_REMOVE" = "1" ]; then
            # assert success
            return 0
        else
            if [ "$MODULE_INSTALLED" = "1" ]; then
                if [ "$ORIGINAL_EXISTS" = "1" ]; then
                    if [ "$ORIGINAL_TYPE_SAME" = "1" ]; then
                        assert_failed "file '$FILENAME' is not supported to removed via hot-install."
                    else
                        # assert success
                        return 0
                    fi
                else
                    # assert success
                    return 0
                fi
            else
                # assert success
                return 0
            fi
        fi
    fi
}

assert_not_exists_file(){
    assert_not_exists "$1" "file"
}
assert_not_exists_dir(){
    assert_not_exists "$1" "dir"
}

if [ ! -z "$MODULE_PATH" ]; then
    if [ "$MODULE_REMOVED" = "1" ]; then
        assert_failed "module was removed."
    fi
    export ALLOW_REMOVE=0 # not allow remove these files
    export ALLOW_SAME=1
    # assert not exists the script that depends on boot up
    assert_not_exists_file "post-fs-data.sh"
    assert_not_exists_file "post-mount.sh"
    assert_not_exists_file "boot-completed.sh"
    assert_not_exists_file "late-load.sh"
    assert_not_exists_file "sepolicy.rule"
    assert_not_exists_file "system.prop"
    # assert not a meta-module
    assert_not_exists_file "metamount.sh"
    assert_not_exists_file "metainstall.sh"
    assert_not_exists_file "metauninstall.sh"
    # assert cannot hot-install zygisk module
    assert_not_exists_dir "zygisk/"
    
    if [ "$MODULE_INSTALLED" = "0" ] || [ "$MODULE_SKIPMOUNT" != "1" ] || [ "$MODULE_UPDATE_SKIPMOUNT" != "1" ]; then
        assert_not_exists_dir "system/"
        assert_not_exists_dir "vendor/"
        assert_not_exists_dir "product/"
        assert_not_exists_dir "system_ext/"
        assert_not_exists_dir "odm/"
        assert_not_exists_dir "oem/"
        assert_not_exists_dir "apex/"
    fi
fi