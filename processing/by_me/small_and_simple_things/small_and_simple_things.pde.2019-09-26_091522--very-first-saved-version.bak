// "BY SMALL AND SIMPLE THINGS"
// Coded by Richard Alexander Hall 2019
// Generates an animated grid of playfully colored concentric (depending) nested circles which contract and expand.
// Pretty closely imitates art by Daniel Bartholomew, but with random generative constraints:
// https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/by-small-and-simple-things-22x30/
// re: https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/
// v0.9.10 variables names improve (no more "local~" etc.)


// TO DO: move initialization of these randomization controlling varaibles into initial circles grid (or circles?) function call(s)? :
//max_wander_dist_mult = 0.087;
//wander_max_step = random(0.002, 0.0521);
//diameter = random(diameterMin, diameterMax);
//diameter_morph_rate = random(0.009, 0.011); 


// Global variables:
// Prismacolor marker colors array:
color[] Prismacolors = {
  #F4DCD7, #F5DCD5, #F8D9BE, #EDD6BF, #F0D9DC, #524547, #5B4446,
  #CBADB1, #BFA9A8, #EEE2C7, #E54D93, #EA5287, #EEE4DC, #F1E5E9,
  #F6C6D0, #F5D3DD, #7F7986, #72727D, #B34958, #AA4662, #F98973,
  #FA855B, #CA4587, #D8308F, #E5E4E9, #F0CCC4, #E0BFB5, #D1BCBD,
  #F7D580, #F5D969, #E497A4, #F895AC, #F9C0BC, #8D6E64, #9B685D,
  #EE8A74, #91BACB, #95B6BA, #E14E6D, #E65F9F, #FA9394, #DEBBB3,
  #4CC8D9, #7AD2E2, #C7C6CD, #C9CBE0, #B19491, #AA8E79, #C87F73,
  #BD6E6B, #0BBDC4, #75755C, #687B57, #B7A1AF, #CA5A62, #C14F6E,
  #A58E9A, #405F89, #435BA3, #B1A1C9, #A1A6D0, #009D79, #009E90,
  #72646C, #877072, #33549B, #9B98A2, #AC9EB8, #D96A6E, #C0A9BE,
  #987D80, #EF7FAD, #FD9863, #D13352, #8E4C5C, #8F4772, #615F6B,
  #36B191, #FEC29F, #62555E, #618979, #59746E, #F45674, #F2D8A4,
  #FFC874, #008D94, #69A2BE, #7B91A2, #EBB28B, #F86060, #00B3DB,
  #74B3E3, #66C7B0, #93CD87, #82B079, #ECA6B9, #C97B8E, #745D5F,
  #A2B1A2, #367793, #6389AB, #C6DD8E, #0090C7, #4F8584, #AF62A2,
  #BEB27B, #574C70, #8D6CA9, #1E7C72, #934393, #97C1DA
};
int PrismacolorArrayLength = Prismacolors.length; 


// variables and function that monitor the passage of time and calls setup() at a given interval;
int millis;
int millisAtReset = 0;
// exploits the fact that millis() always returns the number of milliseconds since setup() was called:
void setup_again_if_time(int interval) {
  millis = millis();
  // if more than "interval" has passed since this function was last called, store the current time.
  // Later (by calling this function again), subtract the current time from the stored time, and do this again.
  if ((millis - millisAtReset) > interval) {
    millisAtReset = millis;
    setup();
  }
}




// class that contains persisting, modifiable information on a circle.
// NOTE: uses the above global Prismacolors array of colors.
class PersistentCircle {
  int x_origin;
  int y_origin;
  int x_center;
  int y_center;
  int[] xy_translate_vector;
  int x_wandered;
  int y_wandered;
  float max_wander_dist_mult;
  float wander_max_step;
  float diameter;
  float diameter_min;
  float diameter_max;
  float diameter_morph_rate;
  color stroke_color;
  float stroke_weight;
  color fill_color;
  
