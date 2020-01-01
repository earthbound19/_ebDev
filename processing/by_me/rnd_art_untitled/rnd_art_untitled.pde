// DESCRIPTION
// Draws random straight lines through vertices
// over RNDpointsPerArea points each per cols and rows (colums and rows)
// of canvas. Hack the values of the following GLOBAL VARIABLES per preference,
// and run the script.
// TO DO: saves result to SVG file.

// GLOBAL VARIABLES.
int cols = 2;    // how many columns to divide the canvas into
int rows = 2;    // how many rows to divide the canvas into
int RNDpointsPerArea = 2;   // how many RND vectors (x,y coordinates) to obtain per area?
int cellXboundaryMultiplier;    // will be int(width / cols via setup()
int cellYboundaryMultiplier;    // will be int(height / rows via setup()
PVector previousPoint;    // for reference in drawing line from one
// point to newly generated point; will be initialized in setup()

// returns RND PVector within the (intended) rectangular area of two PVectors. 
PVector RNDpvectorWithinArea(PVector upper_left, PVector lower_right) {
  int RNDx = int(random(upper_left.x, lower_right.x));
  int RNDy = int(random(upper_left.y, lower_right.y));
  //print(RNDx + "," + RNDy + "\n");
  return new PVector(RNDx, RNDy);
}

void setup() {
  //fullScreen();
  size(800, 800);
  cellXboundaryMultiplier = int(width / cols);
  cellYboundaryMultiplier = int(height / rows);
  //previousPoint = RNDpvectorWithinCenterToPoint(new PVector(cellXboundaryMultiplier, cellYboundaryMultiplier));
  ellipseMode(CENTER);
  stroke(6);
}

int rowsLoop = 0; int colsLoop = 0;
void draw() {
  while (rowsLoop < rows) {
    while (colsLoop < cols) {
      print("UL.x " + colsLoop + " rowsLoop: " + rowsLoop + "\n");

      //line(previousPoint.x, previousPoint.y, rndVector.x, rndVector.y);
      //previousPoint = rndVector;
      //print(rndVector.x + "," + rndVector.y + "\n");
      colsLoop += 1;
    }
  colsLoop = 0;
  rowsLoop += 1;
  }
}
