// "By Small and Simple Things"
// Coded by Richard Alexander Hall 2019
// Generates an animated grid of playfully colored concentric nested circles or n-gons (default circles)
// which change on user click/drag. See USAGE for functionality.
//
// Pretty closely imitates art by Daniel Bartholomew, but with random generative constraints:
// https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/by-small-and-simple-things-22x30/
// re: https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/

// USAGE:
// - click or click and drag on shapes to cause them to change.
// - press the RIGHT arrow key to skip the current displayed variant.
// - press the LEFT arrow key to go back one variant (only one variant remembered).
// - if certain booleans are set true, click/drag also causes PNG/SVG image save
// (only saves first clicked frame and last frame of variant.)
// - see other global variables as documented below for other functionality.

// v1.4.3 work log:
// - FIX: if < 13.5 seconds to next variant and user interact, add 21.5 seconds 'till next variant.
// I must have deleted that line of logic with a print statement before push?! It works now.
// - ALSO on any key press.
// - addednext/previous variant display on RIGHT / LEFT arrow keypresses.
String versionString = "v1.4.3";


// TO DO: * = done, */ (or deleted / moved to work log!) = in progress
// - animation-controlling-varaible scaling up/down vs. 800 px-wide grid reference.
// - moar / different things on subsequent user interaction: color index cycle jump, bw mode, grayscale mode, toggle nGon/circle mode, size rnd? . . .
// - scale nGons to all be same area as circle with same "diameter" (apothem)? https://en.wikipedia.org/wiki/Regular_polygon#Area
// - group PShapes with children in nested shapes on render (for SVG grouping)
// - random orbits for outer and inner shapes?
// - optional randomly changing nGon sides (shapes) in nested shape init.
// - even-numbered nested shapes cut out parent shape.
// - */ drag inner circles along with outer when outer moves (use return from ~.wander())
// - move items in this list to tracker that aren't there :)
// - move initialization of these randomization controlling varaibles into initial circles grid (or circles?) function call(s)? :
// jitter_max_step_mult = random(0.002, 0.0521);
// diameter_morph_rate = random(0.009, 0.011);


// DEPENDENCY IMPORTS
import processing.svg.*;
//import gohai.simpletweet.*;


// BEGIN GLOBAL VARIABLES:
// Prismacolor marker colors array:
color[] Prismacolors = {
  #CA4587, #D8308F, #E54D93, #EA5287, #E14E6D, #F45674, #F86060,
  #D96A6E, #CA5A62, #C14F6E, #B34958, #AA4662, #8E4C5C, #8F4772,
  #934393, #AF62A2, #8D6CA9, #7F7986, #72727D, #615F6B, #62555E,
  #72646C, #745D5F, #877072, #8D6E64, #9B685D, #BD6E6B, #C87F73,
  #C97B8E, #E497A4, #F895AC, #FA9394, #F98973, #EE8A74, #FA855B,
  #FD9863, #EBB28B, #FEC29F, #F9C0BC, #F6C6D0, #F5D3DD, #F0D9DC,
  #F5DCD5, #EEE4DC, #F1E5E9, #E5E4E9, #C7C6CD, #C9CBE0, #97C1DA,
  #91BACB, #95B6BA, #A2B1A2, #BFA9A8, #CBADB1, #D1BCBD, #DEBBB3,
  #E0BFB5, #F0CCC4, #EDD6BF, #F8D9BE, #EEE2C7, #F2D8A4, #F7D580,
  #FFC874, #F5D969, #C6DD8E, #93CD87, #82B079, #36B191, #009D79,
  #009E90, #008D94, #4F8584, #618979, #59746E, #1E7C72, #367793,
  #6389AB, #7B91A2, #69A2BE, #74B3E3, #00B3DB, #4CC8D9, #7AD2E2,
  #0BBDC4, #66C7B0, #9B98A2, #AC9EB8, #B1A1C9, #A1A6D0, #C0A9BE,
  #B7A1AF, #A58E9A, #B19491, #AA8E79, #987D80, #75755C, #687B57,
  #524547, #5B4446, #574C70, #405F89, #435BA3, #33549B, #0090C7,
  #BEB27B, #ECA6B9, #EF7FAD, #E65F9F, #D13352
};