  // class constructor--sets random diameter and morph speed values from passed parameters:
  PersistentCircle(int xCenter, int yCenter, float diameterMin, float diameterMax) {
    x_origin = xCenter;
    y_origin = yCenter;
    x_center = xCenter;
    y_center = yCenter;
    xy_translate_vector = new int[2];
    xy_translate_vector[0] = 0; xy_translate_vector[1] = 0;
    max_wander_dist_mult = 0.071;                  // remember subtle value I like the result of (if I change that) : 0.83
    wander_max_step = random(0.002, 0.0478);      // remember subtle values I like the results of: random(0.002, 0.058);
    diameter = random(diameterMin, diameterMax);
    diameter_morph_rate = random(0.009, 0.011);
      //randomly make that percent positive or negative to start (which will cause grow or expand animation if used as intended) :
      int RNDtrueFalse = (int) random(0,2);  // gets random 0 or 1
      if (RNDtrueFalse == 1) { diameter_morph_rate *= (-1); }  // flips it to negative if RNDtrueFalse is 1
    diameter_min = diameterMin;
    diameter_max = diameterMax;
    // set RND stroke and fill colors:
    int RNDarrayIndex = (int)random(PrismacolorArrayLength);
    stroke_color = Prismacolors[RNDarrayIndex];
    stroke_weight = random(diameter_max * 0.0064, diameter_max * 0.028);
    RNDarrayIndex = (int)random(PrismacolorArrayLength);
    fill_color = Prismacolors[RNDarrayIndex];
  }
  
  // member functions
  void morphDiameter() {
    //Constrains a value to not exceed a maximum and minimum value; re: https://processing.org/reference/constrain_.html
    //constrain(amt, low, high)
    // grow diameter (positive or negative) :
    diameter = diameter + (diameter * diameter_morph_rate);
    // if diameter is at min or max, alter the the grow rate to positive or negative (depending):
    diameter = constrain(diameter, diameter_min, diameter_max);
    if (diameter == diameter_max) { diameter_morph_rate *= (-1); }
    if (diameter == diameter_min) { diameter_morph_rate *= (-1); }
  }
  
  void morphTranslation() {
    //to use: wander_max_step, max_wander_dist_mult
    int xy_wander_max = (int) (diameter * wander_max_step);
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
    
    // AND/OR TO DO: random wobbling around a center, involving a rotation around an offset point? :
    //via something like; re: https://processing.org/discourse/beta/num_1207766233.html
    //  float radius=50;
    //int numPoints=20;
    //float angle=TWO_PI/(float)numPoints;
    //for(int i=0;i<numPoints;i++)
    //{
    //  point(radius*sin(angle*i),radius*cos(angle*i));
    //} 
  }

  // translate (move canvas, draw, then move back) in this function because frustrating reasons:
  void drawCircle(int translateX, int translateY) {
    translate(translateX, translateY);
    stroke(stroke_color);
    strokeWeight(stroke_weight);
    fill(fill_color);
    ellipse(x_center, y_center, diameter, diameter);
    translate(translateX * (-1), translateY * (-1));
  }

}


// class that contains information for a grid of circles and renders and manipulates them.
class CirclesGrid {
  int graph_xy_len;
  int cols;
  int rows;
  float RND_min_diameter_mult;
  float RND_max_diameter_mult;
  PersistentCircle CirclesGrid[][];
  int grid_to_canvas_x_offset;
  int grid_to_canvas_y_offset;

// class constructor
    CirclesGrid(int canvasXpx, int canvasYpx, int passedColumns, float RND_min_diameter_mult, float RND_max_diameter_mult) {
    graph_xy_len = canvasXpx / passedColumns;
    cols = passedColumns;
    rows = canvasYpx/graph_xy_len;
    RND_min_diameter_mult = RND_min_diameter_mult;
    RND_max_diameter_mult = RND_max_diameter_mult;
      //information and a standard (to Processing) function call that will center the grid on the canvas:
      int canvasToGridXremainder = canvasXpx - (cols * graph_xy_len);
      grid_to_canvas_x_offset = canvasToGridXremainder / 2;
      int canvasToGridYremainder = canvasYpx - (rows * graph_xy_len);
      grid_to_canvas_y_offset = canvasToGridYremainder / 2;
      // This class directly manipulates the canvas translation. Should it?
      // Or should I have a function to retrieve that information and pass it outside for use? :
 //TO DO: figure out why this no longer does what it should, and fix it (it isn't moving anything at all, apparently):
      //translate(grid_to_canvas_x_offset, grid_to_canvas_y_offset);
    CirclesGrid = new PersistentCircle[rows][cols];
    // initialize CirclesGrid[][] array elements :
    //int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 0; i < CirclesGrid.length; i++) {          // that comparison measures first dimension of array ( == cols)
      for (int j = 0; j < CirclesGrid[0].length; j++) {    // that comparision measures second dimension of array ( == rows)
// TO DO: get RND diameter min and max, to pass to PersistentCircle initializer:
        int circleLocX = ((graph_xy_len * j) - (int) graph_xy_len / 2) + graph_xy_len;    // OY that last additon convolutes!
        int circleLocY = ((graph_xy_len * i) - (int) graph_xy_len / 2) + graph_xy_len;
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
        CirclesGrid[i][j] = new PersistentCircle(circleLocX, circleLocY, circleDiameterMin, circleDiameterMax);
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

  void drawCirclesGrid() {    // reference / development function
    //int counter = 0;    // uncomment code that uses this to print a number count of circles in the center of each circle.
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        fill(255);
        //stroke(255,0,255);
        CirclesGrid[i][j].drawCircle(grid_to_canvas_x_offset, grid_to_canvas_y_offset);
// THIS IS WHERE THE FREAKY STUFF IS . . . changing properties of the circles so that they animate the next time this is called:
        CirclesGrid[i][j].morphDiameter();
// IN DEVELOPMENT:
        CirclesGrid[i][j].morphTranslation();
        fill(0);
        //counter += 1;
        // debug numbering print of circles:
        //text(counter, ((graph_xy_len * j) - (int) graph_xy_len / 2) + graph_xy_len, ((graph_xy_len * i) - graph_xy_len / 2) + graph_xy_len);
      }
    }
  }

}




