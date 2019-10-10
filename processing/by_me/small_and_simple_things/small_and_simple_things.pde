// "By Small and Simple Things"
// Coded by Richard Alexander Hall 2019
// Generates an animated grid of playfully colored concentric nested circles which contract,
// expand, and morph color on user click or click and drag (or tap and tap and drag). Also saves
// reference image with random seed in file name on first frame of user tap and last frame of that variant.
//
// Pretty closely imitates art by Daniel Bartholomew, but with random generative constraints:
// https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/by-small-and-simple-things-22x30/
// re: https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/
//
// v1.3.2 -- bug fix timing of some image saves by refactoring PNG / SVG save logic (in animation() loop now)
String versionString = "v1.3.2";


// TO DO:
// - svg save every frame?
// - move initialization of these randomization controlling varaibles into initial circles grid (or circles?) function call(s)? :
// wander_max_step_mult = random(0.002, 0.0521);
// diameter = random(diameterMin, diameterMax);
// diameter_morph_rate = random(0.009, 0.011);


// DEPENDENCY IMPORTS
import processing.svg.*;


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
int seed;
boolean booleanOverrideSeed = false;    // if set to true, intOverrideSeed will be used as the random seed for the first displayed variant. If false, a seed will be chosen randomly.
int intOverrideSeed = -161287679;    // a favorite is: -161287679
boolean USE_FULLSCREEN = true;  // if set to true, overrides the following values; if false, they are used:
int globalWidth = 640; int globalHeight = 640;    // dim. of kiosk entered in SMOFA: 1080x1920. scanned 35mm film: 5380x3620
int gridNesting = 4;    // controls how many nests of circles there are for each circle on the grid.
CirclesGrid[] nestedGridSmallCircles = new CirclesGrid[gridNesting];    // must be allocated here (but is not yet initialized)
int circlesGridNumCols;    // to be reinitialized in each loop of setup() -- for reference from other functions
int circlesGridNumRows;    // "
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
int fixedMillisecondsPerVariation = (int) (1000 * 1.3);         // milliseconds to display each variation, if previous boolean is true
int minimumMillisecondsPerVariation = (int) (1000 * 16.5);      // 1000 milliseconds * 16.5 = 16.5 seconds
int maximumMillisecondsPerVariation = (int) (1000 * 52);        // 1000 milliesconds * 52 = 52 seconds
int currentTimeMilliseconds;
int runSetupAtMilliseconds;     // at start of each variation, altered to cue time for next variation
String userInteractionString;   // changed to states reflecting whether user interacted with a variation or not (empty or not empty)
// END VARIABLES RELATED TO image save.
boolean estimateFPS = true;
int FPS = 0;    // dynamically modified by program as it runs (and prints running FPS estimate), IF that afore boolean is true
// reference of original art:
// larger original grid size: 25x14, wobbly circle placement, wobbly concentricity in circles.
// smaller original grid size: 19x13, regular circle placement on grid, wobbly concentricity in circles.
// SMOFA entry configuration for the following values, for ~6' tall kiosk: 7, 21. OR 1, ~65? Match whatever high number it can handle? ~4K resolution horizontally larger monitors: 14, 43
int minimumColumns = 2; int maximumColumns = 21;
float circlesGridXminPercent = 0.4175;    // controls minimum diameter of circle vs. grid cell size
float circlesGridXmaxPercent = 0.72;      // controls maximum "" -- v0.9.12 had 0.63
// NOTE: to control additional information contained in saved file names, see comments in the get_image_file_name_no_ext() function further below.
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
    int tmp_MS_to_add_till_next_variation = (int) random(minimumMillisecondsPerVariation, maximumMillisecondsPerVariation);
    runSetupAtMilliseconds = currentTimeMilliseconds + tmp_MS_to_add_till_next_variation;
  }
}


