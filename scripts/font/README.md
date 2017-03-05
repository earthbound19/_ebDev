fontDevTools
============

Tools (e.g. console scripts to run tools) for font development.

The tools these rely on are not provided in this repository, but you may find them freely available on the world wide web. 08/13/2014 06:32:41 PM -RAH


DEV NOTES:
Possible lead in the comments yon on dividing a path into individual notes, re; http://i.liketightpants.net/and/programmatically-manipulating-typefaces :

"This is quite appropriate! I’m writing my thesis on the subject of conceptual manipulations of typefaces. Joost said I should follow your workshop. So a program can constitute a specific manipulation—for example, how would you go about to remove the curves from a typeface, to make all curves straight?

by Alina Kadlubsky - May 31, 2012 10:37 PM
Reply

Sure!

from robofab.world import CurrentFont
font = CurrentFont()
for g in [glyph.name for glyph in font]:
    old = font[g]
    print len(old)
    new = font.newGlyph("dummytmp", clear=True)


    pen = new.getPointPen()
    for contour in old:
        pen.beginPath()
        for point in contour.points:
            if point.type != "offCurve":
                pen.addPoint((point.x,point.y),"line")
        pen.endPath()


    font.newGlyph(g, clear=True)
    old.appendGlyph(new)
font.removeGlyph("dummytmp")
font.update()

Yes so John Haltiwanger and me spent some time figuring this out for the workshop in Stuttgart. Basically we’re reconstructing the contours in the glyph point by point, but we skip off curve points--these are the control handles to the béziers. Without the control handles the curves become straight lines."