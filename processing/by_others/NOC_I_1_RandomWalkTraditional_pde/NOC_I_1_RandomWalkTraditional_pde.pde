// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// A random walker object!
// tweaked by RAH to:
// - remember the previous positoin and draw a line therefrom
// - render lines over a grid space
// - randomly alter line color

//global grid spacing control variable:
int gridSpace = 20;
int previousXpos = 0;
int previousYpos = 0;
int previousChoice = 0;

class Walker {
  int x,y;

  Walker() {
    x = width/2;
    y = height/2;
  }

  void render() {
    stroke(random(180),random(180),random(255));
    //point(x,y);
    line(previousXpos, previousYpos, x, y);
  }

  // Randomly move up, down, left, right, or stay in one place
  void step() {
    
    previousXpos = x;
    previousYpos = y;
    
    int choice = int(random(4));
    
    if (choice == 0) {
      x+=gridSpace;
    } else if (choice == 1) {
      x-=gridSpace;
    } else if (choice == 2) {
      y+=gridSpace;
    } else {
      y-=gridSpace;
    }

    x = constrain(x,0,width);
    y = constrain(y,0,height);
  }
}


Walker w;

void settings(){
  size(640,360);
}

void setup() {
  // Create a walker object
  w = new Walker();
  background(255);
}

void draw() {
  // Run the walker object
  w.step();
  w.render();
}
