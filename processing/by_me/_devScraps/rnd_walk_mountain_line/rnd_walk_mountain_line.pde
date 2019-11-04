//diagon angles for left to right jagged walk: 45, 135 (horizontal: 90);
// first submit is fail do what want, oh well.

void settings() {
  fullScreen();
}

int oldX; int oldY;
int newX; int newY;
int posNegMultiplier = 1;
int vectorDist;
void setup() {
  frameRate(30);
  oldX = 0; oldY = height / 2;
  newX = oldX; newY = oldY;
  vectorDist = 5;
  stroke(0);
  strokeWeight(25);
  strokeCap(PROJECT);
  strokeJoin(MITER);
  print("canvas width: " + width + " canvas height: " + height + "\n");
}

void draw() {
  //for so long as coordinates to draw are on screen:
  if (oldX < width && oldY < height) {
    //toggle incline or decline via pos/neg multiplier:
    vectorDist = (int) random(20, 200);
    posNegMultiplier *= -1;
    newX += vectorDist; newY += (vectorDist * posNegMultiplier);
    line(oldX, oldY, newX, newY);
    print("drew line from " + oldX + "," + oldY + " to " + newX + "," + newY + ".\n");
    oldX = newX; oldY = newY;
  } // else {
    // print("done.\n");
    // }
}
