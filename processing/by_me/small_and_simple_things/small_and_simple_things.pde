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

// v1.5.0 work log:
// - constrain shapes within boundaries of other shapes via a bit o' algebra; means:
// - improved wander/jitter restrict: intra-shape collision detection/wrangling to stay in
// - fix loop counting bug (redundancy) in implementing that
// - add functions assisting with collision / distance detect
// - add to do items for simpler code
// - comment out jitter
String versionString = "v1.5.0";


// TO DO: * = done, */ (or deleted / moved to work log!) = in progress
// - animation-controlling-varaible scaling up/down vs. 800 px-wide grid reference.
// - moar / different things on subsequent user interaction: color index cycle jump, bw mode, grayscale mode, toggle nGon/circle mode, size rnd? . . .
// - scale nGons to all be same area as circle with same "diameter" (apothem)? https://en.wikipedia.org/wiki/Regular_polygon#Area
// - group PShapes with children in nested shapes on render (for SVG grouping)
// - constraint-free mode (all shapes wander on initial vector without bouncing back)
// - random orbits for outer and inner shapes?
// - optional randomly changing nGon sides (shapes) in nested shape init.
// - option: even-numbered nested shapes cut out parent shape.
// - change all x y coordinate pair variables to PVectors
// - move items in this list to tracker that aren't there :)
// - move initialization of these randomization controlling varaibles into initial shapes grid (or circles?) function call(s)? :
// jitter_max_step_mult = random(0.002, 0.0521);
// diameter_morph_rate = random(0.009, 0.011);


// DEPENDENCY IMPORTS
import processing.svg.*;
//import gohai.simpletweet.*;


