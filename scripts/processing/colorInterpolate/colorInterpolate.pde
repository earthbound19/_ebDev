// DESCRIPTION
// Prints interpolation values, and displays color swatches for, colors interpolated at start color 'from' to end color 'to', in N steps, using Processing's built-in lerpColor function. Hack the GLOBAL VARIABLES (see that comment) to change what is interpolated. Image size depends on how many colors you hard-code. For hacking/finding color gradients.

// USAGE
// Open this file in the Processing IDE (or anything else that can run a Processing file), edit the assignments to the "from" and "to" variables to colors of your choosing, and run it with the triangle "Play" button.
// NOTES:
// - Color interpolation that "makes sense" is a question of your design intent and the purpose of a given color space you work in. lerpColor() interpolates in sRGB space, which has little design consideration for human perception of color. It turns "opposites" to gray at midpoints (for example blue and yellow). The default values here are coded with blue for "fromColor" and yellow for "toColor" to show this.


// CODE
// GLOBAL VARIABLES
color fromColor = color(0, 0 ,255);
color toColor = color(255, 255, 0);
int numberOfInterpolations = 7;    // number of values to interpolate through, including start and end color
color backgroundColor = #919191;    // #919191 is a possible "halfway" between black and white.

// DON'T CHANGE THESE GLOBALS:
int tileEdgePX;
int tilesAreaPadding;
color[] lasInterpolaciones;

int B_MASK = 255;
int G_MASK = 255<<8;
int R_MASK = 255<<16;
// converts Processing's int notation for colors to human-understandable (and proper sRGB) values, and returns a formatted string of them:
String getRGBvalsFromColorINTnotation(int i) {
  int r = (i & R_MASK)>>16;
  int g = (i & G_MASK)>>8;
  int b = i & B_MASK;
  String sRGBvals = r + "," + g +"," + b;
  String hexVals = hex(i); hexVals = hexVals.substring(2);    // trim leading alpha values off
  return sRGBvals + " (#" + hexVals + ")";
}

// returns an array of ints, which are interpolated colors (Processing colors are interpeted ints!) from start to end color at N intervals over range min-max (interpolations), inclusive of max. Adapted from: https://gist.github.com/earthbound19/e7fe15fdf8ca3ef814750a61bc75b5ce
int[] getLerpColorArray(color fromColor, color toColor, int n)
{
  float dividend = 1 / float(n - 1);
  color[] colorArray = new color[n];    // no idea how Processing handles colors as ints, but if I try returing a color[] from this function, it throws an error, whereas it doesn't and it works if I build it as an int[]. ?
  float interpolationValue = 0;
  // build the colorArray:
  for (int i = 0; i < n; i++) {
    int interpolatedColor = lerpColor(fromColor, toColor, interpolationValue);
    // print("interpolationValue: " + interpolationValue + "\n");
    // print(interpolatedColor + "\n");
    colorArray[i] = color(interpolatedColor);
    interpolationValue += dividend;
  }
  return colorArray;
}

void settings() {
  tilesAreaPadding = int(displayWidth * 0.06);
  // print("that is" + tilesAreaPadding);
  tileEdgePX = (displayWidth - (tilesAreaPadding*2)) / numberOfInterpolations;
  size(displayWidth, tileEdgePX + tilesAreaPadding * 2);
}

void setup() {
  noStroke();
  rectMode(CENTER);
  background(#919191);
  lasInterpolaciones = getLerpColorArray(fromColor, toColor, numberOfInterpolations);
  // print the resulting array values this one time that this setup() function runs; render tiles of them also:
  for (int i = 0; i < numberOfInterpolations; i++) {
  String sRGBvals = getRGBvalsFromColorINTnotation(lasInterpolaciones[i]);
    print(sRGBvals + '\n');
    fill(lasInterpolaciones[i]);
    rect( tilesAreaPadding+(tileEdgePX/2)+(i * tileEdgePX), height / 2, tileEdgePX, tileEdgePX);
  }
}

// We can actually just never use this function, so commented out:
// void draw() {
// }
