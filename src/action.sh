#!/system/bin/sh
# action.sh
# action for module

MODDIR=${0%/*}
. "$MODDIR/import-meta.sh" # import meta
. "$MODDIR/utils.sh" # import utils

subdirs=$(get_subdirs "$MODULE_UPDATE_ROOT")
subdirs_count=$(echo "$subdirs" | wc -l)
failed=0
echo -e "[-] Start hot install $subdirs_count modules...\n"

for dir in $subdirs; do
    echo -e "[-] Hot installing $dir..."
    "$MODDIR/hot-install.sh" "$MODULE_UPDATE_ROOT/$dir"
    failed=$(($failed + $?))
done
UI="[!]"
if [ "$failed" = "0" ]; then
    UI="[✓]"
fi
echo -e "$UI $subdirs_count modules were successfully installed, with $(($subdirs_count - $failed)) successful and $failed failing."
if [ "$failed" != "0" ]; then
    echo -e "[!] Reboot required to complete the installation."
fi