// Because I want to respond to both mousePressed AND mouseDragged events, those functions can pass mouseX and mouseY to this when they are called:
void set_color_morph_mode_at_XY(int Xpos, int Ypos) {
      // print(Xpos + " " + Ypos + "\n");
  // collision detection of mouse x and y pos vs. center and radius of circle via this genius breath: https://happycoding.io/tutorials/processing/collision-detection ;
  // checks if distance between center of circle and mouse click is less than radius of circle. if smaller, click  was inside circle. if greater, was outside:
  //int tmp_cols = 4;
  //int tmp_rows = 3;
  for (int grid_Y = 0; grid_Y < circlesGridNumRows; grid_Y ++) {
    for (int grid_X = 0; grid_X < circlesGridNumCols; grid_X ++) {
      int circle_center_x = nestedGridSmallCircles[0].CirclesGridOBJ[grid_Y][grid_X].x_center;
      int circle_center_y = nestedGridSmallCircles[0].CirclesGridOBJ[grid_Y][grid_X].y_center;
      int circle_radius = (int) nestedGridSmallCircles[0].CirclesGridOBJ[grid_Y][grid_X].diameter / 2;
      // if click was within radius of a circle (which will be caught in the amazing speed of
      // for loops in modern computers), activate color morph mode for that circle and all nested circles in it:
      if (dist(Xpos, Ypos, circle_center_x, circle_center_y) < circle_radius) {
        //int hooman_column = grid_X + 1; int hooman_row = grid_Y + 1;    // compensate for humans; compy starts count at 0
        //print("Click is within circle at row " + hooman_row + " column " + hooman_column + "!\n");
        for (int N = 0; N < gridNesting; N ++) {
        nestedGridSmallCircles[N].CirclesGridOBJ[grid_Y][grid_X].color_morph_on = true;
        }
      }
    }
  }

  // ENABLE COLOR MORPH MODE in nested circles (via for loop of number gridNesting) :
  //for (int nested = 0; nested < gridNesting; nested++) {
  //nestedGridSmallCircles[nested].CirclesGridOBJ[row_idx_clicked][col_idx_clicked].color_morph_on = true;
  //}
}


// get file name without extension -- for use before image save function or alternately before svg save (add extension to returned string)
String get_image_file_name_no_ext() {
  int N_cols_tmp = nestedGridSmallCircles[0].cols;
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
  // + " runVariant " + variationNumThisRun
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
    // saveFrame("C:\\Users\\UR_USERNAME\\Dropbox\\By_Small_and_Simple_Things__SMOFA_visitor_image_saves\\" + FNNE + ".png");
    
    // CLOUD SAVE option two (RAH collecting images, Mac) :
    // saveFrame("/Users/earthbound/Dropbox/small_and_simple_things_RAH_image_saves/" + FNNE + ".png");
}


// END GLOBAL FUNCTIONS


// BEGIN CLASSES
// class that contains persisting, modifiable information on a circle.
// NOTE: uses the above global Prismacolors array of colors.
class PersistentCircle {
  int x_origin;
  int y_origin;
  int x_center;
  int y_center;
  int x_wandered;
  int y_wandered;
  float wander_max_step_mult;
  float diameter;
  float diameter_min;
  float diameter_max;
  float diameter_morph_rate;
  color stroke_color;
  int stroke_color_palette_idx;
  float stroke_weight;
  color fill_color;
  int fill_color_palette_idx;
  int milliseconds_elapse_to_color_morph;
  int milliseconds_at_last_color_change_elapsed;
  boolean color_morph_on;
  
  // class constructor--sets random diameter and morph speed values from passed parameters:
  PersistentCircle(int xCenter, int yCenter, float diameterMin, float diameterMax) {
    x_origin = xCenter;
    y_origin = yCenter;
    x_center = xCenter;
    y_center = yCenter;
    wander_max_step_mult = random(0.002, 0.038);  // remember subtle values I like the results of: random(0.002, 0.058) -- for smaller circles. For YUGE: 0.002, 0.038
    diameter = random(diameterMin, diameterMax);
    diameter_morph_rate = random(0.009, 0.012);
      //randomly make that percent positive or negative to start (which will cause grow or expand animation if used as intended) :
      int RNDtrueFalse = (int) random(0,2);  // gets random 0 or 1
      if (RNDtrueFalse == 1) { diameter_morph_rate *= (-1); }  // flips it to negative if RNDtrueFalse is 1
    diameter_min = diameterMin;
    diameter_max = diameterMax;
    // set RND stroke and fill colors:
    int RNDarrayIndex = (int)random(PrismacolorArrayLength);
    stroke_color = Prismacolors[RNDarrayIndex];
    stroke_color_palette_idx = RNDarrayIndex;
    stroke_weight = random(diameter_max * 0.0064, diameter_max * 0.028);
    RNDarrayIndex = (int)random(PrismacolorArrayLength);
    fill_color = Prismacolors[RNDarrayIndex];
    fill_color_palette_idx = RNDarrayIndex;
//TO DO? : control the folling rnd range with parameters?
    milliseconds_elapse_to_color_morph = (int) random(1, 70);    // on more powerful hardware, 194 is effectively true. On slower? Cut by ~1/5?
    milliseconds_at_last_color_change_elapsed = millis();
    color_morph_on = false;
  }
  
