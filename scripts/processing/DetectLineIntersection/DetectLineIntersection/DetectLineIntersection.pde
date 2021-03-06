// DESCRIPTION
// Interactive demonstration of detection of whether lines intersect. Tweaked from:
// http://www.jeffreythompson.org/collision-detection/line-line.php

// USAGE
// Run the sketch. Move the mouse to move the end of the 2nd line so that it crosses or does not cross the first line, and see what happens.

//CODE
float a1x = 0;    // line controlled by mouse
float a1y = 0;
float a2x = 10;   // fixed end
float a2y = 10;

float b1x = 100;  // static line
float b1y = 300;
float b2x = 500;
float b2y = 100;


// LINE/LINE
boolean checkIfLinesIntersect(float a1x, float a1y, float a2x, float a2y, float b1x, float b1y, float b2x, float b2y) {

  // calculate the distance to intersection point
  float uA = ((b2x-b1x)*(a1y-b1y) - (b2y-b1y)*(a1x-b1x)) / ((b2y-b1y)*(a2x-a1x) - (b2x-b1x)*(a2y-a1y));
  float uB = ((a2x-a1x)*(a1y-b1y) - (a2y-a1y)*(a1x-b1x)) / ((b2y-b1y)*(a2x-a1x) - (b2x-b1x)*(a2y-a1y));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {

    // optionally, draw a circle where the lines meet
    float intersectionX = a1x + (uA * (a2x-a1x));
    float intersectionY = a1y + (uA * (a2y-a1y));
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

  // set line's end to mouse coordinates
  a1x = mouseX;
  a1y = mouseY;

  // check for collision
  // if hit, change color of line
  boolean hit = checkIfLinesIntersect(a1x,a1y,a2x,a2y, b1x,b1y,b2x,b2y);
  if (hit) stroke(255,150,0, 150);
  else stroke(0,150,255, 150);
  line(b1x,b1y, b2x,b2y);

  // draw user-controlled line
  stroke(0, 150);
  line(a1x,a1y, a2x,a2y);
}