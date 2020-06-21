// Demonstrates a way to get size values that change up then down over time on a smooth ramp related to the distance of a fixed vertex vs. vertex of a rotating circle. Reduce the problem to its essence for your need . . .

PVector v;
int translate_offset = 200;
float lineDist;
color fillColor;
color altFillColor;
color altFillColorTwo;

void setup() {
  size(400,400);
  //noLoop();
  v = new PVector(0, -200);
  strokeWeight(2.5);
  fillColor = color(255,0,255);
  altFillColor = color(0,255,255);
  altFillColorTwo = color(255,255,0);
  fill(fillColor);
  textSize(32);
}

void draw() {
  translate(translate_offset, translate_offset);
  background(127);
  v.rotate(radians(0.7));
  lineDist = dist(v.x, v.y, 200, 0);
  fill(altFillColor);
  ellipse(0,0,400,400);
  fill(fillColor);
  ellipse(0,0,lineDist,lineDist);
  fill(255,255,0);
  ellipse(v.x, v.y, 15, 15);
  ellipse(200, 0, 15, 15);
  line(v.x, v.y, 200, 0);
  fill(0);
  text(lineDist, 0, 0);
  fill(fillColor);
  translate(translate_offset * (-1), translate_offset * (-1));
}