  // member functions
  void morphDiameter() {
    // constrains a value to not exceed a maximum and minimum value; re: https://processing.org/reference/constrain_.html
    // constrain(amt, low, high)
    // grow diameter (positive or negative) :
    diameter = diameter + (diameter * diameter_morph_rate);
    // if diameter is at min or max, alter the the grow rate to positive or negative (depending):
    diameter = constrain(diameter, diameter_min, diameter_max);
    if (diameter == diameter_max) { diameter_morph_rate *= (-1); }
    if (diameter == diameter_min) { diameter_morph_rate *= (-1); }
  }
  
  void morphTranslation() {
    int xy_wander_max = (int) (diameter * wander_max_step_mult);
    // SETUP x AND y ADDITION (positive or negative) of morph coordinate:
    x_wandered = x_wandered + ((int) random(xy_wander_max * (-1), xy_wander_max));
    y_wandered = y_wandered + ((int) random(xy_wander_max * (-1), xy_wander_max));
    //print(" x and y wandered amts: " + x_wandered + " " + y_wandered + "\n");
    // ACTUAL COORDINATE MORPH but constrained:
    x_center = x_origin + x_wandered;
    x_center = constrain(x_center, (int) x_origin + (xy_wander_max / 2) * (-1),(int) x_origin + (xy_wander_max / 2));
    // UND MORPH UND constrained:
    y_center = y_origin + y_wandered;
    y_center = constrain(y_center, (int) y_origin + (xy_wander_max / 2) * (-1),(int) y_origin + (xy_wander_max / 2));
    
    // AND/OR TO DO: random wobbling around a center, involving a rotation around an offset point? -- in a different function? :
    //via something like; re: https://processing.org/discourse/beta/num_1207766233.html
    // float radius=50;
    // int numPoints=20;
    // float angle=TWO_PI/(float)numPoints;
    // for(int i=0;i<numPoints;i++)
    // {
    //  point(radius*sin(angle*i),radius*cos(angle*i));
    // } 
  }
  
  void morphColor() {
    int localMillis = millis();
  if ((localMillis - milliseconds_at_last_color_change_elapsed) > milliseconds_elapse_to_color_morph && color_morph_on == true) {
      // morph stroke color:
      stroke_color_palette_idx += 1;
      if (stroke_color_palette_idx >= PrismacolorArrayLength) { stroke_color_palette_idx = 0; }    // reset that if it went out of bounds of array indices
      stroke_color = Prismacolors[stroke_color_palette_idx];
      // morph fill color:
      fill_color_palette_idx += 1;
      if (fill_color_palette_idx >= PrismacolorArrayLength) { fill_color_palette_idx = 0; }        // also reset that if it was out of bounds
      fill_color = Prismacolors[fill_color_palette_idx];
      milliseconds_at_last_color_change_elapsed = millis();
    }
  }

  void drawCircle() {
    stroke(stroke_color);
    strokeWeight(stroke_weight);
    fill(fill_color);
    ellipse(x_center, y_center, diameter, diameter);
  }

}


