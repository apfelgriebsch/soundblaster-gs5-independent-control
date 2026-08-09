#!/usr/bin/env bash
set -euo pipefail

UDEV_RULE="/etc/udev/rules.d/99-soundblaster-gs5-ignore-input.rules"
WP_DIR="${HOME}/.config/wireplumber/wireplumber.conf.d"
WP_RULE="${WP_DIR}/51-soundblaster-gs5.conf"

UDEV_CONTENT='ACTION!="remove", KERNEL=="event[0-9]*", ENV{ID_VENDOR_ID}=="041e", ENV{ID_MODEL_ID}=="329d", ENV{LIBINPUT_IGNORE_DEVICE}="1"'

WP_CONTENT='monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "alsa_card.usb-Creative_Technology_Ltd_Sound_Blaster_GS5_MF8470-01"
      }
    ]
    actions = {
      update-props = {
        api.alsa.soft-mixer = true
      }
    }
  }
]'

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

mkdir -p "$WP_DIR"
printf '%s\n' "$WP_CONTENT" > "$WP_RULE"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$UDEV_CONTENT" > "$tmp"

if command -v pkexec >/dev/null 2>&1; then
    pkexec sh -c "
        install -m 0644 '$tmp' '$UDEV_RULE' &&
        udevadm control --reload-rules &&
        udevadm trigger --subsystem-match=input
    "
else
    sudo sh -c "
        install -m 0644 '$tmp' '$UDEV_RULE' &&
        udevadm control --reload-rules &&
        udevadm trigger --subsystem-match=input
    "
fi

systemctl --user restart wireplumber pipewire pipewire-pulse

sleep 1

GS5_SINK="$(wpctl status -n 2>/dev/null | awk '/Sound Blaster GS5.*Stereo/ {gsub(/\./,"",$1); gsub(/\*/,"",$1); print $1; exit}' || true)"
if [[ -n "${GS5_SINK:-}" && "$GS5_SINK" =~ ^[0-9]+$ ]]; then
    wpctl set-mute "$GS5_SINK" 0 || true
    wpctl set-volume "$GS5_SINK" 1.0 || true
fi

notify_user "Sound Blaster GS5" "Installation complete. Restart or log out and back in once."
printf '\nSound Blaster GS5 independent control installed.\n'
printf 'Restart or log out and back in once to ensure KDE reloads the input device.\n'
