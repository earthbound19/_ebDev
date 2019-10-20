// draws a larger and smaller circle, and animates the smaller circle to
// bounce around inside the boundary of the inner circle, via random vector,
// distance from center measurement, and random vector rotation (to bounce) within a range.


PVector innerCircleCenter = new PVector(0, 0);
float translate_offset = 200;
PVector a = new PVector(0, 0);
float vector_x; float vector_y;
float x_center;
float y_center;
float outer_circle_diameter;
float inner_circle_diameter;
float max_wander_dist;
color inner_circle_fill = color(255,0,255);
color inner_circle_stroke = color(150);

void randomize_vector_a() {
  // to randomly change any number to positive or negative, multiply by: * ((int) random(0,2)*2-1);
  float vector_x = random(-1.283, 1.284);
  float vector_y = random(-1.283, 1.284);
  a.x = vector_x; a.y = vector_y;
  // if a.x and a.y are both 0, randomize again--by calling this function itself--meta! :
  while (a.x == 0 && a.y == 0) {
    randomize_vector_a();
  }
}


void setup() {
  size(400,400);
  x_center = width / 2;
  y_center = height / 2;
  outer_circle_diameter = height / 5 * 4;
  float outer_circle_radius = outer_circle_diameter / 5;
  inner_circle_diameter = outer_circle_diameter / 7 * 4;
  max_wander_dist = (outer_circle_diameter / 2) - (inner_circle_diameter / 2);
  print("vector_x, vector_y are " + vector_x + ", " + vector_y + "\n");
  randomize_vector_a();
  innerCircleCenter.x = x_center; innerCircleCenter.y = y_center;
  fill(color(127,0,127));
  stroke(150);
}

void draw() {
  background(100);
  innerCircleCenter.add(a);

  int wandered_distance = (int) dist(x_center, y_center, innerCircleCenter.x, innerCircleCenter.y);
  if (wandered_distance > max_wander_dist) {
    // print("Have surpassed straying boundary; will undo vector add and change vector..\n");
    // undo add:
    innerCircleCenter.sub(a);
    float rotation_angle = random(130, 230);
    a.rotate(radians(rotation_angle));
  }
  
  fill(127,0,255);
  stroke(200);
  ellipse(x_center, y_center, outer_circle_diameter, outer_circle_diameter);
  
  fill(inner_circle_fill);
  stroke(inner_circle_stroke);
  ellipse(innerCircleCenter.x, innerCircleCenter.y, inner_circle_diameter, inner_circle_diameter);
}
