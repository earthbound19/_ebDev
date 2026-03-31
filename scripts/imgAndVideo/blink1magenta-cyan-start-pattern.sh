# DESCRIPTION
# SAVES a boot pattern to a blink1 (USB-powered LED) device via blink1-tool (Mac).
# reference:
# https://github.com/todbot/blink1-tool/blob/master/scripts/blink1-pattern-fill.sh
# https://github.com/todbot/blink1-tool/blob/master/scripts/blink1-patt-tst.sh

# USAGE
#    blink1magenta-cyan-start-pattern.sh


# CODE
# Wipe whatever pattern may be on the device:
blink1-tool --clearpattern ; blink1-tool --savepattern

# SET PATTERN
# turn magenta-magenta-rose on lights 1 and 2:
blink1-tool --rgb=0xff,0x05,0x96 -g -m 8000 -l 1 --setpattline 0
blink1-tool --rgb=0xff,0x05,0x96 -g -m 8000 -l 2 --setpattline 1
# alternate light 1 cyan:
blink1-tool --rgb=0x01,0xed,0xfd -g -m 8000 -l 1 --setpattline 2
blink1-tool --rgb=0xff,0x05,0x96 -g -m 8000 -l 2 --setpattline 3
# alternate light 2 cyan:
blink1-tool --rgb=0x01,0xed,0xfd -g -m 8000 -l 1 --setpattline 4
blink1-tool --rgb=0x01,0xed,0xfd -g -m 8000 -l 2 --setpattline 5
# alternate light 1 back to magenta-magenta-rose:
blink1-tool --rgb=0xff,0x05,0x96 -g -m 8000 -l 1 --setpattline 6
blink1-tool --rgb=0x01,0xed,0xfd -g -m 8000 -l 2 --setpattline 7
# linger on magenta-magenta-rose for light 1 and black for light 2 again (the effect of the start because of delay on light 1, to counteract a too-whitish effect otherwise . .
blink1-tool --rgb=0xff,0x05,0x96 -g -m 10000 -l 1 --setpattline 8
blink1-tool --rgb=0x00,0x00,0x00 -g -m 10000 -l 2 --setpattline 9
# REPEAT

# save that pattern to the blink as a bootup (USB only--no computer) pattern:
blink1-tool --savepattern
# setting startup pattern; set startup true (1,), run line (pos) 0-3, (0,3), run forever (0); re: https://github.com/todbot/blink1/blob/main/docs/blink1-tool-tips.md#play-the-blue-part-of-the-startup-sequence-forever
blink1-tool --setstartup 1,0,9,0

echo ""
echo "DONE. Pattern written and set to play on start. To see the pattern play, remove and re-insert the blink1."

# OPTIONAL: play the pattern:
# blink1-tool --play 1