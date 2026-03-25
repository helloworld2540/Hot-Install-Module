#!/bin/sh
# build.sh

ME=${0##*/}
ROOT=${0%/$ME}

# just put the script to .zip
read -p "Update the module? (y/n): " UPDATE
if [ "$UPDATE" = "y" ]; then
    NOW_VER_CODE=$(grep '^versionCode=' "$ROOT/src/module.prop" | cut -d'=' -f2)
    NOW_VER=$(grep '^version=' "$ROOT/src/module.prop" | cut -d'=' -f2)
    read -p "New version (Current: $NOW_VER): " NEW_VER
    read -p "New version code (Current: $NOW_VER_CODE): " NEW_VER_CODE
    sed -i "s/^version=.*/version=$NEW_VER/" "$ROOT/src/module.prop"
    sed -i "s/^versionCode=.*/versionCode=$NEW_VER_CODE/" "$ROOT/src/module.prop"
    sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VER\"/" "$ROOT/update.json"
    sed -i "s/\"versionCode\": [0-9]*/\"versionCode\": $NEW_VER_CODE/" "$ROOT/update.json"
    read -p "Add changelog? (y/n): " ADD_LOG
    if [ "$ADD_LOG" = "y" ]; then
        echo "# $NEW_VER ($NEW_VER_CODE)" > "$ROOT/changelog.md.tmp"
        while true; do
            read -p "- " LOG_LINE
            if [ -z "$LOG_LINE" ]; then
                break
            fi
            echo "- $LOG_LINE" >> "$ROOT/changelog.md.tmp"
        done
        cat "$ROOT/changelog.md" >> "$ROOT/changelog.md.tmp"
        mv "$ROOT/changelog.md.tmp" "$ROOT/changelog.md"
        rm -f "$ROOT/changelog.md.tmp"
    fi
fi
rm -f "$ROOT/bin/build.zip"
7z a "$ROOT/bin/build.zip" "$ROOT"/src/* "$ROOT"/changelog.md > /dev/null 2>&1
[ $? -eq 0 ] && echo "Build successful: $ROOT/bin/build.zip" || echo "Build failed."