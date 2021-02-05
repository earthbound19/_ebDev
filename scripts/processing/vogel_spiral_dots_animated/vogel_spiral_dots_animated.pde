// DESCRIPTION
// Generates points of a Vogel spiral (Fibonacci spiral variant), and animates attributes of the dot (what is animated may vary with different versions of this script that I might make, and different parameters I may give it).

// DEPENDENCIES
// dawesome toolkit (Processing library)

// USAGE
// Install Processing, open this file in the Processing editor or a Processing script runner, and run the script.


// CODE
String version = "1.0.0";

import dawesometoolkit.*;

class wrappingColorIDX {
  int colorIDX = 0;
  int maxColorIDX = 0;
  
  wrappingColorIDX(int initColorIDX, int passedMaxColorIDX) {
    colorIDX = initColorIDX;
    maxColorIDX = passedMaxColorIDX;
  }
  
  void rotateColorIDX() {
    colorIDX += 1;
    if (colorIDX >= maxColorIDX) {colorIDX = 0;}
  }
}

DawesomeToolkit dawesome;
ArrayList<PVector> layout;
ArrayList<wrappingColorIDX> bgPointColors;
int backgroundDotSize = 20;
int foregroundDotSize = 15;
int vogelPointsDistance = 13;
color[] backgroundDotRNDcolors = {
  // tweaked with less pungent and more pastel orange and green, from _ebPalettes 16_max_chroma_med_light_hues_regular_hue_interval_perceptual.hexplt:
  #f800fc, #ff0596, #ea0000, #fb5537, #ff9710, #ffc900, #feff06, #a0d901,
  #85e670, #0ccab3, #01edfd, #00a6fe, #0041ff, #9937ff, #c830ff
  // omitted because it is used for the foreground dot color: #5c38ff
};
int backgroundDotRNDcolorsArrayMaxIDX = backgroundDotRNDcolors.length;

void setup(){
  fullScreen();
  // size(1200,630);
  // size(1920,1080);
  boolean widthGreaterThanHeight;
  //determine if width or height is greater and do math on the larger value:
  int howManyVogelPoints;
  if (width > height) {howManyVogelPoints = int(width * 3.8);} else {howManyVogelPoints = int(height * 3.8);}
  dawesome = new DawesomeToolkit(this);
  layout = dawesome.vogelLayout(howManyVogelPoints,vogelPointsDistance);
  bgPointColors = new ArrayList<wrappingColorIDX>();
  
  // init bgPointColors ArrayList; thx to help from: https://stackoverflow.com/a/3982597
  bgPointColors = new ArrayList<wrappingColorIDX>();
  int bgColorInitIDX = 0;
  for (PVector p : layout) {
    // add one to bgPointColors for every point in layout, with rnd start IDX, highest poss idx backgroundDotRNDcolorsArrayMaxIDX:
      // had at first chosen rnd bg color; wanted to see how it looks with rotate through them per point:
      // int bgColorInitIDX = (int) random(0, backgroundDotRNDcolorsArrayMaxIDX);
    bgPointColors.add(new wrappingColorIDX(bgColorInitIDX, backgroundDotRNDcolorsArrayMaxIDX));
    // increment the color idx and reset to zero if above max index:
    bgColorInitIDX += 1; if (bgColorInitIDX >= backgroundDotRNDcolorsArrayMaxIDX) {bgColorInitIDX = 0;}
  }
  
  noStroke();
}

void draw(){
  clear();
  //background(#656767);
  background(#362e2c);
  translate(width/2,height/2);

  // randomly wiggling vogel dots behind the main, non-wiggling dots:
  int layoutPointCounter = 0;
  for (PVector p : layout) {
    int RNDx = int(random(-2, 2));
    int RNDy = int(random(-2, 2));
      // random bg dot color changing experiment I'm not sure I liked:
      // int RNDbgColorDotIDX = (int) random(backgroundDotRNDcolorsArrayMaxIDX);
      // fill(backgroundDotRNDcolors[RNDbgColorDotIDX]);
    int bgPointColorIDX = bgPointColors.get(layoutPointCounter).colorIDX;
    color bgPointColor = backgroundDotRNDcolors[bgPointColorIDX];
    fill(bgPointColor);
    ellipse(p.x + RNDx, p.y + RNDy, backgroundDotSize, backgroundDotSize);
    // increment associated bgPointColors color IDX:
    bgPointColors.get(layoutPointCounter).rotateColorIDX();
    layoutPointCounter += 1;
  }

  // fixed color, slightly smaller, fixed position dots in front of those:
  fill(#5c38ff);  // medium blue-violet
  for (PVector p : layout) {
   ellipse(p.x, p.y, foregroundDotSize, foregroundDotSize);
  }
  // saveFrame("/##########.png");
  delay(48);
}
