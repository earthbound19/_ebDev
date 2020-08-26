// DESCRIPTION
// Rapidly generates and saves random irregular geometry ideas.

// USAGE
// - Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.
// - Observe the png and svg format files saved alongside this file.
// - Pick your favorites and incorporate the ideas into other works (or, that is the intent). Some people like them just by themselves as art.


// CODE
// by Richard Alexander Hall

// CODE
// by Richard Alexander Hall, Copyright 2019
// Inspired by Daniel Bartholomew's "Abstractoons."
// TO DO:
// - rnd color fill / outline option logic (use that function)
// - parameter control of iterations
// - equilateral properly center-reference drawn triangle option (unpredictable triangle option commented out for now)
// - random repeat translate from 1-3
// - that with repeat shape or alterante shape

// v0.9.16 changes:
// - global varaible controlling iterations
// - add version string global variable
// - give both these items of information in saved file names.
// - hard code img size to 11x95" @ 96DPI (not fullscreen)
String versionString = "0.9.16";

// DEPENDENCY INCLUDE
import processing.svg.*;

// GLOBALS
int iterationsArg = 2;    // controls how many subsequently smaller shape arrangements to make.
color backgroundColor = #524547;  // Prismacolor Black
// color backgroundColor = #FFFFFF;

// Prismacolor marker colors array:
color[] Prismacolors = {
  #E54D93, #F9E3E0, #D13352, #E14E6D, #F45674, #EA5287, #EF7FAD,
  #F6C6D0, #F895AC, #F4DCD7, #F9C0BC, #F65C6A, #F86060, #FD9863,
  #FA855B, #F7D580, #ECBF7A, #F5D969, #F3C77D, #EEE2C7, #EEE4DC,
  #93CD87, #75755C, #C6DD8E, #687B57, #618979, #009E90, #A2B1A2,
  #008D94, #4F8584, #00B3DB, #0090C7, #33549B, #405F89, #435BA3,
  #574C70, #0BBDC4, #4CC8D9, #97C1DA, #934393, #CA4587, #E65F9F,
  #D8308F, #B1A1C9, #88595C, #8D6E64, #BD6E6B, #EBB28B, #F5DCD5,
  #F7DDCB, #C97B8E, #F0CCC4, #E5E4E9, #F5D3DD, #D46569, #CA5A62,
  #A0716D, #DEBBB3, #C87F73, #EE8A74, #C9877F, #EDD6BF, #5B4446,
  #524547, #F1E5E9, #F0D9DC, #E9C9D1, #C5AAB4, #B7A1AF, #A58E9A,
  #8C7B87, #6A5B67, #62555E, #DDDBE0, #C7C6CD, #C8C7CE, #A4A1A9,
  #9B98A2, #7F7986, #857F8A, #72727D, #615F6B, #FCC0BA, #FFC874,
  #BEB27B, #367793, #6389AB, #8D6CA9, #AF62A2, #FEC29F, #F2D8A4,
  #F8D9BE, #ECA6B9, #7AD2E2, #E497A4, #A7BCBB, #95B6BA, #7B91A2,
  #69A2BE, #C9CBE0, #A1A6D0, #C0A9BE, #AA8E79, #8E4C5C, #AA4662,
  #C14F6E, #D96A6E, #F98973, #F7DFD8, #D1BCBD, #CBADB1, #BFA9A8,
  #B19491, #987D80, #877072, #745D5F, #72646C, #36B191, #66C7B0,
  #8F4772, #B34958, #FA9394, #AC9EB8, #9B685D, #59746E, #1E7C72,
  #009D79, #82B079, #91BACB, #E0BFB5, #74B3E3
};
int PrismacolorArrayLength = Prismacolors.length; 


// irregular geometry generator class
class IrregularGeometryGenerator {
  int canvasDimX;
  int canvasDimY;
  int canvasLen;
  float RNDtranslateMultiplier;
  float RNDshapeLenMult;
  float RNDtranslateReduceMultiplier;
  float RNDshapeLenReduceMultiplier;
  float translationJitter;
  int shapeStrokeWeight;
  int iterations;
  boolean inEraseMode;
  boolean useEraseMode;
// TO DO: use the next variable:
  boolean RNDcolorMode;
  color eraseModeColorFill;
  color eraseModeColorStroke;
  color fillModeColorFill;
  color fillModeColorStroke;

