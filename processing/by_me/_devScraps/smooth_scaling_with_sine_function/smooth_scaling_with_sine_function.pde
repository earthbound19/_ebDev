/**
 * Sine. 
 * 
 * Smoothly scaling size with the sin() function. 
 * Adapted by RAH from an example code file that ships with Processing.
 */
 
float maxDiameter;
float circleDiameter;
float minMaxPad = 50;
float angle = 0;

void setup() {
  size(360, 360);
  maxDiameter = height - minMaxPad;
  noStroke();
  fill(255, 204, 0);
  print("angle,diameter\n");
}

void draw() {
  
  background(0);

  circleDiameter = minMaxPad + (sin(angle) * maxDiameter/2) + maxDiameter/2;

  ellipse(width/2, height/2, circleDiameter, circleDiameter);
  
  angle += 0.008;
  print(angle + "," + circleDiameter, "\n");
  if (angle > 6.28) {   // because 6.28 is the max radian value
    angle = 0;
    // print("yarf!\n");    // for help finding the near-zero switch in csv debugging
  }
}