int PrismacolorArrayLength = Prismacolors.length;
boolean booleanOverrideSeed = true;    // if set to true, overrideSeed will be used as the random seed for the first displayed variant. If false, a seed will be chosen randomly.
int overrideSeed = -161287679;    // a favorite is: -161287679
int previousSeed = overrideSeed;
int seed = overrideSeed;
boolean USE_FULLSCREEN = true;  // if set to true, overrides the following values; if false, they are used:
int globalWidth = 800;
int globalHeight = 800;    // dim. of kiosk entered in SMOFA: 1080x1920. scanned 35mm film: 5380x3620
int gridNesting = 4;    // controls how many nests of circles there are for each circle on the grid. 5 hangs it. ?
GridOfNestedAnimatedShapes GridOfShapes;
int GridOfShapesNumCols;    // to be reinitialized in each loop of setup() -- for reference from other functions
int GridOfShapesNumRows;    // "
int RNDcolorIDX;    // to be used as random index from array of colors
color globalBackgroundColor;
// for "frenetic option", loop creates a list of size gridNesting (of ints) :
// IntList nestedGridRenderOrder = new IntList();    // because this list has a shuffle() member function, re: https://processing.org/reference/IntList.html
// TESTING NOTES: states to test:
// true / false for savePNGs, saveSVGs, saveEveryVariation, and (maybe--though I'm confident it works regardless) saveAllAnimationFrames, .
// START VARIABLES RELATED TO image save:
boolean savePNGs = true;  // Save PNG images or not
boolean saveSVGs = true;  // Save SVG images or not
boolean saveAllAnimationFrames = false;    // if true, all frames up to renderNtotalFrames are saved (and then the program is terminated), so that they can be strung together in a video. Overrides savePNGs state.
// NOTE: at this writing, no SVG save of every frame.
int renderNtotalFrames = 7200;    // see saveAllAnimationFrames comment
int totalFramesRendered;    // incremented during each frame of a running variation. reset at new variation.
int framesRenderedThisVariation;
boolean saveEveryVariation = true;    // Saves last frame of every variation, IF savePNGs and/or saveSVGs is (are) set to true. Also note that if saveEveryVariation is set to true, you can use doFixedTimePerVariation and a low fixedMillisecondsPerVariation to rapidly generate and save variations.
int variationNumThisRun = 0;    // counts how many variations are made during run of program.
boolean doFixedTimePerVariation = false;    // if true, each variation will display for N frames, per fixedMillisecondsPerVariation
int fixedMillisecondsPerVariation = (int) (1000 * 11.5);         // milliseconds to display each variation, if previous boolean is true
int minMillisecondsPerVariation = (int) (1000 * 16.5);      // 1000 milliseconds * 16.5 = 16.5 seconds
int maxMillisecondsPerVariation = (int) (1000 * 52);        // 1000 milliesconds * 52 = 52 seconds
int currentTimeMilliseconds;
int runSetupAtMilliseconds;     // at start of each variation, altered to cue time for next variation
String userInteractionString;   // changed to states reflecting whether user interacted with a variation or not (empty or not empty)
// END VARIABLES RELATED TO image save.
boolean estimateFPS = false;		// vestige from estimating / throttling framerate before I learned about frameRate()). Still useful for displaying time to next variation.
int estimatedFPS = 0;    // dynamically modified by program as it runs (and prints running estimatedFPS estimate), IF that afore boolean is true
// reference of original art:
// larger original grid size: 25x14, wobbly circle placement, wobbly concentricity in circles.
// smaller original grid size: 19x13, regular circle placement on grid, wobbly concentricity in circles.
// SMOFA entry configuration for the following values, for ~6' tall kiosk: 7, 21. ~4K resolution horizontally larger monitors: 14, 43
int minColumns = 2; int maxColumns = 21;
float ShapesGridXminPercent = 0.24;   // minimum diameter of circle vs. grid cell size.   Maybe best ~ .6
float ShapesGridXmaxPercent = 0.86;   // maximum ""                                       Maybe best ~ .75
int minimumNgonSides = -13;    // if negative number, that many times more circles will appear.
int maximumNgonSides = 7;    // maximum number of sides of shapes randomly chosen. Between minimum and maximum, negative numbers, 0, and 1 will be circles. 2 will be a line.
// NOTE: to control additional information contained in saved file names, see comments in the get_image_file_name_no_ext() function further below.
// for image tweets! :
//SimpleTweet simpletweet;
// END GLOBAL VARIABLES


// BEGIN GLOBAL FUNCTIONS
// To initialize and subsequently reinitialize delay to creating and animating next variant:
void setDelayToNextVariant() {
  // SETUP DELAY until this function will be called again by altering the timer control values;
  // otherwise this block here that we're running will be immediately called again (as
  // runSetupAtMilliseconds hasn't incremented) :
  if (doFixedTimePerVariation == true) {
    runSetupAtMilliseconds = currentTimeMilliseconds + fixedMillisecondsPerVariation;
  } else {
    int tmp_MS_to_add_till_next_variation = (int) random(minMillisecondsPerVariation, maxMillisecondsPerVariation);
    runSetupAtMilliseconds = currentTimeMilliseconds + tmp_MS_to_add_till_next_variation;
  }
}