  // constructor
  IrregularGeometryGenerator(int iterationsArg) {
    canvasDimX = width;     // display width
    canvasDimY = height;    // display height
    RNDtranslateMultiplier = 0.84;
    RNDshapeLenMult = 0.86;
    RNDtranslateReduceMultiplier = 0.64;
    RNDshapeLenReduceMultiplier = 0.94;
    translationJitter = 0.49;
      if (canvasDimX >= canvasDimY) {
        canvasLen = canvasDimY;
      }
      else {
        canvasLen = canvasDimX;
      }
    iterations = iterationsArg;
    shapeStrokeWeight = 4;
    inEraseMode = false;
    useEraseMode = true;
// TO DO: RND color mode things enabled via the following boolean when true! :
    RNDcolorMode = false;
    eraseModeColorStroke = #615F6B;      // Prismacolor cool grey 90%
    eraseModeColorFill = #524547;      // Prismacolor black
    fillModeColorFill = #FFFFFF;
    fillModeColorStroke = #524547;      // Prismacolor black
    rectMode(CENTER);
    ellipseMode(CENTER);
  }

  void setRNDcolors() {
     // shape etc. rnd color fill change
     // DEPRECATED; pure random:
     // fill( (int) random(255), (int) random(255), (int) random(255) );
     // stroke( (int) random(255), (int) random(255), (int) random(255) );
    int RNDarrayIndex = (int)random(PrismacolorArrayLength);
    stroke(Prismacolors[RNDarrayIndex]);
    RNDarrayIndex = (int)random(PrismacolorArrayLength);
    fill(Prismacolors[RNDarrayIndex]);
  }

  // set erase drawing colors
  void setSubtractModeColors() {
    fill(eraseModeColorFill);
    stroke(eraseModeColorStroke);
  }

  // set fill drawing colors
  void setAddModeColors() {
    fill(fillModeColorFill);
    stroke(fillModeColorStroke);
  }

  // if useEraseMode is true, this function toggles colors to erase illustrate mode on and off. Otherwise it sets to no fill, which may be a redundant call; oh well:
  void toggleEraseMode() {
    if (useEraseMode) {
      if (inEraseMode == true) { setSubtractModeColors(); inEraseMode = false; } else { setAddModeColors(); inEraseMode = true; }
    }
  }

  // gets and returns a random X and Y translate coordinate pair (in an int[] array),
  // the values of which are may be used by the translate() function:
  int[] getRNDtranslateJitter(int X, int Y) {
    int localX = (int) random(1, X * translationJitter);
    int localY = (int) random(1, Y * translationJitter);
    //force that jitter to be negative (don't translate away from the shape; translate toward it) -- will make cut mode objects cut into other shapes more:
    localX = localX * (-1);
    localY = localY * (-1);
    int[] localXY = {localX, localY};
    return localXY;
  }
  
  // expects String with one of the values you see in the first switch case here
  int getRNDrotate(String mode) {
    int angle = 0;
    int[] directionChoices = {1, 3, 5, 7};
    int[] cardinal = {1, 3, 5, 7};
    int[] diagonal = {0, 2, 4, 6};
    int[] eight = {0, 1, 2, 3, 4, 5, 6, 7};

    switch (mode)
    {
      case "cardinal":
        directionChoices = cardinal;
        break;
      case "diagonal":
        directionChoices = diagonal;
        break;
      case "eight":
        directionChoices = eight;
        break;
      default:
        directionChoices = cardinal;
        break;
    }

    int choiceIDX = (int) random(directionChoices.length);
    int choice = directionChoices[choiceIDX];
    switch (choice)
    {
      case 0:
        angle = 45;    // as in / or NE
        break;
      case 1:
        angle = 90;      // as in - or E
        break;
      case 2:
        angle = 135;    // as in \ or SE
        break;
      case 3:
        angle = 180;      // as in | (turned around) or S
        break;
      case 4:
        angle = 225;    // as in / (turned around) or SW
        break;
      case 5:
        angle = 270;      // as in - (turned around) or W
        break;
      case 6:
        angle = 315;    // as in \ (turned around) or NW
        break;
      case 7:
        angle = 0;
        break;                     // as in | or N (don't rotate (do nothing), or rotate 360 degress, depending on your point of view. - Obi-Wan Kenobi)
    }
    return angle;
  }

