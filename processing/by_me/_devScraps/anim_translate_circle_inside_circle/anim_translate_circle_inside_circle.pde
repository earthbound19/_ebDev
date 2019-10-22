float largerCircleDiameter;
float smallerCircleDiameter;

float centers_distance;
float target_centers_distance;
float larger_circle_X; float larger_circle_Y;
float larger_circle_diameter;
float smaller_circle_X; float smaller_circle_Y;
float smaller_circle_diameter;

color orange = color(255,255,127);
color cyan = color(0,255,255);

void settings() {
size(640,640);
}

void setup() {
  frameRate(0.28);
  ellipseMode(CENTER);
  larger_circle_X = (width / 50) * random(15, 30);
  larger_circle_Y = (width / 50) * random(15, 30);
  larger_circle_diameter = (width / 20) * random(8, 11);
  smaller_circle_X = (width / 70) * random(10, 60);
  smaller_circle_Y = (width / 70) * random(10, 60);
  smaller_circle_diameter = (width / 40) * random(8, 11);
  //noLoop();
}

void draw() {
  background(100);
  strokeWeight(4);
  stroke(cyan);
  fill(127);
  ellipse(larger_circle_X, larger_circle_Y, larger_circle_diameter, larger_circle_diameter);
  ellipse(smaller_circle_X, smaller_circle_Y, smaller_circle_diameter, smaller_circle_diameter);

  // Could a trigonometric function (sin, cos, or tan) do this in fewer lines of code, yet confuse me? :)
  float circles_center_to_center_dist = dist(larger_circle_X, larger_circle_Y, smaller_circle_X, smaller_circle_Y);
  float target_centers_dist = (larger_circle_diameter / 2) - (smaller_circle_diameter / 2);
  float centers_to_target_dist_mult = target_centers_dist / circles_center_to_center_dist;
  float Xdiff = larger_circle_X - smaller_circle_X;
  float Ydiff = larger_circle_Y - smaller_circle_Y;
  float newX = larger_circle_X - (Xdiff * centers_to_target_dist_mult);   // a + will put it tangent opposite side
  float newY = larger_circle_Y - (Ydiff * centers_to_target_dist_mult);
  stroke(orange);
  ellipse(newX, newY, smaller_circle_diameter, smaller_circle_diameter);
  setup();
}