// if less than short number of seconds until next variant, add that + more seconds 'till next variant
// (in circumstances where this function call will be executed) :
void addGracePeriodToNextVariant() {
  int tmp_millis = millis();
  int time_to_next_variant = runSetupAtMilliseconds - tmp_millis;
  if (time_to_next_variant < 13500) {
    runSetupAtMilliseconds += 21500;
    print("ADDED TIME to next variation because of user interaction.\n");
  }
}


// Because I want to respond to both mousePressed AND mouseDragged events, those functions can pass mouseX and mouseY to this when they are called:
void set_color_morph_mode_at_XY(int Xpos, int Ypos) {
  // collision detection of mouse x and y pos vs. center and radius of circle via this genius breath: https://happycoding.io/tutorials/processing/collision-detection ;
  // checks if distance between center of circle and mouse click is less than radius of circle. if smaller, click  was inside circle. if greater, was outside:
  for (int grid_Y = 0; grid_Y < GridOfShapesNumRows; grid_Y ++) {
    for (int grid_X = 0; grid_X < GridOfShapesNumCols; grid_X ++) {
      float circle_center_x = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].x_center;
      // I need to go home and rethink my life. Wait. I _am_ home.
      float circle_center_y = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].y_center;
      float circle_radius = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].diameter / 2;
      // if click was within radius of a circle (which will be caught in the amazing speed of
      // for loops in modern computers), activate color morph mode for that circle and all nested circles in it:
        if (dist(Xpos, Ypos, circle_center_x, circle_center_y) < circle_radius) {
        // int hooman_column = grid_X + 1; int hooman_row = grid_Y + 1;    // compensate for humans; compy starts count at 0
        //    //print("Click is within circle at row " + hooman_row + " column " + hooman_column + "!\n");
        //    // activate color morph mode on all AnimatedShapes in AnimatedShapesArray:
        for (int N = 0; N < gridNesting; N ++) {
        GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[N].color_morph_on = true;
        }
      }
    }
  }
}


// get file name without extension -- for use before image save function or alternately before svg save (add extension to returned string)
String get_image_file_name_no_ext() {
  int N_cols_tmp = GridOfShapes.cols;
  String BGcolorHex = hex(globalBackgroundColor);
  BGcolorHex = BGcolorHex.substring(2, 8);    // take the first two characters (which will, the way this is set up, be FF, for full alpha) off
  String img_file_name_no_ext =
    "By Small and Simple Things " + versionString + " seed " + seed
    // COMMENT OUT any of the below additions that you don't want in the file name,
    // un UNCOMMENT any that you do--and I strongly recommend keeping the
    // frame number and user interaction string in the file name, as this script
    // can save it when a user interacts and then also at the last frame of a
    // displayed variation before the next variation:
    // + " cols " + N_cols_tmp
    // + " bgHex " + BGcolorHex
    // + " pix " + width + "x" + height
    // + " runVariant " + variationNumThisRun
    + " frame " + framesRenderedThisVariation;
    // + userInteractionString;

  return img_file_name_no_ext;
}


// saves whatever is rendered at the moment (expects PNG or other supported raster image file name):
void save_PNG() {
  String FNNE = get_image_file_name_no_ext();
  //LOCAL FOLDER SAVE:
  saveFrame(FNNE + ".png");

  // CLOUD SAVE option one (SMOFA kiosk, Windows) :
   //saveFrame("C:\\Users\\SMOFA_guest\\Dropbox\\By_Small_and_Simple_Things__SMOFA_visitor_image_saves\\" + FNNE + ".png");

  // CLOUD SAVE option two (RAH collecting images, Mac) :
  // saveFrame("/Users/earthbound/Dropbox/small_and_simple_things_RAH_image_saves/" + FNNE + ".png");
}


// END GLOBAL FUNCTIONS


// BEGIN CLASSES
// class that contains persisting, modifiable information on a circle.
// NOTE: uses the above global Prismacolors array of colors.
class AnimatedShape {
  float x_origin;
  float y_origin;
  float x_center;
  float y_center;
  float x_wandered;
  float y_wandered;
// IN PROGRESS: reworking constructor to init animating values off multiplier of what looks good at 800 px wide, including: jitter_max_step_mult, max_jitter_dist, max_wander_dist, diameter_morph_rate, stroke_weight, additionVector. WHEN EACH OF THOSE ARE DONE, and until this consctruction project is complete, I'll add a comment with an asterisk beside each, indicating "done." astrisk/slash (*/) will mean "in progress."
  float jitter_max_step_mult;
  float max_jitter_dist;
  float max_wander_dist;    // */
  float diameter;
  float diameter_min;
  float diameter_max;
  float diameter_morph_rate;
  color stroke_color;
  int stroke_color_palette_idx;
  float stroke_weight;
// TO DO? animate stroke weight?
  color fill_color;
  int fill_color_palette_idx;
  int milliseconds_elapse_to_color_morph;
  int milliseconds_at_last_color_change_elapsed;
  boolean color_morph_on;
  PVector baseVector;
  PVector additionVector;   // */
  //FOR NGON:
  int sides;
  PShape nGon;
  PVector radiusVector;    // used to construct the nGon
  float reference_scale = 800;  // DON'T CHANGE THIS hard-coded value. But if you do :) note that it affects speeds / distances of animation.
  float scale_mult;       // used to scale all animation variables vs. 800px wide grid reference to which hard-coded values were visually tuned. Because the circles vary in size as the program runs, if animation increments are constant, things move relatively "faster" when circles are smaller. This multiplier throttles those values up or down so that animation has the same relative distances/speeds as circles grow/shrink. IT WILL BE FIGURED FROM diameter_max.

