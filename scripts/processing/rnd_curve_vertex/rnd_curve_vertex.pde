// DESCRIPTION
// Rapidly generates ideas for random squiggle lines, which are random coordinates connected by curves. May be useful as an art idea brainstorming tool when I add image/svg save functionality, which I plan to do. Interesting just to watch though.

// USAGE
// Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.


// CODE
// TO DO: the things in DESCRIPTION.
// foundations of this: https://processing.org/tutorials/curves/

int node_size = 12;
float framesPerSecond = 12;

void setup() {
  size(800, 800);
  smooth();
  noFill();
  stroke(0);
  strokeWeight(2.1);
  rnd_curve_vertices();
  frameRate(framesPerSecond);
}

void rnd_curve_vertices() {
  int numInternalPoints = int(random(5, 30));
  background(255);
  beginShape();
  int start_RND_x = int(random(0, width));
  int start_RND_y = int(random(0, width));
  curveVertex(start_RND_x, start_RND_y); // the first control point
  curveVertex(start_RND_x, start_RND_y); // is also the start point of curve
  ellipse(start_RND_x, start_RND_y, node_size, node_size);
  for (int i = 0; i < numInternalPoints; i++) {
    int middle_RND_x = int(random(0, width));
    int middle_RND_y = int(random(0, width));
    curveVertex(middle_RND_x, middle_RND_y);
    ellipse(middle_RND_x, middle_RND_y, node_size, node_size);
  }
  int end_RND_x = int(random(0, width));
  int end_RND_y = int(random(0, width));  
  curveVertex(end_RND_x, end_RND_y); // the last point of curve
  curveVertex(end_RND_x, end_RND_y); // is also the last control point
  ellipse(end_RND_x, end_RND_y, node_size, node_size);
  endShape();
}

void draw() {
  rnd_curve_vertices();
}

//void mousePressed() {
//  rnd_curve_vertices();
//}

//void keyPressed() {
//  rnd_curve_vertices();
//}
