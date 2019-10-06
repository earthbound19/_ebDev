// because alas, Processing has no built in polygon object, re https://processing.org/examples/regularpolygon.html
// -- but it can be accomplished relatively easily enough with a PVector and PShape:
// .. "easily enough," and then it took me two hours to iron out details that get it to draw correctly and well.

PShape s;

void settings() {
  size(640, 640);
}

void setup()
{
  // I don't know why the following default shapeMode, CORNER, locates shapes as I expect (centered), while
  // CENTER mode does not? Maybe the "corner" via the way I build shapes here _is_ the center?
  shapeMode(CORNER);
  ellipseMode(CENTER);
// TO DO: figure out how to have instrinsic stroke weight to a shape,
// if possible--and why this weight only has effect here, and not right before the shape() call:
  strokeWeight(50);
  PVector v = new PVector(0, (width / 3 * (-1)) );
  PShape s = createShape();
  s.beginShape();
  // THIS IS WHERE THERE'S MAGIC: for a triangle, set it to 3, for a square, 4, a pentagon, 5, hexagon 7, etc.;
// TO DO: set n-gons with even number of sides to rotate angle_step / 2 (to "rest" the "bottom" line "flat" against imaginary "ground?"
  float vertices = 7;  // interestingly, 2 will just make a line.
  float angle_step = 360 / vertices;
  print("angle_step is " + angle_step + "\n");
  for (int i=0; i<vertices; i++) {
    print("i is " + i + "\n");
    s.vertex(v.x, v.y);
    v.rotate(radians(angle_step));
    }
  // if this is not done, there will be no edge style (indeed no edge?) from the last vertex to the first,
  // whereas if I manually create that with a duplicate vertex over the first, it does ugly mitering/cornering:
  s.endShape(CLOSE);
  s.setFill(color(255,0,255));
  s.setStroke(127);
  // reference shape manipulation functions:
  // s.translate(50, 50); s.rotate(radians(-10)); s.scale(0.82); s.resetMatrix();
  // TO DO: figure out why I get a null pointer exception if I move this into draw() ; maybe having to do with when object allocated? :
  shape(s, width / 2, height /2);
  //TO TRY:
  //- s.translate(10, 0); 
}
