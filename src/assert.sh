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
        echo -e "[!] Cannot hot install '$MODULE_NAME': $1."
    fi
    exit 1
}
assert_hash_same(){
    hash_original=$(sha256sum "$1" -b)
    hash_update=$(sha256sum "$2" -b)
    if [ "$hash_original" = "$hash_update" ]; then
        # assert success
        return 0
    else
        assert_failed "file '$1' is not same."
    fi
}
assert_hash_same_dir(){
    file_original=$(get_relative_files "$1")
    file_update=$(get_relative_files "$2")
    if [ "$file_original" = "$file_update" ]; then
        for file in $file_original; do
            assert_hash_same "$1/$file" "$2/$file"
        done
    else
        assert_failed "directory '$1' is not same."
    fi
}
assert_type_same(){
    TARGET1="$1"
    TARGET2="$2"
    type1=$(get_type "$TARGET1")
    type2=$(get_type "$TARGET2")
    if [ "$type1" = "$type2" ]; then
        # assert success
        return 0
    else
        assert_failed "$TARGET1 is $type1, but $TARGET2 is $type2"
    fi
}
assert_not_exists() {
    if [ "$MODULE_INSTALLED" = "1" ]; then
        FILENAME=$1
        UPDATED="$MODULE_UPDATE_ROOT/$FILENAME"
        ORIGINAL="$MODULE_REALPATH/$FILENAME"
        exists=$([ -e "$ORIGINAL" ] && echo 1 || echo 0)
        update_exists=$([ -e "$UPDATED" ] && echo 1 || echo 0)
        if [ "$exists" = "1" ]; then
            [ "$FORCE" = "1" ] && assert_failed "mount required"
            if [ "$update_exists" = "1" ]; then
                assert_type_same "$ORIGINAL" "$UPDATED"
                type=$(get_type "$ORIGINAL")
                if [ "$type" = "file" ]; then
                    assert_hash_same "$ORIGINAL" "$UPDATED"
                elif [ "$type" = "dir" ]; then
                    assert_hash_same_dir "$ORIGINAL" "$UPDATED"
                else
                    assert_failed "unsupported type '$type'"
                fi
            else
                assert_failed "'$FILENAME' is not supported to hot install"
            fi
        fi
    else
        FILENAME=$1
        UPDATED="$MODULE_UPDATE_ROOT/$FILENAME"
        exists=$([ -e "$UPDATED" ] && echo 1 || echo 0)
        if [ "$exists" = "1" ]; then
            assert_failed "'$FILENAME' is not supported to hot install"
        fi
    fi
}

if [ ! -z "$MODULE_PATH" ]; then
    if [ "$MODULE_REMOVED" = "1" ]; then
        assert_failed "module removed"
    fi
    # assert not exists the script that depends on boot up
    assert_not_exists "post-fs-data.sh"
    assert_not_exists "post-mount.sh"
    assert_not_exists "boot-completed.sh"
    assert_not_exists "late-load.sh"
    assert_not_exists "sepolicy.rule"
    assert_not_exists "system.prop"
    # assert not a meta-module
    assert_not_exists "metamount.sh"
    assert_not_exists "metainstall.sh"
    assert_not_exists "metauninstall.sh"
    [ "$MODULE_ISMETA" = "1" ] && assert_failed "it is a meta-module"
    [ "$MODULE_REAL_ISMETA" = "1" ] && assert_failed "it is a meta-module"
    # assert no mount required
    if [ "$MODULE_SKIPMOUNT" = "0" ] && [ "$MODULE_UPDATE_SKIPMOUNT" = "1" ]; then
        FORCE=1 # force assert
    fi
    if [ "$MODULE_FIRST_INTSTALL" = "1" ]; then
        FORCE=1 # force assert
    fi
    if [ "$MODULE_FIRST_INTSTALL" = "1" ] || [ "$MODULE_SKIPMOUNT" != "1" ] || [ "$MODULE_UPDATE_SKIPMOUNT" != "1" ]; then
        assert_not_exists "system/"
        assert_not_exists "vendor/"
        assert_not_exists "product/"
        assert_not_exists "system_ext/"
        assert_not_exists "odm/"
        assert_not_exists "oem/"
        assert_not_exists "apex/"
    fi
fi