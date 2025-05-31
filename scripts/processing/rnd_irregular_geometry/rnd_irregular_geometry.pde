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
// - when I open output SVGs from this in an SVG editor it shows multiple objects I didn't know about, out of the viewing area?! Fix??
// - figure out what I was trying to "fix" in corrected_rnd_irregular_geometry.pde (I think not this issue?!) and fix that and patch it into this?
// - N random generations for every random palette (from API) retrieval, instead of a new palette retrieval for every generation?
// - parameter control of iterations
// - equilateral properly center-reference drawn triangle option (unpredictable triangle option commented out for now)
// - random repeat translate from 1-3
// - that with repeat shape or alterante shape

// v0.9.17 changes:
// - option to set palette from a web API that provides colors in a structure this script translates, hard-coded to use API, with fallback to hard-coded colors.
// - change Prismacolor markers array (palette) to soil pigments
String versionString = "0.10.42";

// DEPENDENCY INCLUDE
import processing.svg.*;

// GLOBALS
int iterationsArg = 2;    // controls how many subsequently smaller shape arrangements to make.
color backgroundColor = #524547;  // Prismacolor Black
// color backgroundColor = #FFFFFF;
// if set to true, the generator will attempt to use an API which gives a randomly selected color palette, with fallback to use a hard-coded fallback colorful set. If set to false, hard-coded more muted colors will be used:
boolean RNDcolorMode = true;

// from Soil_Pigments.hexplt:
color[] FallbackColors = {
  #382F2A, #673D2E, #713820, #763436, #9B4831, #8E5237, #A26F3E, #BD8A58,
  #CD844B, #DCA651, #EEC382, #DEC6A6, #D7C7B0, #9E9287, #7E7A6D, #A39461
};
// URL for random color palette selection API:
String apiURL = "https://earthbound.io/data/random_ebPalette/";


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
  color eraseModeColorFill;
  color eraseModeColorStroke;
  color fillModeColorFill;
  color fillModeColorStroke;
  color[] Colors;
  int ColorsArrayLength;

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
    // TO DO: override these when RNDcolorMode is true? Just set them somewhere else one way or the other?
    eraseModeColorStroke = #615F6B;      // Prismacolor cool grey 90%
    eraseModeColorFill = #524547;      // Prismacolor black
    fillModeColorFill = #FFFFFF;
    fillModeColorStroke = #524547;      // Prismacolor black
    rectMode(CENTER);
    ellipseMode(CENTER);
  }

  // Function to set colors, retrieving from API or using fallback
  void setColorPalette() {
    if (RNDcolorMode) {
      print("Attempting to retrieve colors from API..\n");
      Thread t = new Thread(new Runnable() {
        public void run() {
          try {
            JSONObject json = loadJSONObject(apiURL);
            JSONArray colorArray = json.getJSONArray("colors");
            print("Extracted colors array: " + colorArray + "\n");
            Colors = new color[colorArray.size()];
            for (int i = 0; i < colorArray.size(); i++) {
              Colors[i] = color(unhex("FF" + colorArray.getString(i).substring(1)));
            }
          } catch (Exception e) {
            println("API fetch failed or timed out. Using fallback colors.");
            Colors = FallbackColors;
          }
        }
      });
      t.start();
      try {
        t.join(7000); // Wait up to 7 seconds
      } catch (InterruptedException e) {
        println("Timeout reached. Using fallback colors.");
        Colors = FallbackColors;
      }
    } else {
      Colors = FallbackColors;  // Fallback colors if RNDcolorMode is false
    }
    ColorsArrayLength = Colors.length;
  }

  void setRNDcolors() {
    // conditional shape etc. rnd color fill change
    // color strokeColor = Colors[RNDarrayIndex];
    // stroke(strokeColor);
    // color fillColor = Colors[RNDarrayIndex];
    // fill(fillColor);
    int RNDarrayIndex = (int)random(ColorsArrayLength);
    eraseModeColorStroke = Colors[RNDarrayIndex];
    RNDarrayIndex = (int)random(ColorsArrayLength);
    eraseModeColorFill = Colors[RNDarrayIndex];
    RNDarrayIndex = (int)random(ColorsArrayLength);
    fillModeColorFill = Colors[RNDarrayIndex];
    RNDarrayIndex = (int)random(ColorsArrayLength);
    fillModeColorStroke = Colors[RNDarrayIndex];
    RNDarrayIndex = (int)random(ColorsArrayLength);
    // TO DO: a dirty hack to make the background very slightly darker in case it happens to be a randomly selected duplicate of a fill color? : substract 5 from all color channels:
    // assigning to a global here:
    RNDarrayIndex = (int)random(ColorsArrayLength);
    backgroundColor = Colors[RNDarrayIndex];
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
  // the values of which may be used by the translate() function:
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
    if (RNDcolorMode == true) {
      setColorPalette();
      setRNDcolors();
    }

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

int ColorsArrayLength;
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
