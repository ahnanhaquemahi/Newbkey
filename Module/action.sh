MODPATH="${0%/*}"

# Setup
set +o standalone
unset ASH_STANDALONE

for SCRIPT in \
  "keybox.sh" \
  "target_txt.sh" \
  "security_patch.sh" \
  "boot_hash.sh"
do
  if ! sh "$MODPATH/Newb/$SCRIPT"; then
    echo "- Error: $SCRIPT failed. Aborting."
    exit 1
  fi
done



echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Meets Strong Integrity with Newbkey Manager✨✨"
