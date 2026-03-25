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
get_relative_files() {
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -type f | sed 's|^\./||' | sort)
    fi
}
get_subdirs() {
    TARGET_DIR="$1"
    if [ -d "$TARGET_DIR" ]; then
        (cd "$TARGET_DIR" && find . -maxdepth 1 -type d ! -name "." | sed 's|^\./||' | sort)
    fi
}