  // class constructor--sets random diameter and morph speed values from passed parameters;
  // IF nGonSides is 0, we'll know it's intended to be a circle:
  AnimatedShape(int xCenter, int yCenter, float diameterMin, float diameterMax, int sidesArg) {
    x_origin = xCenter; y_origin = yCenter;
    x_center = xCenter; y_center = yCenter;
    diameter_min = diameterMin; diameter_max = diameterMax;
    diameter = random(diameterMin, diameterMax);
    diameter_morph_rate = random(0.001, 0.00205);
    //randomly make that percent positive or negative to start (which will cause grow or expand animation if used as intended) :
    int RNDtrueFalse = (int) random(0, 2);  // gets random 0 or 1
    if (RNDtrueFalse == 1) {
      diameter_morph_rate *= (-1);
    }  // flips it to negative if RNDtrueFalse is 1
    jitter_max_step_mult = random(0.002, 0.038);  // remember subtle values I like the results of: random(0.002, 0.058) -- for smaller circles. For YUGE: 0.002, 0.038
    max_jitter_dist = diameter * jitter_max_step_mult;
    max_wander_dist = diameter * 0.032;   // MAYBE TO DO: set that in logic elsewhere in this script (when setting up grid of animated shapes?) using these circles, to: (outer_circle_diameter - inner_circle_diameter)   -- outer circle being circle this one may be within.
    // set RND stroke and fill colors:
    int RNDarrayIndex = (int)random(PrismacolorArrayLength);
    stroke_color = Prismacolors[RNDarrayIndex];
    stroke_color_palette_idx = RNDarrayIndex;
    stroke_weight = random(diameter_max * 0.0064, diameter_max * 0.0307);   // have tried as high as 0.042 tweaked up from v.1.3.6 size: 0.028
    RNDarrayIndex = (int)random(PrismacolorArrayLength);
    fill_color = Prismacolors[RNDarrayIndex];
    fill_color_palette_idx = RNDarrayIndex;
    //TO DO? : control the folling rnd range with parameters?
    milliseconds_elapse_to_color_morph = (int) random(42, 111);    // on more powerful hardware, 194 is effectively true with no throttling of this.
    milliseconds_at_last_color_change_elapsed = millis();
    color_morph_on = false;
    baseVector = new PVector(x_center, y_center);
    additionVector = getRandomVector();
    // FOR NGON: conditionally alter number of sides:
    if (sidesArg < 3 && sidesArg > 0) { sidesArg = 3; }   // force triangle if 1 or 2 "sides"
    // if sidesArg is negative number, don't worry about changing it--it will be interpreted as a circle. Unless I change that? :
    sides = sidesArg;
    radiusVector = new PVector(0, (diameter / 2 * (-1)) );    // This init vector allows us to construct an n-gon with the first vertex at the top of a conceptual construction circle
    // if "sides" is a negative number, I think an empty shape is built? -- because the for loop won't trigger (i > sides)? :
    nGon = createShape();
    nGon.beginShape();
    float angle_step = 360.0 / sides;
    for (int i = 0; i < sides; i ++) {
      nGon.vertex(radiusVector.x, radiusVector.y);
      radiusVector.rotate(radians(angle_step));
    }
    //turns n-gons with one side that isn't parallel with horizontal so they are:
    int two_division_remainder = sides % 2;
    if (two_division_remainder == 0) { nGon.rotate(radians(angle_step / 2)); }
    nGon.endShape(CLOSE);
  }

  // member functions
  void morphDiameter() {
    // constrains a value to not exceed a maximum and minimum value; re: https://processing.org/reference/constrain_.html
    // constrain(amt, low, high)
    // grow diameter (positive or negative) :
        float old_diameter = diameter;  // for later reference in scaling nGon
    diameter = diameter + (diameter * diameter_morph_rate);
    // if diameter is at min or max, alter the grow rate to positive or negative (depending):
    diameter = constrain(diameter, diameter_min, diameter_max);
    if (diameter == diameter_max) {
      diameter_morph_rate *= (-1);
    }
    if (diameter == diameter_min) {
      diameter_morph_rate *= (-1);
    }
        float percent_change_multiplier = diameter / old_diameter;
    nGon.scale(percent_change_multiplier);
  }

