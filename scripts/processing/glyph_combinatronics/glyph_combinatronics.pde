// DESCRIPTION
// This is in development and not necessarily to my liking yet. The functionality may vary from this description in development or even finally. Displays 4 glyphs from a set of 16, in a 4-tile, in a sequence all possible combinations of the tiles, repetition allowed, each tile rotating in 90 degree increments. 4 tiles * 4 rotations each = 16 possible tile views, 16 views pick 4 all possible combos allow repeat = 65535 4-tile views.

// USAGE
// Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.


// CODE
// v0.9.3

// DEV LOG
// - displayed variant logging (currently rendered variant written to data/lastDisplayedVariant.txt)
// TO DO NEXT:
// 1. load variant from that file if exists
// 2. load from data/all16products.txt
// 3. if no error finding loaded variant in all16products:
// 3B find variant following loaded variant (in all16products)
// 3C iterate through variants starting with that and following sequence
// 4. otherwise, start sequence from start of all16products, logging each to lastDisplayedVariant
String versionCode = "0.9.3";


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
PShape TILE_0; PShape TILE_1; PShape TILE_2; PShape TILE_3;
PShape TILE_4; PShape TILE_5; PShape TILE_6; PShape TILE_7;
PShape TILE_8; PShape TILE_9; PShape TILE_A; PShape TILE_B;
PShape TILE_C; PShape TILE_D; PShape TILE_E; PShape TILE_F;
// array of all those tiles:
PShape[] allTiles = new PShape[16];
int allTilesLength = allTiles.length;
float OT; // Offset Tweak
float OTmultiplier = 0.0;    // the higher this is toward 1, the more tiles will crowd toward center. 0 = no crowding.

color[] colors = {
	#FF00FF, #FF00C0, #FF007F, #7F007F, #40007F, #5F00BE, #7F40FF, #6060FF,
	#6A6AFF, #7F7FFF, #4894EA, #00AFCF, #00CFFF, #00C4FF, #00E4FF, #7FFFFF,
	#76E1A8, #40F37E, #52FE79, #00E77D, #1DCF00, #65D700, #AFE300, #85FF00,
	#00FF00, #B5FF00, #FFFF00, #FFD500, #FFB700, #FD730A, #FF5100, #FF0000,
	#7F0000, #3325D6, #4040FF, #00007F, #0000FF, #007FFF
};
// variables for timing:
float millis_since_last_change;
float now;
float millisecondsPerDrawingChange = 468.75 * 4;
// for logging every displayed variant to a file so we can restore from that variant on program relaunch:
PrintWriter output;
// hex digit array:
char[] hexDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

