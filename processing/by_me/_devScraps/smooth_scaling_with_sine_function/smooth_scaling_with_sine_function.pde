/**
 * Sine. 
 * 
 * Smoothly scaling size with the sin() function.
 * Adapted by RAH from an example code file that ships with Processing.
 */
 
float diameter; 
float angle = 0;

void setup() {
  size(640, 360);
  diameter = height - 10;
  noStroke();
  fill(255, 204, 0);
}

void draw() {

  background(0);

  diameter = sin(angle) * (height - 60) + 10;

  ellipse(width/2, height/2, diameter, diameter);
  
  angle += 0.007;
  if (angle > 6.28) {
    angle = 0;
  }
  print("angle: " + angle + "\tdiameter: " + diameter + "\n");
}