  void jitter() {
    max_jitter_dist = diameter * jitter_max_step_mult;
    // SETUP x AND y ADDITION (positive or negative) of morph coordinate:
    x_wandered = x_wandered + ((int) random(max_jitter_dist * (-1), max_jitter_dist));
    y_wandered = y_wandered + ((int) random(max_jitter_dist * (-1), max_jitter_dist));
    // ACTUAL COORDINATE MORPH but constrained:
    x_center = x_origin + x_wandered;
    x_center = constrain(x_center, (int) x_origin + (max_jitter_dist / 2) * (-1), (int) x_origin + (max_jitter_dist / 2));
    // UND MORPH UND constrained:
    y_center = y_origin + y_wandered;
    y_center = constrain(y_center, (int) y_origin + (max_jitter_dist / 2) * (-1), (int) y_origin + (max_jitter_dist / 2));
  }

// Java (Processing) always passes by value (makes a copy of a paremeter
// passed to a function), so we just create and get new things with this function
// (as it won't work directly on the values of anything we decided to pass
// to the function if we coded it that way, which would mean copying twice == less efficient) :
  PVector getRandomVector() {
    float vector_x = random(-0.583, 0.584);
    float vector_y = random(-0.583, 0.584);
    PVector a = new PVector(vector_x, vector_y);
    // if a.x and a.y are both 0, that means no motion--which we don't want; so:
    // randomize again--by calling this function itself--meta! :
    while (a.x == 0 && a.y == 0) {
      a = getRandomVector();
    }
    return a;
  }

  PVector wander() {
    PVector vector_to_return = new PVector(0,0);    // will be northing unless changed
    x_center = baseVector.x; y_center = baseVector.y;
    float wandered_distance = dist(x_origin, y_origin, x_center, y_center);
    if (wandered_distance > max_wander_dist) {
      baseVector.sub(additionVector);      // undo add
//NOTE: if the following allows angles too near 90, collissions happen before they happen, and freaky atomic jitter results:
      float rotation_angle = random(130, 230);
      //float rotation_angle = random(-11, 12);
      additionVector.rotate(radians(rotation_angle));
    } else {
      baseVector.add(additionVector);
      vector_to_return = additionVector;
    }
    return vector_to_return;
  }

//  void orbit() {
// ?? :
//see vector_rotation.pde
//  }

  void morphColor() {
    int localMillis = millis();
    if ((localMillis - milliseconds_at_last_color_change_elapsed) > milliseconds_elapse_to_color_morph && color_morph_on == true) {
      // morph stroke color:
      stroke_color_palette_idx += 1;
      if (stroke_color_palette_idx >= PrismacolorArrayLength) {
        stroke_color_palette_idx = 0;
      }    // reset that if it went out of bounds of array indices
      stroke_color = Prismacolors[stroke_color_palette_idx];
      // morph fill color:
      fill_color_palette_idx += 1;
      if (fill_color_palette_idx >= PrismacolorArrayLength) {
        fill_color_palette_idx = 0;
      }        // also reset that if it was out of bounds
      fill_color = Prismacolors[fill_color_palette_idx];
      milliseconds_at_last_color_change_elapsed = millis();
    }
  }

  void drawShape() {
// TO DO: black and white mode that conditionally skips color functions here:
    if (sides > 2) {    // as manipulated by constructor logic, this will mean an nGon, so render that:
      nGon.setFill(fill_color);
      nGon.setStrokeWeight(stroke_weight * 1.3);    // * more because it just seems to be better as heavier for nGons than circles.
      nGon.setStroke(stroke_color);  // can not has float but global stroke weight can why?
      shape(nGon, x_center, y_center);
    }
    else {    // otherwise it's a circle, so render that:
      stroke(stroke_color);
      strokeWeight(stroke_weight);
      fill(fill_color);
      ellipse(x_center, y_center, diameter, diameter);
    }
  }
}


class NestedAnimatedShapes {
  int nesting;
  AnimatedShape[] AnimatedShapesArray;
// TO DO: declare and init as PShape with children (for svg grouping on svg save) :
  // PShape nestedShapes;

