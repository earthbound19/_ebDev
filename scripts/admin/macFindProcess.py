# DESCRIPTION
# Identifies the process associated with a window on MacOS. RE: https://superuser.com/a/1171739

# USAGE
#  python path/to/this/script/macFindProcess.py
# -- then follow on-screen prompts.

# DEPENDENCIES
# pyenv (suggested)
# Python 2, via these commands:
# pyenv install 2.7.15
# pyenv active 2.7.15
# pip install pyobjc-framework-Quartz


# CODE
import Quartz
import time
from Foundation import NSSet, NSMutableSet
def transformWindowData(data):
    list1 = []
    for v in data:
        if not v.valueForKey_('kCGWindowIsOnscreen'):
            continue


        row = ( \
            str(v.valueForKey_('kCGWindowOwnerPID') or '?').rjust(7) + \
            ' ' + str(v.valueForKey_('kCGWindowNumber') or '?').rjust(5) + \
            ' {' + ('' if v.valueForKey_('kCGWindowBounds') is None else \
                ( \
                    str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('X')))     + ',' + \
                    str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('Y')))     + ',' + \
                    str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('Width'))) + ',' + \
                    str(int(v.valueForKey_('kCGWindowBounds').valueForKey_('Height'))) \
                ) \
                ).ljust(21) + \
            '}' + \
            '\t[' + ((v.valueForKey_('kCGWindowOwnerName') or '') + ']') + \
            ('' if v.valueForKey_('kCGWindowName') is None else (' ' + v.valueForKey_('kCGWindowName') or '')) \
        ).encode('utf8')
        list1.append(row)

    return list1;

def printBeautifully(dataSet):
    print 'PID'.rjust(7) + ' ' + 'WinID'.rjust(5) + '  ' + 'x,y,w,h'.ljust(21) + ' ' + '\t[Title] SubTitle'
    print '-'.rjust(7,'-') + ' ' + '-'.rjust(5,'-') + '  ' + '-'.ljust(21,'-') + ' ' + '\t-------------------------------------------'

    # print textList1
    for v in dataSet:
        print v;

#grab initial set
wl = Quartz.CGWindowListCopyWindowInfo( Quartz.kCGWindowListOptionAll, Quartz.kCGNullWindowID)
wl = sorted(wl, key=lambda k: k.valueForKey_('kCGWindowOwnerPID'))

#convert into readable format
textList1 = transformWindowData(wl);

#print everything we have on the screen
print 'all windows:'
printBeautifully(textList1)

print 'Move target window'
time.sleep(5)

#grab window data the second time
wl2 = Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionAll, Quartz.kCGNullWindowID)
textList2 = transformWindowData(wl2)

#check the difference
w = NSMutableSet.setWithArray_(textList1)
w.minusSet_(NSSet.setWithArray_(textList2))

#print the difference
printBeautifully(w)