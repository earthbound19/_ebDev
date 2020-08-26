// DESCRIPTION
// Renders a random jagged mountain line of 45 or 135 deg. slopes only.

// USAGE
// - Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.
// - Click to render a new random line.


// CODE
// by Richard Alexander Hall

void settings() {
  fullScreen();
}

int oldX; int oldY;
int newX; int newY;
int posNegMultiplier = 1;
int vectorDist;

void init() {
  background(127);
  oldX = 0; oldY = height / 2;
  newX = oldX; newY = oldY;
  vectorDist = 5;
  stroke(0);
  strokeWeight(25);
  strokeCap(PROJECT);
  strokeJoin(MITER);
  print("canvas width: " + width + " canvas height: " + height + "\n");
}

void setup() {
  frameRate(30);
  init();
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

// draw a new line on mouse press:
void mousePressed() {
  init();
}