  // class constructor: same as for AnimatedShape but adding int nesting to start of list:
  NestedAnimatedShapes(int xCenter, int yCenter, float RND_min_diameter_mult, float RND_max_diameter_mult, int nGonSides, int nestingArg) {

    nesting = nestingArg;
    AnimatedShapesArray = new AnimatedShape[nesting];
    float donwMultiplyConstantMin = 0.67; float downMultiplyConstantMax = 0.92;
    // float percentOfMinDiameterToMax = RND_min_diameter_mult / RND_max_diameter_mult;


    // PRE-DETERMINE diameter/apothem ("diameter" / 2) sizes for an array of animated shapes.
    // Then pass them as max and min radius for each shape as we build the array of shapes.
    // METHOD: get a fixed number of random numbers from a range divided by an interval, descending.
    // (for nested circle diameters)
    int interval = nesting + 4;    // divide min and max possible radius by how many intervals to determine size slices?
    float dividend = (RND_max_diameter_mult - RND_min_diameter_mult) / interval;
    int radii_to_get = nesting + 1;   // or the last circle will have no min. radius!
    int low_range_excluder = radii_to_get;
    int selected = interval;    // a lie to start with but starts the loop as we wish
    // YARP:
              // print("~-~-\n");
    float[] radii = new float[radii_to_get];
    for (int i = 0; i < radii_to_get; i++) {
               //print("sel. range: " + low_range_excluder + ":" + selected + " ");
      int selected_num = (int) random(low_range_excluder, selected + 1);
      float result_num = RND_min_diameter_mult + (selected_num * dividend);
      radii[i] = result_num;
               //print("--selected: " + selected_num + " --dividend: " + dividend + " * selected is: " + result_num + "\n");
      selected = selected_num - 1;
      low_range_excluder -= 1;
    }
    //debug print (lower index numbers have higher values indeed as intended) :
    //for (int j = 0; j < radii.length; j++) { print("radii[" + j + "]: " + radii[j] + "\n"); }
    // END PRE-DETERMINE diameter/apothem sizes.



    for (int i = 0; i < nesting; i++) {
      // tried using this instead of nGonSides; maybe it will be more impressive with random shape orientation / spin? But for now, nah:
      // int rnd_meta_nGonSides = (int) random(0, nGonSides + 1);    // sometimes this will be "random" between 0 and 0. Whatever.
      AnimatedShapesArray[i] = new AnimatedShape(
        xCenter,
        yCenter,
        //RND_min_diameter_mult,
        //RND_max_diameter_mult,
        radii[i+1],
        radii[i+1],
        nGonSides
      );
          // SHRINK MIN AND MAX so next iteration will have smaller shape.
          // OPTION ONE:
          // Make old minimum new maximum, and new minimum from min. multiplier vs. that new max
          // (or percentOfMinDiameterToMax) :
    RND_max_diameter_mult = RND_min_diameter_mult;
    RND_min_diameter_mult *= donwMultiplyConstantMin;
          // OR:
          // OPTION TWO: min and max down-multiplied by a constant, which results in inner shapes
          // sometimes having a diameter (allowed max) greater than out shape minimum size. This
          // is more visually interesting in terms of animation, and at first I thought it broke
          // random vector movement of shapes, but is seems not to.
    // RND_min_diameter_mult *= donwMultiplyConstantMin;
    // RND_max_diameter_mult *= downMultiplyConstantMax;
    }
  }

  void drawAndChangeNestedShapes() {
    for (int j = 0; j < nesting; j++) {
      AnimatedShapesArray[j].drawShape();
      AnimatedShapesArray[j].morphDiameter();
      AnimatedShapesArray[j].jitter();
      AnimatedShapesArray[j].wander();
      // UNCOMMENT FOR COLOR MORPHING, which makes it freaking DAZZLING, if I may say so:
      AnimatedShapesArray[j].morphColor();
    }
  }

}


// class that contains information for a grid of shapes.
class GridOfNestedAnimatedShapes {
  int graph_xy_len;
  int cols;
  int rows;
  NestedAnimatedShapes ShapesGridOBJ[][];
  int grid_to_canvas_x_offset;
  int grid_to_canvas_y_offset;

  // class constructor
  GridOfNestedAnimatedShapes(int canvasXpx, int canvasYpx, int passedColumns, float RND_min_diameter_multArg, float RND_max_diameter_multArg, int nestingArg) {
    graph_xy_len = canvasXpx / passedColumns;   // it seems this discards any remainder if it divides unevenly.
    cols = passedColumns;
    rows = canvasYpx/graph_xy_len;
    //information and a standard (to Processing) function call that will center the grid on the canvas:
    int canvasToGridXremainder = canvasXpx - (cols * graph_xy_len);   // gets us the earlier discarded remainder
    grid_to_canvas_x_offset = canvasToGridXremainder / 2;
    int canvasToGridYremainder = canvasYpx - (rows * graph_xy_len);
    grid_to_canvas_y_offset = canvasToGridYremainder / 2;
    ShapesGridOBJ = new NestedAnimatedShapes[rows][cols];
    // int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 0; i < ShapesGridOBJ.length; i++) {          // that comparison measures first dimension of array ( == cols)
      for (int j = 0; j < ShapesGridOBJ[0].length; j++) {    // that comparision measures second dimension of array ( == rows)
        // OY the convolution of additional offests just to make a grid centered! :
        int circleLocX = ((graph_xy_len * j) - (int) graph_xy_len / 2) + grid_to_canvas_x_offset + graph_xy_len;
        int circleLocY = ((graph_xy_len * i) - (int) graph_xy_len / 2) + grid_to_canvas_y_offset + graph_xy_len;
        int rnd_num = (int) random(minimumNgonSides, maximumNgonSides + 1);
        float minDiam = graph_xy_len * RND_min_diameter_multArg;
        float maxDiam = graph_xy_len * RND_max_diameter_multArg;
        ShapesGridOBJ[i][j] = new NestedAnimatedShapes(circleLocX, circleLocY, minDiam, maxDiam, rnd_num, nestingArg);    // I might best like: 1, 8
      }
    }
  }

  void ShapesGridDrawAndChange() {
    //int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        fill(255);
        //stroke(255,0,255);
        ShapesGridOBJ[i][j].drawAndChangeNestedShapes();
        fill(0);
        //counter += 1;
        // debug numbering print of circles:
        //text(counter, ((graph_xy_len * j) - (int) graph_xy_len / 2) + graph_xy_len, ((graph_xy_len * i) - graph_xy_len / 2) + graph_xy_len);
      }
    }
  }
}
// END CLASSES




