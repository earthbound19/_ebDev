float lineStartX; float lineStartY;
PVector angler;
float rndYdistanceStepMin = 11;
float rndYdistanceStepMax = 135;
float rndAngleMin = -44;
float rndAngleMax = 40;

// creates and returns a PVector of random angle and distance (for use via
// the .add() function of another vector, to make points wander) ;
// will not return PVector in excess of twoAnglesMax:
PVector getRNDslopeAndDistVec() {
  float xDist = random(rndYdistanceStepMin, rndYdistanceStepMax);
//  boolean whetherUsePower = (Math.random() < 0.5);
//  if (whetherUsePower == true) {
//// THIS DRAMATICALLY ALTERS the variability of line length (by an order of magnitude):
//    xDist = pow(xDist, 2);
//  }
  float angle = 1.0;
  // canyonize: 1 in N chance of getting rnd number in exponential distribution
  int chooser = (int) random(0,10);
  if (chooser == 8) {
    angle *= random(-1.9, 1.96);
  }
  // rnd arbitrary Y drop / spikes ("cliffize"):
  int cliffize = 0;
  if (chooser == 7) {
    cliffize = (int) random(xDist * -1.31, xDist * 1.185);
  }
  PVector returnVector = new PVector(xDist, 0 + cliffize);
  angle = random(rndAngleMin * angle, rndAngleMax * angle);
  returnVector.rotate(radians(angle));
  return returnVector;
}

void init() {
  background(127);
  stroke(0);
  strokeWeight(5);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  lineStartX = 0;
  lineStartY = height * random(0.33, 0.66);
  // randomly init sign of anglerPosNegMult as opposite if rnd choose 1 from range 0,1:
  //int chooser = (int) random(0, 2); if (chooser == 1) { posNegMult *= -1; }
  angler = new PVector(lineStartX, lineStartY);
  PVector tmpVec = getRNDslopeAndDistVec();
  angler.add(tmpVec);
}

void setup() {
  fullScreen();
  //frameRate(30);
  init();
}

int strokeCounter = 0;
void draw() {
  strokeCounter += 1;
  if (lineStartX < width) {
  //stroke((int) random(0, 200));    // randomly change stroke gray color to differentiate strokes
  PVector tmpVec = getRNDslopeAndDistVec();
  angler.add(tmpVec);
  line(lineStartX, lineStartY, angler.x, angler.y);
     print("Drew line no. " + strokeCounter + "\n");
  lineStartX = angler.x; lineStartY = angler.y;
  }
}

void mousePressed() {
  init();
}
