#!/usr/bin/env python3
import fcntl
import os
import struct
import sys

EVIOCSKEYCODE = 0x40084504
EVIOCSKEYCODE_V2 = 0x40284504
SCANCODE_RIGHT_ALT = 0xB8
SCANCODE_RIGHT_CTRL = 0x9D
KEY_X = 45


def read_first_line(path):
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return handle.readline().strip()
    except OSError:
        return ""


def event_name(device):
    event = os.path.basename(device)
    return read_first_line(f"/sys/class/input/{event}/device/name")


def set_keycode(fd, scancode, keycode):
    try:
        fcntl.ioctl(fd, EVIOCSKEYCODE, struct.pack("II", scancode, keycode))
        return
    except OSError as first_error:
        entry = struct.pack(
            "=BBHI32s",
            0,
            4,
            0,
            keycode,
            struct.pack("=I", scancode) + bytes(28),
        )
        try:
            fcntl.ioctl(fd, EVIOCSKEYCODE_V2, entry)
            return
        except OSError:
            raise first_error


def main():
    device = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("DEVNAME", "")
    if not device:
        raise SystemExit("missing input event device")

    vendor = read_first_line("/sys/class/dmi/id/sys_vendor")
    product = read_first_line("/sys/class/dmi/id/product_name")
    if vendor != "Dell Inc." or product != "G5 5587":
        return

    if event_name(device) != "AT Translated Set 2 keyboard":
        return

    with open(device, "rb+", buffering=0) as event:
        # Right Alt / AltGr -> KEY_X.
        set_keycode(event.fileno(), SCANCODE_RIGHT_ALT, KEY_X)


if __name__ == "__main__":
    main()
