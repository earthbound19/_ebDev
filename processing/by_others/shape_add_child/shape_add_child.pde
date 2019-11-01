// tweaked from https://processing.org/reference/PShape_addChild_.html for SVG save
// to examine whether things are grouped in the result SVG. THEY ARE. And if I render
// them on their own, they are organized each as their own group.

import processing.svg.*;

PShape house;

void setup() {
  size(200, 200);

  // Make a group PShape
  house = createShape(GROUP);
  
  // Make three shapes
  PShape path = createShape();
  path.beginShape();
  path.vertex(-20, -20);
  path.vertex(0, -40);
  path.vertex(20, -20);
  path.endShape();
  PShape rectangle = createShape(RECT, -20, -20, 40, 40);
  PShape circle = createShape(ELLIPSE, 0, 0, 20, 20);
  
  // Add all three as children
  house.addChild(path);
  house.addChild(rectangle);
  house.addChild(circle);
}

void animate() {
  background(52);
  translate(mouseX, mouseY);
  shape(house);
}

void draw() {
  animate();
}

void mousePressed() {
  beginRecord(SVG, "house.svg");
  background(52);
  translate(mouseX, mouseY);
  shape(house);
  endRecord();
}
