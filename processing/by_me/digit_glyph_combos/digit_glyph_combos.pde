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
String versionCode = "0.2.0";

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

color[] commodoreVicColors = {
  #C250D0, #8E8BFF, #4844E4, #696969, #9E9E9E, #D7D7D7, #FFFFFF, #BEFFB0,
  #FFFF73, #67DE5B, #85FEF6, #FF868D, #C26C36, #B84A50, #7F5600, #121212
};

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
  ZERO = loadShape("0-3.svg"); ZERO.disableStyle();
  FOUR = loadShape("4-7.svg"); FOUR.disableStyle();
  EIGHT = loadShape("8-B.svg"); EIGHT.disableStyle();
  //EIGHT = loadShape("8-B-alt.svg"); EIGHT.disableStyle();
  C = loadShape("C-F.svg"); C.disableStyle();
  shapeMode(CENTER);
  strokeWeight(0);
  change_drawing();    // only called once here in setup (as setup is only called once)
}

// vestigal function works but is unused:
//color getRNDcolor(color[] palette) {
//  int paletteLength = palette.length;
//  int colorIDX = int(random(0, paletteLength)); 
//  return palette[colorIDX];
//}

// does what I want, I don't know how :shrug:,
// from: https://forum.processing.org/two/discussion/7696/unique-random-number-for-elements-in-array
static final boolean contains(int n, int... nums) {
  for (int i : nums)  if (i == n)  return true;
  return false;
}

color[] get5RNDcolors(color[] palette) {
  color[] returnColors = new color[5];
  // get an array of unique numbers which are indices of palette;
  // NOTE the QTY must be <= RANGE:
  int QTY = 5, RANGE = palette.length;
  final int[] numbers = new int[QTY];
  for (int rnd, i = 0; i != QTY; ++i) {
    numbers[i] = MIN_INT;
    while (contains(rnd = (int)random(0, RANGE), numbers));
      numbers[i] = rnd;
  }
  // use rnd unique number indeces to create palette of 5 unique colors from other palette:
  print("\n");
  for (int j = 0; j < numbers.length; j++) {
    //print(numbers[j] + "\n");
    returnColors[j] = commodoreVicColors[numbers[j]];
  }
  // return that palette:
  return returnColors;
};

void setFillAndStroke(color wut) {
  fill(wut); stroke(wut);
}

void change_drawing() {
  color[] RND5colors = get5RNDcolors(commodoreVicColors);
  background(RND5colors[0]);
  setFillAndStroke(RND5colors[1]);
  shape(ZERO, tile_1A_Center.x, tile_1A_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[2]);
  shape(FOUR, tile_1B_Center.x, tile_1B_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[3]);
  shape(EIGHT, tile_2A_Center.x, tile_2A_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[4]);
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
