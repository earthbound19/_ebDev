# SAVES a boot pattern to a blink1 (USB-powered LED device) device via blink1-tool (Mac).

# Wipe whatever pattern may be on the device:
blink1-tool --clearpattern ; blink1-tool --savepattern
# blink magenta on light 1, cyan on light 2:
blink1-tool -g -m 700 --rgb 0xff,0x00,0xff -l 1 --setpattline 0
# blink cyan on light 1, magenta on light 2, after this swap, then repeat..
blink1-tool -g -m 700 --rgb 0x00,0xff,0xff -l 2 --setpattline 1
blink1-tool -g -m 700 --rgb 0xff,0x00,0xff -l 2 --setpattline 2
blink1-tool -g -m 700 --rgb 0x00,0xff,0xff -l 1 --setpattline 3
# save that pattern to the blink as a bootup (USB only--no computer) pattern:
blink1-tool --savepattern