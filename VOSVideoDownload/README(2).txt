ANY FALSE USE OF THIS PROGRAM CAN RESULT IN COPYRIGHT INFRINGEMENT TO THE RESPECTIVE AUTHORS.
THIS CODE HAS BEEN WRITTEN WITH THE USE OF ARTIFICIAL INTELLIGENCE.

INTENDED OS: APPLE (IOS/MAC)

INSTALLING:

STEP 1:
INSTALL A-SHELL

STEP 2:
COPY THIS SCRIPT:
"#!/bin/sh

UPDATE_URL_BASE=https://raw.githubusercontent.com/vrederik123/VOSVideoDownload---Updates/main/vosvideodownload.sh
DOWNLOAD_URL=${VOS_DOWNLOAD_URL:-$UPDATE_URL_BASE}

case "$0" in
    */*) SCRIPT_NAME=${0##*/}; SCRIPT_DIR=${0%/*}; [ -n "$SCRIPT_DIR" ] || SCRIPT_DIR=/ ;;
    *) SCRIPT_NAME=$0; SCRIPT_DIR=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd "$SCRIPT_DIR" && pwd) || {
    printf '%s\n' "Cannot resolve the installer directory."
    exit 1
}
INSTALL_PATH=$SCRIPT_DIR/vosvideodownload.sh
DOWNLOAD_TMP=$SCRIPT_DIR/.vosvideodownload-download.$$
INSTALL_TMP=$SCRIPT_DIR/.vosvideodownload-install.$$

cleanup() {
    rm -f "$DOWNLOAD_TMP" "$INSTALL_TMP"
}
trap cleanup 0
trap 'exit 1' HUP INT TERM

banner() {
    if [ -t 1 ]; then
        printf '\033[2J\033[H'
        printf '\033[38;5;208m'
    fi
    printf '%s\n' \
        'VOSVIDEODOWNLOAD INSTALLER' \
        '--------------------------'
    if [ -t 1 ]; then
        printf '\033[0m'
    fi
    printf '\n'
}

read_input() {
    IFS= read -r REPLY
}

valid_version() {
    awk -v version="$1" 'BEGIN {
        count = split(version, part, ".")
        if (count < 2 || count > 4) exit 1
        for (i = 1; i <= count; i++) {
            if (part[i] !~ /^[0-9]+$/) exit 1
        }
    }'
}

rewrite_update_url() {
    awk -v url="$UPDATE_URL_BASE" '
        BEGIN { matches = 0 }
        /^UPDATE_URL=/ {
            print "UPDATE_URL=${VOS_UPDATE_URL:-" url "}"
            matches++
            next
        }
        { print }
        END { if (matches != 1) exit 1 }
    ' "$1" > "$2"
}

banner
printf '%s\n' "This installs the Apple shell version beside this installer:"
printf '  %s\n' "$INSTALL_PATH"
if [ -e "$INSTALL_PATH" ]; then
    printf '%s\n' "An installed script already exists. Its settings, history, and videos will be kept."
    printf '%s' "Replace the script? [y/N]: "
else
    printf '%s' "Install VOSVideoDownload? [y/N]: "
fi
read_input || exit 1
case "$REPLY" in
    y|Y) ;;
    *) printf '%s\n' "Installation cancelled."; exit 0 ;;
esac

if [ ! -w "$SCRIPT_DIR" ]; then
    printf 'Cannot write to the installer folder: %s\n' "$SCRIPT_DIR"
    exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
    printf '%s\n' "curl is unavailable in this shell."
    exit 1
fi

banner
printf '%s\n' "Downloading the Apple version..."
if ! curl --location --fail --silent --show-error --connect-timeout 15 --max-time 60 \
    "$DOWNLOAD_URL" --output "$DOWNLOAD_TMP"; then
    printf '%s\n' "Download failed. Check your connection and the update URL:"
    printf '  %s\n' "$DOWNLOAD_URL"
    exit 1
fi

if [ ! -s "$DOWNLOAD_TMP" ] || ! grep -Fxq 'VOS_IOS_SCRIPT=1' "$DOWNLOAD_TMP"; then
    printf '%s\n' "The downloaded file is not a valid VOSVideoDownload Apple script."
    exit 1
fi
INSTALLED_VERSION=$(sed -n 's/^VERSION=//p' "$DOWNLOAD_TMP" | head -n 1)
VERSION_TYPE=$(sed -n 's/^VERSION_TYPE=//p' "$DOWNLOAD_TMP" | head -n 1)
if ! valid_version "$INSTALLED_VERSION" || [ -z "$VERSION_TYPE" ] ||
    printf '%s\n' "$VERSION_TYPE" | grep -Eq '[^A-Za-z0-9_-]'; then
    printf '%s\n' "The downloaded script has invalid version metadata."
    exit 1
fi

if ! rewrite_update_url "$DOWNLOAD_TMP" "$INSTALL_TMP"; then
    printf '%s\n' "Could not set the installed script's update URL."
    exit 1
fi
if ! sh -n "$INSTALL_TMP"; then
    printf '%s\n' "The downloaded script has invalid shell syntax."
    exit 1
fi
if ! mv "$INSTALL_TMP" "$INSTALL_PATH"; then
    printf 'Could not install the script at: %s\n' "$INSTALL_PATH"
    exit 1
fi

printf '\nVOSVideoDownload %s (%s) installed successfully.\n' "$INSTALLED_VERSION" "$VERSION_TYPE"
printf 'Run it with: sh "%s"\n' "$INSTALL_PATH"
printf '%s\n' "The updater is configured to use:"
printf '  %s\n' "$UPDATE_URL_BASE""
