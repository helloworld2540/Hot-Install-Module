#!/system/bin/sh
# install.sh

SKIPUNZIP=1
unzip -d "$MODPATH" -o "$ZIPFILE" -x "install.sh" -x "changelog.md"
chmod 777 "$MODPATH"/*.sh