int gridNesting = 4;
// It took me experimenting to learn that I can't initialize an object of
// a class out here outside setup(), only declare it (which I guess means
// allocate the memory for it), in order for it to persist as usable in
// setup() and void() ! :/   :
CirclesGrid[] nestedGridSmallCircles = new CirclesGrid[gridNesting];

int RNDcolorIDX;
color globalBackgroundColor;

//for "frenetic option", loop creates a list of size gridNesting (of ints) :
//IntList nestedGridRenderOrder = new IntList();    // because this list has a shuffle() member function, re: https://processing.org/reference/IntList.html

//to make the script exit after N frames if desired, increment a value from 0 in draw() and exit when it is this:
int nFrames = 7200;
int frameCounter = 0;




void setup() {
  //size(1280,720);
  fullScreen();
  // MIND TO MAKE the two assignments on the next line of code those same XY values, as Processing can't use variables for size():
  // my Mac's screen is 1680 W x 1050 H
  int W = width; int H = height;
  ellipseMode(CENTER);

  // To randomly change the background color to any color from the Prismacolor array at each run, uncomment the next two lines of code:
  RNDcolorIDX = (int)random(PrismacolorArrayLength);
  globalBackgroundColor = Prismacolors[RNDcolorIDX];

  // To always have N circles accross the grid, uncomment the next line and comment out the line after it. For random between N and N-1, comment out the next line and uncomment the one after it.
  //int gridXcount = 19;  // good values: any, or 14 or 19
  int gridXcount = (int) random(14, 43);

  // reference of original art:
  // larger original grid size: 25x14, wobbly circle placement, wobbly concentricity in circles.
  // smaller original grid size: 19x13, regular circle placement on grid, wobbly concentricity in circles.
  float circlesGridXminPercent = 0.45;
  float circlesGridXmaxPercent = 0.63;
  
  for (int i = 0; i < gridNesting; i++) {
    nestedGridSmallCircles[i] = new CirclesGrid(W, H, gridXcount, circlesGridXminPercent, circlesGridXmaxPercent);
    circlesGridXminPercent *= 0.67; circlesGridXmaxPercent *= 0.92;
  }
  
  // for "frenetic option" :
  //for (int x = 0; x < gridNesting; x++) {
  //  nestedGridRenderOrder.append(x);
  //  //print(x + "\n");
  //}
  
  // to produce one static image, uncomment the next function:
  //noLoop();
}


void draw() {
  background(globalBackgroundColor);  // clears canvas to white before next animaton frame (so no overlap of smaller shapes this frame on larger from last frame) :
  
  // randomizes list--for frenetic option (probably will never want) :
  //nestedGridRenderOrder.shuffle();
  //println(nestedGridRenderOrder);

  for (int j = 0; j < gridNesting; j++) {
    //use the next line instead of the one after it for the "frenetic option" (see other comments that say that) :
    //nestedGridSmallCircles[ nestedGridRenderOrder.get(j) ].drawCirclesGrid();
    nestedGridSmallCircles[j].drawCirclesGrid();
  }

  //CONTROL LIVE FRAME RATE via delay:
  delay(33);    // 33 = ~30fps -- or to hog CPU cycles less on dynamic run, try 250
  
  // ANIMATION IMAGE SERIES SAVE. Uncomment this code block to do that.
  //saveFrame("#######.png");
  //frameCounter += 1;
  //if (frameCounter == nFrames) {
  //  exit();
  //}

  //To recreate this work of art and its attendant animation every N milliseconds,
  //uncomment the next line of code and change the number of milliseconds passed to the function:
  setup_again_if_time(13250);
}
