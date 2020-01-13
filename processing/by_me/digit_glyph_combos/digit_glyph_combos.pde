// DIGIT GLYPH COMBOS
// IN DEVELOPMENT. Will take four glyphs, and display them in a 4-tile,
// displaying in sequence all possible combinations of the tiles,
// repetition allowed, each tile rotating in 90 degree incriments.
// 4 tiles * 4 rotations each = 16 possible tile views,
// 16 views pick 4 all possible combos allow repeat = 65535 4-tile views.

// DEV LOG
// - first proof of concept stub displaying a 4-tile from loaded SVGs.
// SVGs are probably in final form. Dang they look nice, if I may say.
// TO DO: a lot.
String versionCode = "0.1";

// CODE

// GLOBAL VARIABLES
float gridPaddingFromEdge = 50;
float gridXYlength;
int cellsXY = 2;
float cellXYlength;
float xScreenCenter;
float yScreenCenter;
float cell1A_xCenter; float cell1A_yCenter;
float cell1B_xCenter; float cell1B_yCenter;
float cell2A_xCenter; float cell2A_yCenter;
float cell2B_xCenter; float cell2B_yCenter;
PShape ZERO;
PShape FOUR;
PShape EIGHT;
PShape C;


void setup() {
  size(800, 800);
  //fullScreen();
  gridXYlength = width - (gridPaddingFromEdge * 2);
  cellXYlength = gridXYlength / cellsXY;
  xScreenCenter = width / 2;
  yScreenCenter = height / 2;
  float cellOffsetToCenter = (cellXYlength / 2);
  cell1A_xCenter = xScreenCenter - cellOffsetToCenter;
  cell1A_yCenter = yScreenCenter - cellOffsetToCenter;
  cell1B_xCenter = xScreenCenter + cellOffsetToCenter;
  cell1B_yCenter = yScreenCenter - cellOffsetToCenter;
  cell2A_xCenter = xScreenCenter - cellOffsetToCenter;
  cell2A_yCenter = yScreenCenter + cellOffsetToCenter;
  cell2B_xCenter = xScreenCenter + cellOffsetToCenter;
  cell2B_yCenter = yScreenCenter + cellOffsetToCenter;
  // The file "bot1.svg" must be in the data folder
  // of the current sketch to load successfully
  ZERO = loadShape("0-3.svg");
  FOUR = loadShape("4-7.svg");
  EIGHT = loadShape("8-B.svg");
  C = loadShape("C-F.svg");
  shapeMode(CENTER);
  change_drawing();    // only called once here in setup (as setup is only called once)
}

void change_drawing() {
  background(255);
  // The syntax shapeMode(CENTER) [which was set in setup()] draws the shape from its center point and
  // uses the third and forth parameters of shape() to specify the width and height.
  // re: https://processing.org/reference/shapeMode_.html
  shape(ZERO, cell1A_xCenter, cell1A_yCenter, cellXYlength, cellXYlength);
  shape(FOUR, cell1B_xCenter, cell1B_yCenter, cellXYlength, cellXYlength);
  shape(EIGHT, cell2A_xCenter, cell2A_yCenter, cellXYlength, cellXYlength);
  shape(C, cell2B_xCenter, cell2B_yCenter, cellXYlength, cellXYlength);
// TO DO: figure out why this doesn't rotate on the axis I expected:
  ZERO.rotate(90); FOUR.rotate(90); EIGHT.rotate(90); C.rotate(90);
}


void draw(){
}

// to do: change to ~1 second timer, not mousePressed() event:
void mousePressed() {
  change_drawing();
}
