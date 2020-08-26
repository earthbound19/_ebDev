# DESCRIPTION
# SAVES a boot pattern to a blink1 (USB-powered LED) device via blink1-tool (Mac).

# USAGE
# Run without any parameter:
#    blink1blue-red-alternate-start-pattern.sh


# CODE
# Wipe whatever pattern may be on the device:
blink1-tool --clearpattern ; blink1-tool --savepattern
# blink magenta on light 1, cyan on light 2:
blink1-tool -g -m 50 --RGB 0xff,0x00,0x00 -l 1 --setpattline 0
# blink cyan on light 1, magenta on light 2, after this swap, then repeat..
blink1-tool -g -m 50 --RGB 0x00,0x00,0xff -l 2 --setpattline 1
blink1-tool -g -m 50 --RGB 0xff,0x00,0x00 -l 2 --setpattline 2
blink1-tool -g -m 50 --RGB 0x00,0x00,0xff -l 1 --setpattline 3
# save that pattern to the blink as a bootup (USB only--no computer) pattern:
blink1-tool --savepattern