// BEGIN MAIN FUNCTIONS
void settings() {
  // SEE these controlling variables in the global variables section near start of script:
  if (USE_FULLSCREEN == true) {
    fullScreen();
  } else {
    size(globalWidth, globalHeight);
  }

  // initializes runSetupAtMilliseconds before draw() is called:
  setDelayToNextVariant();
}


boolean runSetup = false;                      // Controls when to run setup() again. Manipulated by script logic.
boolean savePNGnow = false;                    // Controls when to save PNGs. Manipulated by script logic.
boolean recordSVGnow = false;                  // Controls when to save SVGs. Manipulated by script logic.
boolean userInteractedThisVariation = false;   // affects those booleans via script logic.
// handles values etc. for new animated variation to be displayed:
void setup() {
  //simpletweet = new SimpleTweet(this);
  //simpletweet.setOAuthConsumerKey("");
  //simpletweet.setOAuthConsumerSecret("");
  //simpletweet.setOAuthAccessToken("");
  //simpletweet.setOAuthAccessTokenSecret("");

  // uncomment if u want to throttle framerate--RECOMMENDED or
  // a fast CPU will DO ALL THE THINGS TOO MANY TOO FAST and heat up--
  // also it will make for properly timed animations if you save all frames to PNGs or SVGs:
  frameRate(30);

  if (booleanOverrideSeed == true) {
    seed = previousSeed;
    booleanOverrideSeed = false;
  } else {
    previousSeed = seed;
    seed = (int) random(-2147483648, 2147483647);
  }
  randomSeed(seed);

  variationNumThisRun += 1;
  //print("~-~- Setting up variation number " + variationNumThisRun + " in run. Seed: " + seed + " -~-~\n");

  ellipseMode(CENTER);

  // Randomly change the background color to any color from the Prismacolor array OR black OR white at each run:
  RNDcolorIDX = (int)random(PrismacolorArrayLength + 2);
  // I can't use a switch because of requirement that cases be constant expressions, so:
  if (RNDcolorIDX == PrismacolorArrayLength) {    // confusingly, that actually means what results from the (PrismacolorArrayLength + 1) max range (as random doesn't include max range)
    globalBackgroundColor = color(0);    // black
  } else {
    if (RNDcolorIDX == PrismacolorArrayLength + 1) {
      globalBackgroundColor = color(255);    // white
    } else {   // all other cases, use whatever rnd idx was chosen in the range 0 - length of array:
      globalBackgroundColor = Prismacolors[RNDcolorIDX];
    }
  }
  // To always have N circles accross the grid, uncomment the next line and comment out the line after it. For random between N and N-1, comment out the next line and uncomment the one after it.
  // int gridXcount = 19;  // good values: any, or 14 or 19
  int gridXcount = (int) random(minColumns, maxColumns + 1);  // +1 because random doesn't include max range. Also, see comments where those values are set.

  GridOfShapes = new GridOfNestedAnimatedShapes(width, height, gridXcount, ShapesGridXminPercent, ShapesGridXmaxPercent, gridNesting);

  GridOfShapesNumCols = GridOfShapes.cols;
  GridOfShapesNumRows = GridOfShapes.rows;

  // for "frenetic option" :
  //for (int x = 0; x < gridNesting; x++) {
  //  nestedGridRenderOrder.append(x);
  //  //print(x + "\n");
  //}

  userInteractionString = "";
  framesRenderedThisVariation = 0;  // reset here and incremented in every loop of draw()
  runSetup = false;
  savePNGnow = false;
  recordSVGnow = false;
  userInteractedThisVariation = false;

  // to produce one static image, uncomment the next function:
  //noLoop();
}