// BEGIN GLOBAL VARIABLES:
// NOTE: to control additional information contained in saved file names, see comments in the get_image_file_name_no_ext() function further below.
boolean booleanOverrideSeed = false;    // if set to true, overrideSeed will be used as the random seed for the first displayed variant. If false, a seed will be chosen randomly.
int overrideSeed = -161287679;    // a favorite is: -161287679
int previousSeed = overrideSeed;
int seed = overrideSeed;
boolean USE_FULLSCREEN = true;  // if set to true, overrides the following values; if false, they are used:
int globalWidth = 800;
int globalHeight = 800;    // dim. of kiosk entered in SMOFA: 1080x1920. scanned 35mm film: 5380x3620
int gridNesting = 4;    // controls how many nests of shapes there are for each shape on the grid. 5 hangs it. ?
GridOfNestedAnimatedShapes GridOfShapes;
int GridOfShapesNumCols;    // to be reinitialized in each loop of setup() -- for reference from other functions
int GridOfShapesNumRows;    // "
int RNDbgColorIDX;    // to be used as random index from array of colors
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
// SMOFA entry configuration for the following values, for ~6' tall kiosk: 1, 21? ~4K resolution horizontally larger monitors: 14, 43
int minColumns = 2; int maxColumns = 21;
float ShapesGridXminPercent = 0.24;   // minimum diameter/apothem of shape vs. grid cell size.   Maybe best ~ .6
float ShapesGridXmaxPercent = 0.86;   // maximum ""                                       Maybe best ~ .75
int minimumNgonSides = -13;    // if negative number, that many times more circles will appear.
int maximumNgonSides = 7;    // maximum number of sides of shapes randomly chosen. Between minimum and maximum, negative numbers, 0, and 1 will be circles. 2 will be a line.
// Prismacolor marker colors array:
color[] backgroundColors = {
	#CA4587, #D8308F, #E54D93, #EA5287, #E14E6D, #F45674, #F86060, #D96A6E,
	#CA5A62, #C14F6E, #B34958, #AA4662, #8E4C5C, #8F4772, #934393, #AF62A2,
	#8D6CA9, #72727D, #615F6B, #62555E, #745D5F, #877072, #8D6E64, #9B685D,
	#A45A52, #BD6E6B, #C87F73, #C97B8E, #E497A4, #F895AC, #FA9394, #F98973,
	#EE8A74, #FA855B, #FD9863, #EBB28B, #FEC29F, #F9C0BC, #F6C6D0, #F5D3DD,
	#F0D9DC, #F5DCD5, #F0CCC4, #E0BFB5, #F8D9BE, #EEE2C7, #F2D8A4, #FADFA7,
	#F7D580, #FFC874, #FDFD96, #F5FFA1, #F0FFF0, #FFFFFF, #E0FFFF, #E5E4E9, #F1E5E9,
	#C7C6CD, #C9CBE0, #97C1DA, #91BACB, #95B6BA, #A2B1A2, #BFA9A8, #B7A1AF,
	#AC9EB8, #B1A1C9, #A1A6D0, #9B98A2, #A58E9A, #B19491, #7B91A2, #6389AB,
	#69A2BE, #74B3E3, #00B3DB, #4CC8D9, #7AD2E2, #93EDF7, #00FFEF, #7FFFD4,
	#88D8C0, #93CD87, #82B079, #00A86B, #009B7D, #00A693, #36B191, #0BBDC4,
	#008D94, #4F8584, #1E7C72, #59746E, #367793, #405F89, #435BA3, #33549B,
	#3344EF, #333388, #333366, #333351, #003153, #002147, #000000, #32127A, #574C70,
	#524547, #414141, #79443B, #4E1609, #C23B22, #EF3312, #FD0E35, #D13352,
	#E323DB, #2E8B57, #73ED91, #00FA9A, #A1FA2A, #7EF100
};
int backgroundColorsArrayLength = backgroundColors.length;
color[] fillColors = {
	#CA4587, #D8308F, #E54D93, #EA5287, #E14E6D, #F45674, #F86060, #D96A6E,
	#CA5A62, #C14F6E, #B34958, #AA4662, #8E4C5C, #8F4772, #934393, #AF62A2,
	#8D6CA9, #72727D, #615F6B, #62555E, #745D5F, #877072, #8D6E64, #9B685D,
	#A45A52, #BD6E6B, #C87F73, #C97B8E, #E497A4, #F895AC, #FA9394, #F98973,
	#EE8A74, #FA855B, #FD9863, #EBB28B, #FEC29F, #F9C0BC, #F6C6D0, #F5D3DD,
	#F0D9DC, #F5DCD5, #F0CCC4, #E0BFB5, #F8D9BE, #EEE2C7, #F2D8A4, #FADFA7,
	#F7D580, #FFC874, #FDFD96, #F5FFA1, #F0FFF0, #E0FFFF, #E5E4E9, #F1E5E9,
	#C7C6CD, #C9CBE0, #97C1DA, #91BACB, #95B6BA, #A2B1A2, #BFA9A8, #B7A1AF,
	#AC9EB8, #B1A1C9, #A1A6D0, #9B98A2, #A58E9A, #B19491, #7B91A2, #6389AB,
	#69A2BE, #74B3E3, #00B3DB, #4CC8D9, #7AD2E2, #93EDF7, #00FFEF, #7FFFD4,
	#88D8C0, #93CD87, #82B079, #00A86B, #009B7D, #00A693, #36B191, #0BBDC4,
	#008D94, #4F8584, #1E7C72, #59746E, #367793, #405F89, #435BA3, #33549B,
	#3344BB, #333388, #333366, #333351, #003153, #002147, #32127A, #574C70,
	#524547, #414141, #79443B, #4E1609, #2E8B57, #73ED91, #00FA9A
};
int fillColorsArrayLength = fillColors.length;
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
  if (time_to_next_variant < 13750) {
    runSetupAtMilliseconds += 28750;
    print("ADDED TIME delay until next variation because of user interaction.\n");
  }
}


