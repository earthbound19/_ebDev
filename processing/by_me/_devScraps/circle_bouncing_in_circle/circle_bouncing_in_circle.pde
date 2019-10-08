// draws a larger and smaller circle, and animates the smaller circle to
// bounce around inside the boundary of the inner circle, via random vector,
// distance from center measurement, and random vector rotation (to bounce) within a range.


PVector v = new PVector(0, 0);
int translate_offset = 200;
PVector a = new PVector(0, 0);
float vector_x; float vector_y;
int x_center;
int y_center;
int outer_circle_diameter;
int inner_circle_diameter;
float max_dist_wander;
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
  int outer_circle_radius = outer_circle_diameter / 5;
  inner_circle_diameter = outer_circle_diameter / 7 * 4;
  max_dist_wander = outer_circle_diameter - inner_circle_diameter;
  max_dist_wander = max_dist_wander * 0.993;
  print("vector_x, vector_y are " + vector_x + ", " + vector_y + "\n");
  randomize_vector_a();
  v.x = x_center; v.y = y_center;
  fill(color(127,0,127));
  stroke(150);
}

void draw() {
  background(100);
  v.add(a);
  // v.rotate(radians(1));
  int wandered_distance = (int) dist(x_center, y_center, v.x, v.y);
  if (wandered_distance > max_dist_wander / 2) {
    // print("Have surpassed straying boundary; will undo vector add and change vector..\n");
    // undo add:
    v.sub(a);
    float rotation_angle = random(130, 230);
    a.rotate(radians(rotation_angle));
  }
  fill(127,0,255);
  stroke(200);
  ellipse(x_center, y_center, outer_circle_diameter, outer_circle_diameter);
  fill(inner_circle_fill);
  stroke(inner_circle_stroke);
  ellipse(v.x, v.y, inner_circle_diameter, inner_circle_diameter);
}
