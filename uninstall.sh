#!/usr/bin/env bash
set -euo pipefail

UDEV_RULE="/etc/udev/rules.d/99-soundblaster-gs5-ignore-input.rules"
WP_RULE="${HOME}/.config/wireplumber/wireplumber.conf.d/51-soundblaster-gs5.conf"

notify_user() {
    local title="$1"
    local text="$2"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$text" || true
    elif command -v kdialog >/dev/null 2>&1; then
        kdialog --title "$title" --msgbox "$text" || true
    else
        printf '%s\n%s\n' "$title" "$text"
    fi
}

rm -f "$WP_RULE"

if command -v pkexec >/dev/null 2>&1; then
    pkexec sh -c "
        rm -f '$UDEV_RULE' &&
        udevadm control --reload-rules &&
        udevadm trigger --subsystem-match=input
    "
else
    sudo sh -c "
        rm -f '$UDEV_RULE' &&
        udevadm control --reload-rules &&
        udevadm trigger --subsystem-match=input
    "
fi

systemctl --user restart wireplumber pipewire pipewire-pulse

notify_user "Sound Blaster GS5" "Uninstall complete. Restart or log out and back in once."
printf '\nSound Blaster GS5 independent control removed.\n'
printf 'Restart or log out and back in once to ensure KDE reloads the input device.\n'