  int[] RNDshape() {
// TO DO?: instead of that 6.7 constant, create and use an object variable:
    int X = (int) random(canvasLen / 6.7 * RNDshapeLenMult, canvasLen * RNDshapeLenMult);
    int Y = (int) random(canvasLen / 6.7 * RNDshapeLenMult, canvasLen * RNDshapeLenMult);
    strokeWeight(shapeStrokeWeight);  // because some shapes set that lighter, reset it
// TO DO: improve triangles (see below) and reintroduce option via random(3) on next line:
//NOTE: to have higher chance of rectangles, set N in random(N) to two or higher than the number of available choices, and it will in additional cases default to rectangle:
    int choice = (int) random(2);  // doesn't include number itself in range, zero-indexed (can have 0)
    // Yes, it's silly it chooses between 0 and 0 when that's random 1, but this is so I can make it a higher number than 1 to include shapes other than rectangles.
    switch (choice)
    {
      default:  // doubles as "case 0:" _and_ any other case (to set higher chance of rectangle by passing higher number to random()
        // one in three chance to randomly multiply X or Y by 2 to make it a longer rectangle:
        int choiceThree = (int) random(4);
        switch (choiceThree)
          {
            case 0: X = X * 2; break; case 1: Y = Y * 2; break; case 2: break; // no changes
          }
        rect(0, 0, X, Y);
        break;
      case 1:  // circle
        ellipse(0, 0, X, X);
        break;
      //case 2:  // potentially stretched "pyramid" triangle
      //  // lighter stroke weight for triangles:
      //  strokeWeight(int(shapeStrokeWeight * .8));
      //  triangle(X, Y,  (X-(X/2)), (Y-(Y/2)),  (X-X), Y);
      //  break;
//      case 3:  // right triangle
        // lighter stroke weight for triangles:
//        strokeWeight(int(shapeStrokeWeight * .8));
//        triangle(X, Y,  (X+(X/2)), (Y-(Y/2)),  (X+(X/2)), Y);
//        break;
      //OTHER CASES TO DO: long thick lines? right triangle? equilateral triangle? star? oval? diamond? trapezoid(s)? glyphs (like alphabet characters)? squiggles?
    }
    int[] sizeXY = {X, Y};
    return sizeXY;
  }
  
