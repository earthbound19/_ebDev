// Random walk with drawn primary shapes (with outlines) of
// colors randomly chosen from palette.
// by Richard Alexander Hall
// evolved from rnd_walk_draw_square.pde

// Global variables:
color backgroundColor = #9B98A2;  // Prismacolor Cool Grey 50%
int globalStrokeWeight = 24;
// Prismacolor marker colors array:
color[] Prismacolors = {
  #E54D93, #F9E3E0, #D13352, #E14E6D, #F45674, #EA5287, #EF7FAD,
  #F6C6D0, #F895AC, #F4DCD7, #F9C0BC, #F65C6A, #F86060, #FD9863,
  #FA855B, #F7D580, #ECBF7A, #F5D969, #F3C77D, #EEE2C7, #EEE4DC,
  #93CD87, #75755C, #C6DD8E, #687B57, #618979, #009E90, #A2B1A2,
  #008D94, #4F8584, #00B3DB, #0090C7, #33549B, #405F89, #435BA3,
  #574C70, #0BBDC4, #4CC8D9, #97C1DA, #934393, #CA4587, #E65F9F,
  #D8308F, #B1A1C9, #88595C, #8D6E64, #BD6E6B, #EBB28B, #F5DCD5,
  #F7DDCB, #C97B8E, #F0CCC4, #E5E4E9, #F5D3DD, #D46569, #CA5A62,
  #A0716D, #DEBBB3, #C87F73, #EE8A74, #C9877F, #EDD6BF, #5B4446,
  #524547, #F1E5E9, #F0D9DC, #E9C9D1, #C5AAB4, #B7A1AF, #A58E9A,
  #8C7B87, #6A5B67, #62555E, #DDDBE0, #C7C6CD, #C8C7CE, #A4A1A9,
  #9B98A2, #7F7986, #857F8A, #72727D, #615F6B, #FCC0BA, #FFC874,
  #BEB27B, #367793, #6389AB, #8D6CA9, #AF62A2, #FEC29F, #F2D8A4,
  #F8D9BE, #ECA6B9, #7AD2E2, #E497A4, #A7BCBB, #95B6BA, #7B91A2,
  #69A2BE, #C9CBE0, #A1A6D0, #C0A9BE, #AA8E79, #8E4C5C, #AA4662,
  #C14F6E, #D96A6E, #F98973, #F7DFD8, #D1BCBD, #CBADB1, #BFA9A8,
  #B19491, #987D80, #877072, #745D5F, #72646C, #36B191, #66C7B0,
  #8F4772, #B34958, #FA9394, #AC9EB8, #9B685D, #59746E, #1E7C72,
  #009D79, #82B079, #91BACB, #E0BFB5, #74B3E3
};
int PrismacolorArrayLenghth = Prismacolors.length; 


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
      //clear the background (in case it is a colored square) by filling the area with the background:
      strokeWeight(globalStrokeWeight + 20);  // note this must be larger than the hard-coded strokeWeight in a few lines--because the same weight leaves trace pixels of former color behind! This overlaps that.
      fill(backgroundColor);
      stroke(backgroundColor);
      rect(posX, posY, tileSizeX, tileSizeY);
    // set stroke weight again and colors to random selection from color array:
    strokeWeight(globalStrokeWeight);
    int RNDarrayIndex = (int)random(PrismacolorArrayLenghth);
    stroke(Prismacolors[RNDarrayIndex]);
    RNDarrayIndex = (int)random(PrismacolorArrayLenghth);
    fill(Prismacolors[RNDarrayIndex]);
    int choice = (int) random(3);
    switch (choice)
    {
      case 0:  // circle
        ellipse(posX, posY, tileSizeX, tileSizeY);
        break;
      case 1:  // square
        rect(posX, posY, tileSizeX, tileSizeY);
        break;
      case 2:  // triangle
        triangle(posX, (posY + tileSizeX)  ,  (posX + (tileSizeX / 2)), (posY + (globalStrokeWeight / 2))  ,  (posX + tileSizeX), (posY + tileSizeY));
        break;
    }
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
  fullScreen();
  // uncomment this override and comment out the previous line if
  // you use saveFrame() below for animation:
  //size(1920,1080);
  int RNDarrayIndex = (int)random(Prismacolors.length);
  background(backgroundColor);
  // Create walker objects
  walkerOne = new Walker();
  walkerTwo = new Walker();
  walkerThree = new Walker();
  walkerFour = new Walker();
  ellipseMode(CORNER);
}


// FOR OPTIONAL code block to terminate sketch after N frames:
// (More global variables)
//int framesCounter = 0;
//int maxFrames = 300;

// main Processing draw function (it loops infinitely)
void draw() {
  //FOR OPTIONAL CODE BLOCK below:
//  framesCounter += 1;
  // Run the walker objects
  walkerOne.step(); walkerTwo.step(); walkerThree.step(); walkerFour.step();
  walkerOne.render(); walkerTwo.render(); walkerThree.render(); walkerFour.render();
  delay(86);  // this delay makes the render rate slightly less than insane
  //saveFrame();

      //OPTIONAL CODE BLOCK: terminate sketch after N renders:
  //    if (framesCounter >= maxFrames) {
   //     exit();
     // }
}
