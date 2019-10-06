//draws a circle which orbits the center of the plane via vector rotation (must translate image to have it in center--otherwise it would orbit corner)

PVector v;
//PVector a;
int translate_offset = 200;

void setup() {
  size(400,400);
  //noLoop();
  v = new PVector(0, -200);
  //a = new PVector(3, 3);
}

void draw() {
  background(127);
  //v.add(a);
  v.rotate(radians(3));
  translate(translate_offset, translate_offset);
  ellipse(v.x, v.y, 10, 10);
  translate(translate_offset * (-1), translate_offset * (-1));
}
