# Sound Blaster GS5 Independent Control

Small Linux helper for the **Creative Sound Blaster GS5** on CachyOS / Arch-based systems using PipeWire, WirePlumber and KDE Wayland.

It separates the GS5 hardware volume control from the desktop volume control.

## What it does

The installer applies two changes:

1. **GS5 knob -> KDE**
   - KDE/libinput ignores the GS5 HID volume events.
   - Turning the volume knob on the GS5 no longer changes the KDE system volume.

2. **KDE/PipeWire -> GS5 hardware mixer**
   - WirePlumber uses a software mixer for the GS5.
   - PipeWire no longer controls the GS5 hardware mixer directly.

USB audio remains available normally.

## Device

This repository is configured specifically for:

- Creative Sound Blaster GS5
- USB ID: `041e:329d`
- WirePlumber device: `alsa_card.usb-Creative_Technology_Ltd_Sound_Blaster_GS5_MF8470-01`

## Install

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

After installation, restart the computer or log out and back in once.

## Uninstall

```bash
./uninstall.sh
```

Then restart the computer or log out and back in once.

## Files installed

```text
/etc/udev/rules.d/99-soundblaster-gs5-ignore-input.rules
~/.config/wireplumber/wireplumber.conf.d/51-soundblaster-gs5.conf
```

The uninstall script removes both files again.

## Expected behavior

After installation:

- Turning the GS5 knob changes the GS5 volume only.
- KDE no longer reacts to the GS5 volume knob.
- PipeWire no longer uses the GS5 hardware mixer.
- The GS5 continues to work as a normal USB audio output.
- Other keyboard/media volume keys continue to work normally.

## Requirements

- Linux
- PipeWire
- WirePlumber
- systemd
- udev
- `wpctl`
- KDE Wayland was used for testing

## Notes

This project targets the exact GS5 USB/device identifiers listed above. If Creative changes the identifiers in another hardware revision, the matching rules may need to be adjusted.

## Version

`1.0.0`