  void makeIrregularGeometry() {
    background(backgroundColor);
	noFill(); // will be overriden by toggleEraseMode() if useEraseMode is true
    
    // back up defaults that will be modified in the following for loop:
    float transBackup = RNDtranslateMultiplier;
    float shapeLenBackup = RNDshapeLenMult;
    int translateFromSizeXY[] = {2, 2};

    for (int k = 0; k <= iterations; k++)
    {
    // (translate center to corner and) random rotate:
    translate(width/2, height/2);
    int RNDrotateDegree = getRNDrotate("cardinal");
    rotate(radians(RNDrotateDegree));
    
    // (set erase or draw mode and) draw (and record size of shape for move to edge of shape reference)
// TO DO: figure out why this first call breaks things (if toggleEraseMode(); on the next line is uncommented):
    toggleEraseMode();	// see comments near that function
    translateFromSizeXY = RNDshape();

    // move to edge of drawn shape (and reduce multiplier for range of next shape to be drawn) (with a random lower translation range or else this will always move to corners)
    translateFromSizeXY[0] = (int) random((translateFromSizeXY[0] * .25), translateFromSizeXY[0]);
    translateFromSizeXY[1] = (int) random((translateFromSizeXY[1] * .25), translateFromSizeXY[1]);
    translate(translateFromSizeXY[0] / 2, translateFromSizeXY[1] / 2);
    RNDtranslateMultiplier *= RNDtranslateReduceMultiplier;
    RNDshapeLenMult *= RNDshapeLenReduceMultiplier;
    // add translation jitter.
    int[] transJitterXY = getRNDtranslateJitter(translateFromSizeXY[0], translateFromSizeXY[1]);
    translate(transJitterXY[0], transJitterXY[1]);

    // (set erase or draw mode and) draw another shape (and reduce yet again multiplier for range of next shape to be drawn)
    toggleEraseMode();
    int[] translateFromSizeXYtwo = RNDshape();
    RNDtranslateMultiplier *= RNDtranslateReduceMultiplier;
    RNDshapeLenMult *= RNDshapeLenReduceMultiplier;
// YES AND REDUCE AGAIN?
    // RNDtranslateMultiplier *= RNDtranslateReduceMultiplier;
    // RNDshapeLenMult *= RNDshapeLenReduceMultiplier;
    
    // move back from jitter
    translate(transJitterXY[0] * (-1), transJitterXY[1] * (-1));
    // move back from edge of next-to-last drawn shape
    translate((translateFromSizeXY[0] / 2) * (-1), (translateFromSizeXY[1] / 2) * (-1));
    // move back from center
    translate((width/2) * -1, (height/2) * -1);
// YES MOAR
    // rnd rotate again, translate same edge distance (as to first drawn shape), with new jitter? and
    // (set erase or draw mode and) draw another shape:
    // (translate center to corner to rotate--even though I could skip that by not doing the last rotate undo, I'm doing it anyway as part of new draw operation)
    translate(width/2, height/2);
    int RNDrotateDegreeAgain = getRNDrotate("cardinal");
    rotate(radians(RNDrotateDegreeAgain));
    translate(translateFromSizeXY[0] / 2, translateFromSizeXY[1] / 2);
      // MOAR JITTER? :
      int[] transJitterXYtwo = getRNDtranslateJitter(translateFromSizeXYtwo[0], translateFromSizeXYtwo[1]);
      translate(transJitterXYtwo[0], transJitterXYtwo[1]);
    toggleEraseMode();
    int[] translateFromSizeXYthree = RNDshape();
      // POST-DRAW, TRANSLATE BACK FROM MOAR JITTER? :
      translate(transJitterXYtwo[0] * (-1), transJitterXYtwo[1] * (-1));
    // (translate corner back to center again)
    translate(width/2, height/2);
    }
    
    // restore backed up defaults and set prior defaults (for erase mode, conditionally) :
    RNDtranslateMultiplier = transBackup;
    RNDshapeLenMult = shapeLenBackup;
	if (useEraseMode) { setAddModeColors(); inEraseMode = true; }
  }
}


// global random string generator function
String rndString() {
  String florf = "";
  for (int i = 0; i < 12; i++)
  {
  florf += (char) int(random(98, 123));
  }
  return florf;
}


void setup()
{
  size(1056, 816);    // use full display size--why these !same as width and height above, I don't know.
  // To generate only one image per run, uncomment the next line:
  //noLoop();
}


IrregularGeometryGenerator genOne;
void draw()
{
    // this all happens over the infinite loop which is this draw() function:
  String flarf = rndString();
    // start logging all geometry drawing as SVG; re https://processing.org/reference/libraries/svg/index.html :
  String fileNameNoExt = "rnd_irregular_geometry_gen_v" + versionString + "_iters_" + iterationsArg + "__" + flarf;
  beginRecord(SVG, fileNameNoExt + ".svg");
    // generate irregular shape! :
  genOne = new IrregularGeometryGenerator(iterationsArg);
    // contrive random string for unique file name component:
  genOne.makeIrregularGeometry();
    // save PNG image! :
  save(fileNameNoExt + ".png");
    // stop SVG logging:
 endRecord();
}