// class that contains information for a grid of circles and renders and manipulates them.
class CirclesGrid {
  int graph_xy_len;
  int cols;
  int rows;
  float RND_min_diameter_mult;
  float RND_max_diameter_mult;
  PersistentCircle CirclesGridOBJ[][];
  int grid_to_canvas_x_offset;
  int grid_to_canvas_y_offset;

// class constructor
    CirclesGrid(int canvasXpx, int canvasYpx, int passedColumns, float RND_min_diameter_mult, float RND_max_diameter_mult) {
    graph_xy_len = canvasXpx / passedColumns;   // it seems this discards any remainder if it divides unevenly.
    cols = passedColumns;
    rows = canvasYpx/graph_xy_len;
    RND_min_diameter_mult = RND_min_diameter_mult;
    RND_max_diameter_mult = RND_max_diameter_mult;
      //information and a standard (to Processing) function call that will center the grid on the canvas:
      int canvasToGridXremainder = canvasXpx - (cols * graph_xy_len);   // gets us the earlier discarded remainder
      grid_to_canvas_x_offset = canvasToGridXremainder / 2;
      int canvasToGridYremainder = canvasYpx - (rows * graph_xy_len);
      grid_to_canvas_y_offset = canvasToGridYremainder / 2;
      // This class directly manipulates the canvas translation. Should it?
      // Or should I have a function to retrieve that information and pass it outside for use? :
 //TO DO: figure out why this no longer does what it should, and fix it (it isn't moving anything at all, apparently):
      //translate(grid_to_canvas_x_offset, grid_to_canvas_y_offset);
    CirclesGridOBJ = new PersistentCircle[rows][cols];
    // initialize CirclesGrid[][] array elements :
    //int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 0; i < CirclesGridOBJ.length; i++) {          // that comparison measures first dimension of array ( == cols)
      for (int j = 0; j < CirclesGridOBJ[0].length; j++) {    // that comparision measures second dimension of array ( == rows)
// TO DO: get RND diameter min and max, to pass to PersistentCircle initializer:
        // OY the convolution of additional offests just to make a grid centered! :
        int circleLocX = ((graph_xy_len * j) - (int) graph_xy_len / 2) + grid_to_canvas_x_offset + graph_xy_len;
        int circleLocY = ((graph_xy_len * i) - (int) graph_xy_len / 2) + grid_to_canvas_y_offset + graph_xy_len;
        // randomly pick smallest and largest diameter range for (to be) animated circle (to be passsed to PersistentCircle constructor) :
        float circleDiameterMin = random(graph_xy_len * RND_min_diameter_mult, graph_xy_len * RND_max_diameter_mult);
        float circleDiameterMax = random(graph_xy_len * RND_min_diameter_mult, graph_xy_len * RND_max_diameter_mult);
        // if min is larger than max, swap them -- although..
// TO DO: test run to see if this swapping is even necessary:
        if (circleDiameterMin > circleDiameterMax) {
          float tmp = circleDiameterMax; circleDiameterMax = circleDiameterMin; circleDiameterMin = tmp;
        }
          // print(circleLocX + " " + circleLocY + "\n");
          // print("i is " + i + ", j is " + j + "\n");
            // constructor of that class, for reference: PersistentCircle(int x_center, int y_center, int diamterMin, int diameterMax) :
        CirclesGridOBJ[i][j] = new PersistentCircle(circleLocX, circleLocY, circleDiameterMin, circleDiameterMax);
      }
    }
  }

  // member functions
  // only for dev reference and testing:
  void drawDynamicallyConstructedCircleGrid() {    // reference / development function
    //int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 1; i <= rows; i++) {
      for (int j = 1; j <= cols; j++) {
        //fill(255);
        ellipse((graph_xy_len * j) - (int) graph_xy_len / 2, (graph_xy_len * i) - graph_xy_len / 2, (int) graph_xy_len * 0.6, (int) graph_xy_len * 0.6);
        //CirclesGrid[i][j].drawCircle();
        //fill(0);
        //counter += 1;
        //text(counter, (graph_xy_len * j) - (int) graph_xy_len / 2, (graph_xy_len * i) - graph_xy_len / 2);
      }
    }
  }

  void CirclesGridDrawAndChange() {
    //int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        fill(255);
        //stroke(255,0,255);
        CirclesGridOBJ[i][j].drawCircle();
// THIS IS WHERE THE FREAKY STUFF IS . . . changing properties of the circles so that they animate the next time this is called:
        CirclesGridOBJ[i][j].morphDiameter();
        CirclesGridOBJ[i][j].morphTranslation();
// UNCOMMENT FOR COLOR MORPHING, which makes it freaking DAZZLING, if I may say so:
        CirclesGridOBJ[i][j].morphColor();
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
  seed = (int) random(-2147483648, 2147483647);
  randomSeed(seed);
  // THAT WILL BE OVERRIDEN if the boolean value booleanOverrideSeed is set to true:
  if (variationNumThisRun == 0 && booleanOverrideSeed == true) {
  randomSeed(intOverrideSeed);
  }
  
  variationNumThisRun += 1;
  //print("~-~- Setting up variation number " + variationNumThisRun + " in run. Seed: " + seed + " -~-~\n");
  
// TO DO: check: I think the interpreter demanded I use static values? Do I really need W and H here:
  int W = width; int H = height;
  ellipseMode(CENTER);

  // Randomly change the background color to any color from the Prismacolor array OR black OR white at each run:
  RNDcolorIDX = (int)random(PrismacolorArrayLength + 2);
  // I can't use a switch because of requirement that cases be constant expressions, so:
  if (RNDcolorIDX == PrismacolorArrayLength) {    // confusingly, that actually means what results from the (PrismacolorArrayLength + 1) max range (as random doesn't include max range)
    globalBackgroundColor = 0;    // black
  } else { 
      if (RNDcolorIDX == PrismacolorArrayLength + 1) {
        globalBackgroundColor = 255;    // white
      }
    else {   // all other cases, use whatever rnd idx was chosen in the range 0 - length of array:
    globalBackgroundColor = Prismacolors[RNDcolorIDX];
      }
    }
  // To always have N circles accross the grid, uncomment the next line and comment out the line after it. For random between N and N-1, comment out the next line and uncomment the one after it.
  //int gridXcount = 19;  // good values: any, or 14 or 19
  int gridXcount = (int) random(minimumColumns, maximumColumns + 1);  // +1 because random doens't include max range. Also, see comments where those values are set.  
  //This creates nested grids of circles of decreasing minimum and maximum diameter in each iteration of the loop. This is insane, haha, but cool! :
  float circlesGridXminPercent_copy = circlesGridXminPercent;
  float circlesGridXmaxPercent_copy = circlesGridXmaxPercent;
  for (int i = 0; i < gridNesting; i++) {
    nestedGridSmallCircles[i] = new CirclesGrid(W, H, gridXcount, circlesGridXminPercent_copy, circlesGridXmaxPercent_copy);
    circlesGridXminPercent_copy *= 0.67; circlesGridXmaxPercent_copy *= 0.92;
  }
  
  circlesGridNumCols = nestedGridSmallCircles[0].cols;
  circlesGridNumRows = nestedGridSmallCircles[0].rows;
  
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

  for (int j = 0; j < gridNesting; j++) {
    //use the next line instead of the one after it for the "frenetic option" (see other comments that say that) :
    //nestedGridSmallCircles[ nestedGridRenderOrder.get(j) ].CirclesGridDrawAndChange();
    nestedGridSmallCircles[j].CirclesGridDrawAndChange();
  }

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
      FPS = totalFramesRendered - last_captured_totalFramesRendered;
      int countdown_to_next_render = runSetupAtMilliseconds - current_millis;
      print("Estimated frames per second: " + FPS + ". total frames rendered: " + totalFramesRendered + ". Next variation in " + countdown_to_next_render + "ms\n");
      //reset these values or this won't work:
      last_captured_millis = current_millis;
      last_captured_totalFramesRendered = totalFramesRendered;
    }
  }

  // BUT UMMMM... THERE'S A frameRate() FUNCTION?
  // conditioanlly THROTTLE delay either fixed or current calculated FPS;
  // BUT: ON A CONSISTENTLY VERY SLUGGISH computer, maybe just forget that,
  // and comment out the next line of code (delay(FPS);) and uncomment the one after it (delay(0)):
  //delay(FPS);    // 33 = ~30fps -- or to hog CPU cycles less on dynamic run, try 250. For a wimpy kiosk, do ONE OR ZERO.
  //delay(0);

}


int last_captured_millis = 0;
int last_captured_totalFramesRendered = 0;
void draw() {

  animate();

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
      if (saveEveryVariation == true && savePNGs == true) { save_PNG(); }
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
}


void mouseDragged() {
  set_color_morph_mode_at_XY(mouseX, mouseY);
}
