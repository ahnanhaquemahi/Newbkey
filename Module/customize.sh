#!/system/bin/sh

# Define important paths and file names
TRICKY_DIR="/data/adb/tricky_store"
REMOTE_URL="https://raw.githubusercontent.com/ahnanhaqeumahi/Newbkey/main/conf"
TARGET_FILE="$TRICKY_DIR/keybox.xml"
BACKUP_FILE="$TRICKY_DIR/keybox.xml.bak"
TMP_REMOTE="$TRICKY_DIR/remote_keybox.tmp"
SCRIPT_REMOTE="$TRICKY_DIR/remote_script.sh"
DEPENDENCY_MODULE="/data/adb/modules/tricky_store"

# Show UI banner
ui_print ""
ui_print "*********************************"
ui_print "*****Newb Keybox Installer*******"
ui_print "*********************************"
ui_print ""

# Remove old module if legacy path exists (lowercase 'Newbkey')
if [ -d "/data/adb/modules/Newbkey" ]; then
  touch /data/adb/modules/Newbkey/remove
fi

# Check if Tricky Store module is installed (required dependency)
if [ ! -d "$DEPENDENCY_MODULE" ]; then
  ui_print "- Error: Tricky Store module not found!"
  ui_print "- Please install Tricky Store before using Yuri Keybox."
  abort
fi

# Function to download the remote keybox
fetch_remote_keybox() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REMOTE_URL" | base64 -d > "$SCRIPT_REMOTE"
    chmod +x "$SCRIPT_REMOTE"
    if ! sh "$SCRIPT_REMOTE"; then
      ui_print "- Error: Remote script failed. Aborting."
      return 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$REMOTE_URL" | base64 -d > "$SCRIPT_REMOTE"
    chmod +x "$SCRIPT_REMOTE"
    if ! sh "$SCRIPT_REMOTE"; then
      ui_print "- Error: Remote script failed. Aborting."
      return 1
    fi
  else
    ui_print "- Error: curl or wget not found."
    ui_print "- Cannot fetch remote keybox."
    ui_print "- Tip: You can install a working BusyBox with network tools from:"
    ui_print "- https://mmrl.dev/repository/grdoglgmr/busybox-ndk"
    return 1
  fi
  return 0
}

# Function to update the keybox file
update_keybox() {
  ui_print "- Fetching remote keybox..."
  if ! fetch_remote_keybox; then
    ui_print "- Failed to fetch remote keybox!"
    return
  fi

  # Check if keybox already exists
  if [ -f "$TARGET_FILE" ]; then
    # If the new one is identical, skip update
    if cmp -s "$TARGET_FILE" "$TMP_REMOTE"; then
      ui_print "- Existing Newb Keybox found. No changes made."
      rm -f "$TMP_REMOTE"
      rm -rf "$SCRIPT_REMOTE"
      return
    else
      # If the file differs, back up the old one
      ui_print "- Existing keybox not by Newb."
      ui_print "- Creating a backup..."
      mv "$TARGET_FILE" "$BACKUP_FILE"
      rm -rf "$SCRIPT_REMOTE"
    fi
  else
    ui_print "- No keybox found. Creating a new one."
  fi

  # Move the downloaded keybox into place
  mv "$TMP_REMOTE" "$TARGET_FILE"
  rm -rf "$SCRIPT_REMOTE"
  ui_print "- keybox.xml successfully updated."
}

# Start main logic
ui_print "- Checking if there is an Newb Keybox..."
mkdir -p "$TRICKY_DIR" # Make sure the directory exists
update_keybox          # Begin the update process



