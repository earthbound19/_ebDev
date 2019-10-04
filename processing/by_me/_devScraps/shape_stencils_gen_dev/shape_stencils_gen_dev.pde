// NOTE: any key or mousepress (well technically their release) will generate a new test SVG.

// DEPENDENCY INCLUDES:
import processing.svg.*;

// GLOBALS:
// stencil sizes in inches:
float[] stencils = {
1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5, 1.55, 1.6, 1.65, 1.7, 1.75, 1.8, 1.85, 1.9, 1.95,
2.0, 2.05, 2.1, 2.15, 2.2, 2.25, 2.3, 2.35, 2.4, 2.45, 2.5, 2.55, 2.6, 2.65, 2.7, 2.75, 2.8, 2.85, 2.9, 2.95,
3.0, 3.05, 3.1, 3.15, 3.2, 3.25, 3.3, 3.35, 3.4, 3.45, 3.5, 3.55, 3.6, 3.65, 3.7, 3.75, 3.8, 3.85, 3.9, 3.95,
4.0, 4.05, 4.1, 4.15, 4.2, 4.25, 4.3, 4.35, 4.4, 4.45, 4.5, 4.55, 4.6, 4.65, 4.7, 4.75, 4.8, 4.85, 4.9, 4.95,
5.0, 5.05, 5.1, 5.15, 5.2, 5.25, 5.3, 5.35, 5.4, 5.45, 5.5, 5.55, 5.6, 5.65, 5.7, 5.75, 5.8, 5.85, 5.9, 5.95,
6.0, 6.05, 6.1, 6.15, 6.2, 6.25, 6.3, 6.35, 6.4, 6.45, 6.5, 6.55, 6.6, 6.65, 6.7, 6.75, 6.8, 6.85, 6.9, 6.95,
7.0, 7.05, 7.1, 7.15, 7.2, 7.25, 7.3, 7.35, 7.4, 7.45, 7.5, 7.55, 7.6, 7.65, 7.7, 7.75, 7.8, 7.85, 7.9, 7.95,
8.0, 8.05, 8.1, 8.15, 8.2, 8.25, 8.3, 8.35, 8.4, 8.45, 8.5
// 8.55, 8.6, 8.65, 8.7, 8.75, 8.8, 8.85, 8.9, 8.95
};
int stencilsArrayLength = stencils.length;

// global random string generator function
String rndString() {
  String florf = "";
  for (int i = 0; i < 12; i++)
  {
  florf += (char) int(random(98, 123));
  }
  return florf;
}

//TO DO: figure out why nothing redraws on re-call of draw() function after it's called from within this function, and fix it --
//until then, this function is commented out:
//function overrides for built-in functions which invoke the whole setup() function on release of keypress or mouse click:
void keyReleased() {
  setup();
}
void mouseReleased() {
  setup();
}


// SETUP
// for help figuring out parameters for screen size() :
float DPI = 96;    // It seems that Processing works internally with a DPI of 96.
float paper_inches_x = 11.0;
float paper_inches_y = 8.5;
float paper_pixels_x = DPI * paper_inches_x;
float paper_pixels_y = DPI * paper_inches_y;

void setup() {
// HELP FOR PAPER SIZING:
// RUN THE SCRIPT to see the following print command to get the width and height you should enter
// in size() -- then enter those parameters in size(), for example like: size(576, 792) : 
 print("DPI " + DPI + "* paper_inches_x " + paper_inches_x + " = paper_pixels_x " + paper_pixels_x + "\n");
 print("DPI " + DPI + "* paper_inches_y " + paper_inches_y + " = paper_pixels_y " + paper_pixels_y + "\n");
  size(1056, 816);
  //without the following function call, draw() will be called infinitely:
  drawShapes();
}

void draw() {
  // NORTHING HERE -- keyboard triggers call of setup() which draws a shape and makes a new svg.
}

void drawShapes () {
  background(255);
  // SVG RECORD START: re https://processing.org/reference/libraries/svg/index.html :
  float x_center = pixelWidth / 2; float y_center = pixelHeight / 2;
  int RND_stencil_idx = (int) random(0, stencilsArrayLength + 1);
  float stencil_dim = (float) stencils[RND_stencil_idx];
      // OVERRIDE FOR TESTING ONLY:
      //stencil_dim = 8.5;
  print("Stencil size selected is " + stencil_dim + "\"\n");
  String flarf = rndString();
  float shape_xy_len = DPI * stencil_dim;
  print("shape_xy_len (pixels) = " + shape_xy_len);
      //OPTIONAL SVG save:
      String fileNameString = stencil_dim + "_circle_test.svg";
      beginRecord(SVG, fileNameString);
  strokeWeight(8);
  stroke(0);
  //noFill();
  ellipse(x_center, y_center, shape_xy_len, shape_xy_len);
      //OPTIONAL PNG save:
      // save("stencil_" + stencil_dim_str + "_in.png");
  endRecord();
}
