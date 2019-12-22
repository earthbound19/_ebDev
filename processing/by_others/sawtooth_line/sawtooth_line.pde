//source: https://forum.processing.org/two/discussion/2221/drawing-a-zig-zag-with-a-loop

int x, r;
 
void setup() {
  size(800, 100);
  r = height/2;
  background(255);
  stroke(0);
}
void draw() {
 
  int pos_x = width+x;
 
  if (pos_x>0)
    x--; 
 
 
  int y = r-abs((x%(r+1)));
  int pos_y = height/4 + y;
 
  point (pos_x, pos_y);
 
  if (y==r)
    line(pos_x, pos_y, pos_x, height/4);
 
}
