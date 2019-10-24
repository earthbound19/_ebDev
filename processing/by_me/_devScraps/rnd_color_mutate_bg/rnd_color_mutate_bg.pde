// Randomly mutating color change of background.
// This may be boring by itself; this is a color mutation proof of concept.

int r = 126;
int g = 126;
int b = 126;
int colorMutationAmount = 3;

int mutate(int RGBnum) {
  int rndChange = (int) random(2);  //casting -- also random(2) returns 0 or 1.
  switch (rndChange)
  {
    case 0:
      RGBnum -= colorMutationAmount;
      break;  // WITHOUT THIS it falls through to the next case, blergh.
    case 1:
      RGBnum += colorMutationAmount;
      break;
  }
  RGBnum = constrain(RGBnum, 0, 255);
  return RGBnum;
}

// Main Processing setup funtion
void setup() {
  size(displayWidth, displayHeight);
  //size(1280,720);  // uncomment this override if you use saveFrame() below for animation:
  background(126);
}

// main Processing draw function (it loops infinitely)
void draw() {
  //print(".RGB: " + r + "," + g + "," + b + "\n");
  r = mutate(r); g = mutate(g); b = mutate(b);
  //print("..RGB: " + r + "," + g + "," + b + "\n");
  background(r,g,b);
  delay(33);  // 1000ms/s / 30 = 33.33 = ~30 fps
  //saveFrame();
}
