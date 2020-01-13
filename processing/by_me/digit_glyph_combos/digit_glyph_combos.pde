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
String versionCode = "0.1.2";

// CODE

// GLOBAL VARIABLES
float gridPaddingFromEdge = 50;
float gridXYlength;
int cellsXY = 2;
float cellXYlength;
float xScreenCenter;
float yScreenCenter;
//vectors that describe the center location (XY) of the four tiles:
PVector tile_1A_Center; PVector tile_1B_Center;
PVector tile_2A_Center; PVector tile_2B_Center;
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
  tile_1A_Center = new PVector(xScreenCenter - cellOffsetToCenter, yScreenCenter - cellOffsetToCenter);
  tile_1B_Center = new PVector(xScreenCenter + cellOffsetToCenter, yScreenCenter - cellOffsetToCenter);
  tile_2A_Center = new PVector(xScreenCenter - cellOffsetToCenter, yScreenCenter + cellOffsetToCenter);
  tile_2B_Center = new PVector(xScreenCenter + cellOffsetToCenter, yScreenCenter + cellOffsetToCenter);
  // These files must be in the /data folder
  // of the current sketch to load successfully:
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
    // svg style override re: https://processing.org/examples/disablestyle.html
    //ZERO.disableStyle();  // Ignore the colors in the SVG
    //fill(0, 102, 153);    // Set the SVG fill to blue
    //stroke(255);          // Set the SVG fill to white
    //strokeWeight(50);
  shape(ZERO, tile_1A_Center.x, tile_1A_Center.y, cellXYlength, cellXYlength);
  shape(FOUR, tile_1B_Center.x, tile_1B_Center.y, cellXYlength, cellXYlength);
  shape(EIGHT, tile_2A_Center.x, tile_2A_Center.y, cellXYlength, cellXYlength);
  shape(C, tile_2B_Center.x, tile_2B_Center.y, cellXYlength, cellXYlength);
  // TO DO: Tile rotation from their center; re? : https://stackoverflow.com/a/41654779/1397555
  //ZERO.rotate(radians(4));
  //ZERO.translate(tile_1A_Center.x, tile_1A_Center.y);
  //ZERO.rotate(90); FOUR.rotate(90); EIGHT.rotate(90); C.rotate(90);
}


void draw(){
}

// to do: change to ~1 second timer, not mousePressed() event:
void mousePressed() {
  change_drawing();
}