// Because I want to respond to both mousePressed AND mouseDragged events, those functions can pass mouseX and mouseY to this when they are called:
void set_color_morph_mode_at_XY(int Xpos, int Ypos) {
  // collision detection of mouse x and y pos vs. center and radius of circle via this genius breath: https://happycoding.io/tutorials/processing/collision-detection ;
  // checks if distance between center of shapes and mouse click is less than radius of circle. if smaller, click  was inside circle. if greater, was outside:
  for (int grid_Y = 0; grid_Y < GridOfShapesNumRows; grid_Y ++) {
    for (int grid_X = 0; grid_X < GridOfShapesNumCols; grid_X ++) {
      float shape_center_x = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].x_center;
      // I need to go home and rethink my life. Wait. I _am_ home.
      float shape_center_y = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].y_center;
      float shape_radius = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].diameter / 2;
      // if click was within radius of a circle (or apothem of shape) (which will be caught in the amazing speed of
      // for loops in modern computers), activate color morph mode for that shape and all nested shapes in it:
        if (dist(Xpos, Ypos, shape_center_x, shape_center_y) < shape_radius) {
        // int hooman_column = grid_X + 1; int hooman_row = grid_Y + 1;    // compensate for humans; compy starts count at 0
            //print("Click is within shape at row " + hooman_row + " column " + hooman_column + "!\n");
            // activate color morph mode on all AnimatedShapes in AnimatedShapesArray:
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
     + " cols " + N_cols_tmp
     + " bgHex " + BGcolorHex
    // + " pix " + width + "x" + height
     + " frame " + framesRenderedThisVariation
     + userInteractionString;

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


// checks properties of two shapes to determine whether one is within the other and returns boolean saying which:
boolean is_shape_within_shape(PVector larger_shape_XY, float larger_shape_diameter, PVector smaller_shape_XY, float smaller_shape_diameter) {
  float centers_distance = dist(larger_shape_XY.x, larger_shape_XY.y, smaller_shape_XY.x, smaller_shape_XY.y);
  float radii_difference = (larger_shape_diameter / 2) - (smaller_shape_diameter / 2);
  boolean is_within_shape = true;
  if (centers_distance > radii_difference) { is_within_shape = false; } else { is_within_shape = true; }
  return is_within_shape;
}

// takes six values: the x and y center coordinate and diamter of a larger circle or shape
// (intended use), and the same for a smaller shape. returns a PVector which is the x and y
// coordinates to make the smaller shape interior nearest tangent to the larger shape
// (constrained within its maximum or nearest edge). Intended use: to keep shapes within
// shapes from wandering outside the shape.
PVector get_larger_to_smaller_shape_interior_tangent_PVector(
PVector larger_shape_XY, float larger_shape_diameter,
PVector smaller_shape_XY, float smaller_shape_diameter
) {
  PVector coords_to_return = new PVector(0,0);    // will be 0,0 unless changed
  boolean is_within_shape = is_shape_within_shape(larger_shape_XY, larger_shape_diameter, smaller_shape_XY, smaller_shape_diameter);
  if (is_within_shape == false) {
            // print("circle/shape is outside larger circle/shape.\n");
    float target_centers_dist = (larger_shape_diameter / 2) - (smaller_shape_diameter / 2);
    float shapes_center_to_center_dist = dist(larger_shape_XY.x, larger_shape_XY.y, smaller_shape_XY.x, smaller_shape_XY.y);
    float centers_to_target_dist_mult = target_centers_dist / shapes_center_to_center_dist;
    float Xdiff = larger_shape_XY.x - smaller_shape_XY.x;
    float Ydiff = larger_shape_XY.y - smaller_shape_XY.y;
    float newX = larger_shape_XY.x - (Xdiff * centers_to_target_dist_mult);   // a + will put it tangent opposite side
    float newY = larger_shape_XY.y - (Ydiff * centers_to_target_dist_mult);
    coords_to_return = new PVector(newX, newY);
    }
  return coords_to_return;
}


// END GLOBAL FUNCTIONS


// BEGIN CLASSES
// class that contains persisting, modifiable information on a circle.
// NOTE: uses the above global fillColors array of colors.
class AnimatedShape {
  float x_origin;
  float y_origin;
  float x_center;
  float y_center;
  float x_wandered;
  float y_wandered;
// IN PROGRESS: reworking constructor to init animating values off multiplier of what looks good at 800 px wide,
// including: jitter_max_step_mult, max_jitter_dist, max_wander_dist, diameter_morph_rate, stroke_weight, additionVector.
// WHEN EACH OF THOSE ARE DONE, and until this consctruction project is complete, I'll add a comment with an asterisk beside each,
// indicating "done." astrisk/slash (*/) will mean "in progress."
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
  float scale_mult;       // used to scale all animation variables vs. 800px wide grid reference to which hard-coded values were visually tuned. Because the shapes vary in size as the program runs, if animation increments are constant, things move relatively "faster" when shapes are smaller. This multiplier throttles those values up or down so that animation has the same relative distances/speeds as shapes grow/shrink. IT WILL BE FIGURED FROM diameter_max.

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
    jitter_max_step_mult = random(0.002, 0.0032);  // remember subtle values I like the results of: random(0.002, 0.058) -- for smaller circles/shapes. For YUGE: 0.002, 0.038
    max_jitter_dist = diameter * jitter_max_step_mult;
    max_wander_dist = diameter * 1.16;		// Only for outer circle (or shape) of nested circle (or shape).
    // set RND stroke and fill colors:
    int RNDarrayIndex = (int)random(fillColorsArrayLength);
    stroke_color = fillColors[RNDarrayIndex];
    stroke_color_palette_idx = RNDarrayIndex;
    stroke_weight = random(diameter_max * 0.0064, diameter_max * 0.0307);   // have tried as high as 0.042 tweaked up from v.1.3.6 size: 0.028
    RNDarrayIndex = (int)random(fillColorsArrayLength);
    fill_color = fillColors[RNDarrayIndex];
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
            // print("diameter:diameter_min:diameter_max: " + diameter + ":" + diameter_min + ":" + diameter_max + "\n");
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
            // print("->diameter:diameter_min:diameter_max: " + diameter + ":" + diameter_min + ":" + diameter_max + "\n");
  }

  void jitter() {
    max_jitter_dist = diameter * jitter_max_step_mult;
    // SETUP x AND y ADDITION (positive or negative) of morph coordinate:
    x_wandered = ((int) random(max_jitter_dist * (-1), max_jitter_dist));
    y_wandered = ((int) random(max_jitter_dist * (-1), max_jitter_dist));
    x_center += x_wandered;
    y_center += y_wandered;
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

  PVector wander(PVector parent_shape_XY, float parent_shape_diameter) {
    PVector vector_to_return = new PVector(0,0);    // will be northing unless changed
    // updating variable within the object this function is a part of:
    // but shouldn't I use? : translate(additionVector);
    baseVector.add(additionVector);
    x_center = baseVector.x; y_center = baseVector.y;
    // check if we just made the shape go outside its parent, and if so undo that translate:
//TO DO: update the object to use PVectors so I don't have to create this temp one (or do other redundant operations) :
    PVector this_shape_XY = new PVector(x_center, y_center);
    boolean is_shape_within_parent = is_shape_within_shape(parent_shape_XY, parent_shape_diameter, this_shape_XY, diameter);
    if (is_shape_within_parent == true) {
      vector_to_return = additionVector;
    } else {    // undo that translate, and change wander direction:
      baseVector.sub(additionVector);
//NOTE: if the following allows angles too near 90, collissions happen before they happen, and freaky atomic jitter results:
      float rotation_angle = random(130, 230);
      additionVector.rotate(radians(rotation_angle));
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
      if (stroke_color_palette_idx >= fillColorsArrayLength) {
        stroke_color_palette_idx = 0;
      }    // reset that if it went out of bounds of array indices
      stroke_color = fillColors[stroke_color_palette_idx];
      // morph fill color:
      fill_color_palette_idx += 1;
      if (fill_color_palette_idx >= fillColorsArrayLength) {
        fill_color_palette_idx = 0;
      }        // also reset that if it was out of bounds
      fill_color = fillColors[fill_color_palette_idx];
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

  void translate(PVector add) {
    x_center += add.x; y_center += add.y;
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
    // (for nested circle diameters or nested shape apothems)
    int interval = nesting + 4;    // divide min and max possible radius by how many intervals to determine size slices?
    float dividend = (RND_max_diameter_mult - RND_min_diameter_mult) / interval;
    int radii_to_get = nesting + 1;   // or the last circle/shape will have no min. radius!
    int low_range_excluder = radii_to_get;
    int selected = interval;    // a lie to start with but starts the loop as we wish
    float[] radii = new float[radii_to_get];
    for (int i = 0; i < radii_to_get; i++) {
               //print("sel. range: " + low_range_excluder + ":" + selected + " ");
      int selected_num = (int) random(low_range_excluder, selected + 1);
      float result_num = RND_min_diameter_mult + (selected_num * dividend);
      radii[i] = result_num;
      selected = selected_num - 1;
      low_range_excluder -= 1;
    }
    // END PRE-DETERMINE diameter/apothem sizes.
    for (int i = 0; i < nesting; i++) {
			// print(radii[i+1] + ":" + radii[i] + "\n");
      AnimatedShapesArray[i] = new AnimatedShape(
        xCenter,
        yCenter,
        radii[i+1],
        radii[i],
        nGonSides
      );
    }

  }

  void drawAndChangeNestedShapes() {
    for (int j = 0; j < nesting; j++) {
      AnimatedShapesArray[j].drawShape();
      AnimatedShapesArray[j].morphDiameter();
       // AnimatedShapesArray[j].jitter();    // so dang silky smooth without jitter; also maybe edge collisions are now less spastic _without_ that (the opposite case used to be).
        for (int k = j + 1; k < nesting; k++) {
          PVector tmp_vec;
          // WANDERING
          // if we're at the outmost shape or circle, pass made-up PVector and diameter by extrapolation from max_distance;
          // otherwise pass those properties of the parent shape:
          if (j == 0) {     // wander under these conditions:
            PVector INVISIBL_PARENT_XY = new PVector(AnimatedShapesArray[0].x_origin, AnimatedShapesArray[0].y_origin);
            float INVISIBL_RADIUS = AnimatedShapesArray[0].max_wander_dist;
            tmp_vec = AnimatedShapesArray[0].wander(INVISIBL_PARENT_XY, INVISIBL_RADIUS);
          } else {          // or under these conditions (one or the other) :
            PVector parent_center_XY = new PVector(AnimatedShapesArray[j].x_center, AnimatedShapesArray[j].y_center);
            tmp_vec = AnimatedShapesArray[k].wander(parent_center_XY, AnimatedShapesArray[j].diameter);
          }
          // DONE WANDERING
          // drag all inner circles/shapes with outer translated circle/shape, using that gotten vector;
          // this won't always actually move anything (as sometimes tmp_vec is (0,0), but it's a waste to check if it will:
          AnimatedShapesArray[k].translate(tmp_vec);
          // CONSTRAINING inner shapes within borders of outer ones
          // if shape has wandered beyond border of parent, drag it within parent, tangent on nearest edge;
          // get XY tmp vectors anew (as prior operations can move things)
          PVector parent_center_XY = new PVector(AnimatedShapesArray[j].x_center, AnimatedShapesArray[j].y_center);
          PVector child_center_XY = new PVector(AnimatedShapesArray[k].x_center, AnimatedShapesArray[k].y_center);
          boolean is_within_parent = is_shape_within_shape(
          parent_center_XY,
          AnimatedShapesArray[j].diameter,
          child_center_XY,
          AnimatedShapesArray[k].diameter);
          if (is_within_parent == false) {      // CONSTRAIN it:
                    // print(is_within_parent + "\n");
            PVector relocate_XY = get_larger_to_smaller_shape_interior_tangent_PVector(
            parent_center_XY, AnimatedShapesArray[j].diameter,
            child_center_XY, AnimatedShapesArray[k].diameter
            );
                    // print(relocate_XY + "\n");
            AnimatedShapesArray[k].x_center = relocate_XY.x;
            AnimatedShapesArray[k].y_center = relocate_XY.y;
          }
          // DONE CONSTRAINING
        }
      // COLOR MORPHING makes it freaking DAZZLING, if I may say so:
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
    // int counter = 0;    // uncomment code that uses this to print a number count of shapes in the center of each shape.
    for (int i = 0; i < ShapesGridOBJ.length; i++) {          // that comparison measures first dimension of array ( == cols)
      for (int j = 0; j < ShapesGridOBJ[0].length; j++) {    // that comparision measures second dimension of array ( == rows)
        // OY the convolution of additional offests just to make a grid centered! :
        int shapeLocX = ((graph_xy_len * j) - (int) graph_xy_len / 2) + grid_to_canvas_x_offset + graph_xy_len;
        int shapeLocY = ((graph_xy_len * i) - (int) graph_xy_len / 2) + grid_to_canvas_y_offset + graph_xy_len;
        int rnd_num = (int) random(minimumNgonSides, maximumNgonSides + 1);
        float minDiam = graph_xy_len * RND_min_diameter_multArg;
        float maxDiam = graph_xy_len * RND_max_diameter_multArg;
        ShapesGridOBJ[i][j] = new NestedAnimatedShapes(shapeLocX, shapeLocY, minDiam, maxDiam, rnd_num, nestingArg);    // I might best like: 1, 8
      }
    }
  }

  void ShapesGridDrawAndChange() {
    //int counter = 0;    // uncomment code that uses this to print a number count of shapes in the center of each shape.
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        fill(255);
        //stroke(255,0,255);
                // print("~~\n");
        ShapesGridOBJ[i][j].drawAndChangeNestedShapes();
        fill(0);
        //counter += 1;
        // debug numbering print of shapes:
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

  ellipseMode(CENTER);

  // Randomly change the background color to any color from backgroundColors array at each run:
  RNDbgColorIDX = (int)random(backgroundColorsArrayLength);
	globalBackgroundColor = backgroundColors[RNDbgColorIDX];
  // To always have N shapes accross the grid, uncomment the next line and comment out the line after it. For random between N and N-1, comment out the next line and uncomment the one after it.
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
