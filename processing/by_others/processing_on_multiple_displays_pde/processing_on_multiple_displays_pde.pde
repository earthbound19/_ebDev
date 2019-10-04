/**
 * Multi-Monitor Sketch (v2.21)
 * by GoToLoop (2015/Jun/28)
 *
 * forum.Processing.org/two/discussion/12319/
 * using-papplet-runsketch-to-create-multiple-windows-in-a-sketch
 * 
 * forum.Processing.org/two/discussion/11304/
 * multiple-monitors-primary-dragable-secondary-fullscreen
 *
 * forum.Processing.org/two/discussion/10937/multiple-sketches
 */
 
ProjectorSketch projector;
 
void settings() {
  size(300, 300, JAVA2D);
  smooth(4);
 
  println("Main's  sketchPath: \t\"" + sketchPath("") + "\"");
  println("Main's  dataPath: \t\"" + dataPath("") + "\"\n");
}
 
void setup() {
  noLoop();
  frameRate(60);
  stroke(-1);
  strokeWeight(1.5);
 
  runSketch( new String[] {
    "--display=1", 
    "--location=" + (displayWidth>>2) + ',' + (displayHeight>>3), 
    "--sketch-path=" + sketchPath(""), 
    "" }
    , projector = new ProjectorSketch() );
}
 
void draw() {
  background(0);
  line(0, 0, width, height);
}
 
void mousePressed() {
  projector.getSurface().setVisible(true);
}
 
static final void removeExitEvent(final PSurface surf) {
  final java.awt.Window win
    = ((processing.awt.PSurfaceAWT.SmoothCanvas) surf.getNative()).getFrame();
 
  for (final java.awt.event.WindowListener evt : win.getWindowListeners())
    win.removeWindowListener(evt);
}
 
class ProjectorSketch extends PApplet {
  void settings() {
    size(displayWidth>>1, displayHeight>>1, JAVA2D);
    smooth(4);
 
    println("Inner's sketchPath: \t\"" + sketchPath("") + "\"");
    println("Inner's dataPath: \t\"" + dataPath("") + "\"\n");
  }
 
  void setup() {
    removeExitEvent(getSurface());
 
    frameRate(1);
    stroke(#FFFF00);
    strokeWeight(5);
  }
 
  void draw() {
    background((color) random(#000000));
    line(width, 0, 0, height);
 
    saveFrame( dataPath("screen-####.jpg") );
  }
 
  @ Override void exit() {
  }
}
