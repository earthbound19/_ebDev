// Random walk with drawn squares (with outlines) of random colors.
// by Richard Alexander Hall
// Heavily modified from Random Walker example, "The Nature of Code," by Daniel Shiffman, http://natureofcode.com

//Walker class
class Walker {
  // members
  int posX, posY;
  int spacingSizeX, spacingSizeY;
  int tileSizeX, tileSizeY;
  int widthVSspacingSizeXmodulo, widthVSspacingSizeYmodulo;
  int tilesX, tilesY;
  int canvasSetX, canvasSetY;

  // constructor
  Walker() {
    spacingSizeX = 128;
    spacingSizeY = 128;
    tileSizeX = 80;
    tileSizeY = 80;
    canvasSetX = displayWidth; canvasSetY = displayHeight;
    // if you'd rather override that canvas size, uncomment the next line; also uncomment the size override further below in code:
    //canvasSetX = 1280; canvasSetY = 720;
    //for figuring out the boundary past which we must reset the x or y pos to the next lowest multiple of spacingSizeX and spacingSizeY:
    widthVSspacingSizeXmodulo = canvasSetX % spacingSizeX;
    widthVSspacingSizeYmodulo = canvasSetY % spacingSizeY;
    tilesX = canvasSetX / spacingSizeX;
    tilesY = canvasSetY / spacingSizeY;
    //print("Display dimensions are " + displayWidth + " x " + displayHeight);
    posX = (int) random(tilesX) * spacingSizeX;  // weird casting to int type
    posY = (int) random(tilesY) * spacingSizeY;
  }

  // member functions
  void render() {
    strokeWeight(24);
    stroke(random(255), random(255), random(255));
    fill(random(255), random(255), random(255));
    rect(posX, posY, tileSizeX, tileSizeY);
  }

  // Randomly move up, down, left, right, or stay in one place
  void step() {

    int choice = int(random(4));

    if (choice == 0) {
      posX+=spacingSizeX;
    } else if (choice == 1) {
      posX-=spacingSizeX;
    } else if (choice == 2) {
      posY+=spacingSizeY;
    } else {
      posY-=spacingSizeY;
    }

    posX = constrain(posX, 0, (width - widthVSspacingSizeXmodulo));
    posY = constrain(posY, 0, (height -widthVSspacingSizeYmodulo));
  }
}

// global instances of Walker objects
Walker walkerOne;
Walker walkerTwo;
Walker walkerThree;
Walker walkerFour;

// Main Processing setup funtion
void setup() {
  size(displayWidth, displayHeight);
  //size(1280,720);  // uncomment this override if you use saveFrame() below for animation:
  // Create walker objects
  walkerOne = new Walker();
  walkerTwo = new Walker();
  walkerThree = new Walker();
  walkerFour = new Walker();
  background(126);
}

// main Processing draw function (it loops infinitely)
void draw() {
  // Run the walker objects
  walkerOne.step(); walkerTwo.step(); walkerThree.step(); walkerFour.step();
  walkerOne.render(); walkerTwo.render(); walkerThree.render(); walkerFour.render();
  delay(86);  // this delay makes the render rate slightly less than insane
  //saveFrame();
}