// DOES ALL THE THINGS for one frame of animation:
void animate() {

  // SVG RECORD, CONDITIONALLY:
  if (recordSVGnow == true) {
    String svg_file_name_no_ext = get_image_file_name_no_ext();
    beginRecord(SVG, svg_file_name_no_ext + ".svg");
  }

  background(globalBackgroundColor);  // clears canvas to white before next animaton frame (so no overlap of smaller shapes this frame on larger from last frame) :

  // randomizes list--for frenetic option (probably will never want) :
  //nestedGridRenderOrder.shuffle();
  //println(nestedGridRenderOrder);

  GridOfShapes.ShapesGridDrawAndChange();

  if (recordSVGnow == true) {
    endRecord();
    recordSVGnow = false;
  }

  totalFramesRendered += 1;
  framesRenderedThisVariation += 1;   // this is reset to 0 at every call of setup()

  // conditionally calculate and print running display of frames per second.
  if (estimateFPS == true) {
    int current_millis = millis();
    if (current_millis - last_captured_millis > 999) {
      estimatedFPS = totalFramesRendered - last_captured_totalFramesRendered;
      int countdown_to_next_render = runSetupAtMilliseconds - current_millis;
      print("Estimated frames per second: " + estimatedFPS + ". total frames rendered: " + totalFramesRendered + ". Next variation in " + countdown_to_next_render + "ms\n");
      //reset these values or this won't work:
      last_captured_millis = current_millis;
      last_captured_totalFramesRendered = totalFramesRendered;
    }
  }
}


int last_captured_millis = 0;
int last_captured_totalFramesRendered = 0;
void draw() {

  // SAVE SVG FRAME AS PART OF ANIMATION FRAMES conditioned on boolean:
  if (saveAllAnimationFrames == true && saveSVGs == true) { beginRecord(SVG, "_anim_frames/#######.svg"); }
  animate();
  if (saveAllAnimationFrames == true && saveSVGs == true) { endRecord(); }

  // SAVE PNG FRAME AS PART OF ANIMATION FRAMES conditioned on boolean:
  if (saveAllAnimationFrames == true && savePNGs == true) {
    saveFrame("_anim_frames/#######.png");
    if (totalFramesRendered == renderNtotalFrames) {
      exit();
    }
  }

  // NOTE: runSetupAtMilliseconds (on which this block depends) is initialized in settings() :
  currentTimeMilliseconds = millis();
  if (currentTimeMilliseconds >= runSetupAtMilliseconds) {
    // IF WE DON'T DO THE FOLLOWING, this block here is invoked immediately in the
    // next loop of draw() (which we don't want to happen) :
    setDelayToNextVariant();
    // this captures PNG if boolean controlling says do so, before next variant starts via setup() :
    if (saveEveryVariation == true && savePNGs == true) {
      save_PNG();
    }
    // captures SVG if boolean controlling says to:
    if (saveEveryVariation == true && saveSVGs == true) {
      noLoop();
      recordSVGnow = true;
      animate();
      loop();
    }
    runSetup = true;
  }

  if (runSetup == true) {
    setup();
  }
}


void mousePressed() {
  set_color_morph_mode_at_XY(mouseX, mouseY);
  userInteractionString = "__user_interacted";    // intended use by other functions / reset to "" by other functions

  if (userInteractedThisVariation == false) {    // restricts the functionality in this block to once per variation
    // (because setup(), which is called every variation, sets that false)
    //save PNG on click, conditionally:
    if (savePNGs == true) {
      save_PNG();
    }
    // save SVG on click, conditionally:
    if (saveSVGs == true) {
      noLoop();
      recordSVGnow = true;
      animate();
      loop();
    }
    userInteractedThisVariation = true;
  }

  //String fileNameNoExt = get_image_file_name_no_ext();
  //String tweet = simpletweet.tweetImage(get(), fileNameNoExt + " saved via visitor interaction at Springville Museum of Art! More visitor images at: http://s.earthbound.io/BSaST #generative #generativeArt #processing #processingLanguage #creativeCoding");
  //println("Posted " + tweet);
  addGracePeriodToNextVariant();
}


void mouseDragged() {
  set_color_morph_mode_at_XY(mouseX, mouseY);
}


void keyPressed() {
  // if user presses left arrow key, go back to previous variant:
  if (keyCode == LEFT) {
    booleanOverrideSeed = true;
    runSetupAtMilliseconds = 0;
  }
  // if user presses right arrow key, skip this variant:
  if (keyCode == RIGHT) {
    // booleanOverrideSeed = false;
    runSetupAtMilliseconds = 0;
  }

  // Is there a more elegant way to do this where switches aren't available?
  // If I add more key responses above, I have to add them here:
  if (keyCode != LEFT && keyCode != RIGHT) {
    addGracePeriodToNextVariant();
  }
}
