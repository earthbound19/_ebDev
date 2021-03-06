// DESCRIPTION
// Interactive demonstration of detection of whether lines intersect. Tweaked from:
// http://www.jeffreythompson.org/collision-detection/line-line.php

// USAGE
// Run the sketch. Move the mouse to move the end of the 2nd line so that it crosses or does not cross the first line, and see what happens.

//CODE
PVector a1 = new PVector(0,0);
PVector a2 = new PVector(10,10);
PVector b1 = new PVector(100,300);
PVector b2 = new PVector(500,100);

// function returns true if lines of 1a-a2 and b1-b2 intersect; false otherwise
boolean checkIfLinesIntersect(PVector a1, PVector a2, PVector b1, PVector b2) {
  // calculate the distance to intersection point:
  float uA = ((b2.x-b1.x)*(a1.y-b1.y) - (b2.y-b1.y)*(a1.x-b1.x)) / ((b2.y-b1.y)*(a2.x-a1.x) - (b2.x-b1.x)*(a2.y-a1.y));
  float uB = ((a2.x-a1.x)*(a1.y-b1.y) - (a2.y-a1.y)*(a1.x-b1.x)) / ((b2.y-b1.y)*(a2.x-a1.x) - (b2.x-b1.x)*(a2.y-a1.y));
  // if uA and uB are between 0-1, lines are colliding:
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    // draw a circle where the lines meet:
    float intersectionX = a1.x + (uA * (a2.x-a1.x));
    float intersectionY = a1.y + (uA * (a2.y-a1.y));
    fill(255,0,0);
    noStroke();
    ellipse(intersectionX,intersectionY, 20,20);
    return true;
  }
  return false;
}


void setup() {
  size(600,400);
  strokeWeight(5);  // make lines easier to see
}


void draw() {
  background(255);
  // set line's end to mouse coordinates:
  a1.x = mouseX; a1.y = mouseY;
  // check for collision; if hit, change color of line:
  boolean hit = checkIfLinesIntersect(a1, a2, b1, b2);
  if (hit == true) {
    stroke(255,150,0, 150);
  } else {
    stroke(0,150,255, 150);
  }
  line(b1.x,b1.y, b2.x,b2.y);
  // draw user-controlled line
  stroke(0, 150);
  line(a1.x,a1.y, a2.x,a2.y);
}