void setup() {
   size(800, 800);
  //fullScreen();
  int lengthToUse;
  if (width <= height) { lengthToUse = width; } else { lengthToUse = height; }
  gridXYlength = lengthToUse - (gridPaddingFromEdge * 2);
  cellXYlength = gridXYlength / cellsXY;
  xScreenCenter = width / 2;
  yScreenCenter = height / 2;
  OT = gridXYlength * OTmultiplier;
  float cellOffsetToCenter = (cellXYlength / 2);
// would like to have OT be either 0 or multiplier every run of change_drawing, via
// rnd true/false boolean like this: useOT = random(1) > .5;
  tile_1A_Center = new PVector(xScreenCenter - cellOffsetToCenter + OT, yScreenCenter - cellOffsetToCenter + OT);
  tile_1B_Center = new PVector(xScreenCenter + cellOffsetToCenter - OT, yScreenCenter - cellOffsetToCenter + OT);
  tile_2A_Center = new PVector(xScreenCenter - cellOffsetToCenter + OT, yScreenCenter + cellOffsetToCenter - OT);
  tile_2B_Center = new PVector(xScreenCenter + cellOffsetToCenter - OT, yScreenCenter + cellOffsetToCenter - OT);
  // svg files must be in the /data folder of the current sketch to load successfully:
  TILE_0 = loadShape("0.svg"); TILE_0.disableStyle(); allTiles[0] = TILE_0;
  TILE_1 = loadShape("1.svg"); TILE_1.disableStyle(); allTiles[1] = TILE_1;
  TILE_2 = loadShape("2.svg"); TILE_2.disableStyle(); allTiles[2] = TILE_2;
  TILE_3 = loadShape("3.svg"); TILE_3.disableStyle(); allTiles[3] = TILE_3;
  TILE_4 = loadShape("4.svg"); TILE_4.disableStyle(); allTiles[4] = TILE_4;
  TILE_5 = loadShape("5.svg"); TILE_5.disableStyle(); allTiles[5] = TILE_5;
  TILE_6 = loadShape("6.svg"); TILE_6.disableStyle(); allTiles[6] = TILE_6;
  TILE_7 = loadShape("7.svg"); TILE_7.disableStyle(); allTiles[7] = TILE_7;
  TILE_8 = loadShape("8.svg"); TILE_8.disableStyle(); allTiles[8] = TILE_8;
  //TILE_8 = loadShape("8-B-alt.svg"); TILE_8.disableStyle(); allTiles[2] = TILE_8;
  TILE_9 = loadShape("9.svg"); TILE_9.disableStyle(); allTiles[9] = TILE_9;
  TILE_A = loadShape("A.svg"); TILE_A.disableStyle(); allTiles[10] = TILE_A;
  TILE_B = loadShape("B.svg"); TILE_B.disableStyle(); allTiles[11] = TILE_B;
  TILE_C = loadShape("C.svg"); TILE_C.disableStyle(); allTiles[12] = TILE_C;
  TILE_D = loadShape("D.svg"); TILE_D.disableStyle(); allTiles[13] = TILE_D;
  TILE_E = loadShape("E.svg"); TILE_E.disableStyle(); allTiles[14] = TILE_E;
  TILE_F = loadShape("F.svg"); TILE_F.disableStyle(); allTiles[15] = TILE_F;
  shapeMode(CENTER);
  strokeWeight(0);
  change_drawing();    // only called once here in setup (as setup is only called once)
}

// does what I want, I don't know how :shrug: used by getNrndColors() ;
// from: https://forum.processing.org/two/discussion/7696/unique-random-number-for-elements-in-array
static final boolean contains(int n, int... nums) {
  for (int i : nums)  if (i == n)  return true;
  return false;
}

color[] getNrndColors(int howMany, color[] palette) {
  color[] returnColors = new color[howMany];
  // get an array of unique numbers which are indices of palette;
  // NOTE the QTY must be <= RANGE:
  int QTY = howMany, RANGE = palette.length;
  final int[] numbers = new int[QTY];
  for (int rnd, i = 0; i != QTY; ++i) {
    numbers[i] = MIN_INT;
    while (contains(rnd = (int)random(0, RANGE), numbers));
      numbers[i] = rnd;
  }
  // use rnd unique number indeces to create palette of 5 unique colors from other palette:
  //print("\n");
  for (int j = 0; j < numbers.length; j++) {
    //print(numbers[j] + "\n");
    returnColors[j] = colors[numbers[j]];
  }
  // return that palette:
  return returnColors;
};

void setFillAndStroke(color wut) {
  fill(wut); stroke(wut);
}

void change_drawing() {
  millis_since_last_change = millis();
  color[] RND5colors = getNrndColors(9, colors);
  background(RND5colors[0]);
  setFillAndStroke(RND5colors[1]);
    int tileA = int(random(0, allTilesLength));
  shape(allTiles[tileA], tile_1A_Center.x, tile_1A_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[2]);
    int tileB = int(random(0, allTilesLength));  
  shape(allTiles[tileB], tile_1B_Center.x, tile_1B_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[3]);
    int tileC = int(random(0, allTilesLength));
  shape(allTiles[tileC], tile_2A_Center.x, tile_2A_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[4]);
    int tileD = int(random(0, allTilesLength));
  shape(allTiles[tileD], tile_2B_Center.x, tile_2B_Center.y, cellXYlength, cellXYlength);
  output = createWriter("data/lastDisplayedVariant.txt");
  //String referenceSTR = str(tileA);
  String variant = str(hexDigits[tileA]) + str(hexDigits[tileB]) + str(hexDigits[tileC]) + str(hexDigits[tileD]);
  output.println(variant);
  output.flush();
  output.close();
}

void draw(){
  now = millis();
  if ((now - millis_since_last_change) > millisecondsPerDrawingChange) {
    change_drawing();
  }
}

// to do: change to ~1 second timer, not mousePressed() event:
void mousePressed() {
  change_drawing();
}

//void keyPressed() {
//  change_drawing();
//}
