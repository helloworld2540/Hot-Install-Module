#!/system/bin/sh
# action.sh
# action for module

MODDIR=${0%/*}
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/utils.sh" # import utils

subdirs=$(get_subdirs "$MODULE_UPDATE_ROOT")
# remove empty line
subdirs=$(echo "$subdirs" | sed '/^$/d')
subdirs_count=$(echo "$subdirs" | wc -l)
failed=0
if [ -z "$subdirs" ]; then
    echo -e "[✓] No module to install."
    exit 0
fi
echo -e "[-] Start hot install $subdirs_count modules...\n"

for dir in $subdirs; do
    echo -e "[-] Hot installing '$dir'..."
    if "$MODDIR/hot-install.sh" "$MODULE_UPDATE_ROOT/$dir"; then
        echo -e "[✓] Installed '$dir'."
    else
        failed=$(($failed + 1))
        echo -e "[!] Failed to install '$dir'."
    fi
    echo -e ""
done
UI="[!]"
if [ "$failed" = "0" ]; then
    UI="[✓]"
fi
WAS_OR_WERE="were"
if [ "$subdirs_count" = "1" ]; then
    WAS_OR_WERE="was"
fi
echo -e "$UI $subdirs_count modules $WAS_OR_WERE successfully installed, with $(($subdirs_count - $failed)) successful and $failed failing."
if [ "$failed" != "0" ]; then
    echo -e "[!] Reboot required to complete the installation."
fi