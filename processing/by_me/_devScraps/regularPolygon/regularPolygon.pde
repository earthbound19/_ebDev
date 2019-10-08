// because alas, Processing has no built in polygon object, re https://processing.org/examples/regularpolygon.html
// -- but it can be accomplished relatively easily enough with a PVector and PShape:
// .. "easily enough," and then it took me two hours to iron out details that get it to draw correctly and well.

PShape s;


// IN DEVELOPMENT: a class containing information and functionality to do the below (copying and will move that code into a class) :
class PersistentNGon {
  float diameter;
  float diameter_min;
  float diameter_max;
  float diameter_morph_rate;
  private PVector radiusVector;  // used to effectively define visual radius
  int sides;  // 2 = line, 3 = triangle, 4 = square, 5 = pentagon, etc.
  int x_origin;
  int y_origin;
  int x_center;
  int y_center;
  color fill_color;
  int fill_color_palette_idx;
  color stroke_color;
  int stroke_color_palette_idx;
  float stroke_weight;
  private PShape s;   // contains vertices, fill and line stroke colors
  int x_wandered;
  int y_wandered;
  float max_wander_dist_mult;
  float wander_max_step_mult;
  int milliseconds_elapse_to_color_morph;
  int milliseconds_at_last_color_change_elapsed;
  boolean color_morph_on;
  boolean rotation_enabled;
  float rotation_degrees_per;
  PersistentNGon(int xCenter, int yCenter, float diameterMin, float diameterMax, int sides) {
    
  }
}


void settings() {
  size(640, 640);
}

void setup()
{
  // I don't know why the following default shapeMode, CORNER, locates shapes as I expect (centered), while
  // CENTER mode does not? Maybe the "corner" via the way I build shapes here _is_ the center?
  shapeMode(CORNER);
  ellipseMode(CENTER);
  strokeWeight(20);
}

void draw() {
  delay(1750);
  background(50);
  // NOTE that PShapes have no intrinsic stroke attribute--whatever is the current global stroke will be used.
    // The way the vector is used, its' x attribute is the distance from the intended center of the shape to edge, so the distance of the radius, OR diameter / 2:
    PVector radiusVector = new PVector(0, (width / 2 * (-1)) );
    PShape s = createShape();
    s.beginShape();
    // THIS IS WHERE THERE'S MAGIC: for a triangle, set it to 3, for a square, 4, a pentagon, 5, hexagon 7, etc.;
  // TO DO: set n-gons with even number of sides to rotate angle_step / 2 (to "rest" the "bottom" line "flat" against imaginary "ground?"
    int vertices = (int) random(3, 8);  // interestingly, 2 will makes a line if the line stroke > 0.
    float angle_step = (float) 360 / (float) vertices;
    print("vertices: " + vertices + " angle step: " + angle_step + "\n");
    for (int i=0; i<vertices; i++) {
      // print("i is " + i + "\n");
      s.vertex(radiusVector.x, radiusVector.y);
      radiusVector.rotate(radians(angle_step));
      }
    // if this is not done, there will be no edge style (indeed no edge?) from the last vertex to the first,
    // whereas if I manually create that with a duplicate vertex over the first, it does ugly mitering/cornering:
    s.endShape(CLOSE);
    s.setFill(color(255,0,255));
    s.setStroke(90);
    // reference shape manipulation functions:
    // s.translate(50, 50); s.rotate(radians(-10)); s.scale(0.82); s.resetMatrix();
    // TO DO: figure out why I get a null pointer exception if I move this into draw() ; maybe having to do with when object allocated? :
    int two_division_remainder = vertices % 2;
    if (two_division_remainder == 0) { s.rotate(radians(angle_step / 2)); }
    strokeWeight((int) random(20, 45));
    shape(s, width / 2, height /2);
    //TO TRY:
    //- s.translate(10, 0);
}
