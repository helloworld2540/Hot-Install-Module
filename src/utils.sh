#!/system/bin/sh
# utils.sh
# this script is used as source file to import utils function

get_type() {
    TARGET="$1"
    if [ -L "$TARGET" ]; then
        echo "link"
    elif [ -d "$TARGET" ]; then
        echo "dir"
    elif [ -f "$TARGET" ]; then
        echo "file"
    elif [ ! -e "$TARGET" ]; then
        echo "none"
    else
        echo "other"
    fi
}
get_relative_child() {
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . | sed 's|^\./||' | sort)
    fi
}
get_relative_files(){
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -type f | sed 's|^\./||' | sort)
    fi
}
get_relative_dirs(){
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -type d | sed 's|^\./||' | sort)
    fi
}
get_subdirs() {
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -maxdepth 1 -type d ! -name "." | sed 's|^\./||' | sort)
    fi
}
get_subfiles(){
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -maxdepth 1 -type f ! -name "." | sed 's|^\./||' | sort)
    fi
}
get_subchild() {
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -maxdepth 1 ! -name "." | sed 's|^\./||' | sort)
    fi
}

is_hash_same_file(){
    hash_original=$(sha256sum "$1" -b) || return 1
    hash_update=$(sha256sum "$2" -b) || return 1
    if [ "$hash_original" = "$hash_update" ]; then
        # assert success
        return 0
    else
        return 1
    fi
}
is_hash_same_dir(){
    dirs_original=$(get_relative_dirs "$1")
    dirs_update=$(get_relative_dirs "$2")
    files_original=$(get_relative_files "$1")
    files_update=$(get_relative_files "$2")
    # check dir
    [ "$dirs_original" != "$dirs_update" ] && return 1
    # check file
    [ "$files_original" != "$files_update" ] && return 1
    for file in $files_original; do
        ORIGINAL="$1/$file"
        UPDATE="$2/$file"
        if ! is_hash_same_file "$ORIGINAL" "$UPDATE"; then
            return 1
        fi
    done
    # assert success
    return 0
}
is_hash_same(){
    if [ -d "$1" ]; then
        is_hash_same_dir "$1" "$2"
    else
        is_hash_same_file "$1" "$2"
    fi
}