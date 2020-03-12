// DESCRIPTION
// Prints variants of constructed random character sets (hard-coded but hackable: block
// # characters), scrolling down the screen, with character color morph (randomization).

// TO DO:
// - something with this? https://stackoverflow.com/questions/51702011/can-we-create-partially-colored-text-in-processing
// - unique rnd colors of rows? Might entail:
//  - converting text to PShape; possibly re: https://discourse.processing.org/t/convert-text-to-pshape/15552/2
// - tweet image with current char set text?
// - save SVG?
// - svg numbering and save anim mode, for anims?


// CODE

// GLOBALS DECLARATIONS
String versionNumber = "0.6.0";
// Changes this version:
// - render noise over entire view, delay, then render new of same type of noise for period,
// and periodically call setup() which may rnd change color. This is _much_ more interesting.

int delayBetweenRenders = 141;

// palette tweaked (and expanded with more cyans and greens, and lighter those) from:
// https://github.com/earthbound19/_ebArt/blob/master/palettes/fundamental_vivid_hues_v2.hexplt
color[] fillColors = {
	#FF00FF, #FF00C0, #FF007F, #DB12A3, #C91BB5, #B624C8, #A42DDA, #7F40FF,
	#6060FF, #6A6AFF, #7F7FFF, #608BF3, #4894EA, #00AFCF, #00C1EA, #00CFFF, #00C4FF,
	#00E4FF, #2DEEFF, #3EF1FF, #7FFFFF, #6DFFFF, #5BFFFF, #25FFFF, #00FFFF,
  #32F2DA, #43EECD, #54EAC1, #76E1A8, #40F37E, #52FE79, #00E77D, #1DCF00,
	#65D700, #85FF00, #00FF00, #B5FF00, #B2F300, #AFE300, #D1EF00, #FFD500,
	#FFB700, #FD730A, #FF5100, #FF0000, #FF0047, #FF006B, #FF009C
};
int fillColorsLength = fillColors.length;
int fillColorsArrayIndex = 0;
boolean rndColorChangeMode = true;

PFont myFont;
String stringOfCharsToInitFrom;

StringList masterCharSet;
int masterCharSetLength;
StringList subCharSet;
int subCharSetLength;
StringList charsetToUse;

float fontPointSize;

float characterWidth;
color backGroundColor;
color fillColor;
float columnWidth;
float rowHeight;
int columns;
int rows;

String charsDisplayString;

boolean displayRNDsubsets;
int numRendersToDisplaySubset;
int reloadAfterNrenders;
int renderCount;
int subsetDisplayedrendersCounter;
// END GLOBALS DECLARATIONS


// FUNCTION ALTERS A GLOBAL! :
// randomly changes index to select foreground color from self, before, or after,
// looping around if past either edge of array index, but only if an rnd color mode bool is true:
void setRNDfillColor() {
  if (rndColorChangeMode == true) {
    // roll a three-sided die; if one is rolled, do rnd color change:
    int rndChoiceOne = int(random(1, 4));
    if (rndChoiceOne == 1) {
      int rndChoiceTwo = int(random(-2, 2));
      fillColorsArrayIndex += rndChoiceTwo;
      // if less than zero, set to array max.:
      if (fillColorsArrayIndex < 0) {
        fillColorsArrayIndex = fillColorsLength;
      }
      // if more than array max., set to zero:
      if (fillColorsArrayIndex >= fillColorsLength) {
        fillColorsArrayIndex = 0;
      }
      // print("fillColorsArrayIndex val: " + fillColorsArrayIndex + "\n");
      
      fillColor = fillColors[fillColorsArrayIndex];
      fill(fillColor);
    }
  }
}

// Alters a global! : Sets charsetToUse to rnd chars and length from masterCharSet:
void setSubCharSet() {
  masterCharSet.shuffle();
  // empty this array so we can rebuild it:
  subCharSet.clear();
  // choose rnd num between 1 and master char set length:
  int rndLen = int(random(1, (masterCharSetLength + 1) * 0.4));    // orig. python script max range mult.: 0.31
  // print("Random length chosen for subset is: " + rndLen + "\n");
  for (int j = 0; j < rndLen; j++) {
    subCharSet.append(masterCharSet.get(j));
  }
  subCharSetLength = subCharSet.size();
  
  charsetToUse = subCharSet;
  // for testing:
  // int subCharSetLength = subCharSet.size();
  // String tmp_one = "";
  // for (int floref = 0; floref < subCharSetLength; floref++) {
  //   tmp_one += subCharSet.get(floref);
  // }
  // text(tmp_one + "\n", width/2, height/2);
}

void setup() {
  fullScreen();
  // size(1280, 720);
  // size(413, 258);

  fillColorsArrayIndex = int(random(0, fillColorsLength));
  setRNDfillColor();

  // it seems those block glyphs are literally double tall?! :
  
  stringOfCharsToInitFrom = "▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■";
  charsDisplayString = "";
  masterCharSet = new StringList();   // because has .shuffle();
  subCharSet = new StringList();
  charsetToUse = new StringList();
  int lengthOfChars = stringOfCharsToInitFrom.length();
  for (int i = 0; i < lengthOfChars; i++) {
    masterCharSet.append(str(stringOfCharsToInitFrom.charAt(i)));
  }
  masterCharSetLength = masterCharSet.size();
  // inits subCharSet
  setSubCharSet();
  if (displayRNDsubsets == true) {
    charsetToUse = subCharSet;
    } else {
      charsetToUse = masterCharSet;
    }

  // fontPointSize = 83.4;
  // fontPointSize = 51.5;
  // fontPointSize = 43;
  fontPointSize = 39.1;
  // fontPointSize = 32;
  // fontPointSize = 24;
  // fontPointSize = 12;

  backGroundColor = #383838;
  fillColor = #00FFFF;
  // NOTE: the following overrides that with an RND color if rndColorChangeMode is true:
  if (rndColorChangeMode == true) {
    fillColor = fillColors[int(random(0, fillColorsLength))];
  }
  
  background(backGroundColor);
  fill(fillColor);

  displayRNDsubsets = true;
  numRendersToDisplaySubset = 18;
  reloadAfterNrenders = numRendersToDisplaySubset * 30;
  renderCount = 0;
  subsetDisplayedrendersCounter = 0;
  
  // Uncomment the following two renders to see the available fonts 
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("FiraMono-Bold.otf", fontPointSize);    // on Mac, leads to rendered monospace width of ~49.79
  textFont(myFont);
  textAlign(CENTER, TOP);

  textSize(fontPointSize);    // Also sets vertical leading; re
  // https://processing.org/reference/textLeading_.html -- so reset that with textLeading():
  characterWidth = textWidth('█');
      // Trying and failing to figure out vertical metrics via variables instead of manual value here:
      // float doubleTallCharacterHeight = (textAscent() * 2)  +  (textDescent() * 2);   
      // print("height of double tall characters may be: " + doubleTallCharacterHeight + "\n");
      // columnWidth = (width / characterWidth);
  columns = int(width / characterWidth);
  // print(characterWidth + "\n");
  float leadingMultiplier = 1.485;    // hard-coded multiplier figured for Fira Mono Bold double-tall glyphs
  rowHeight = fontPointSize * leadingMultiplier;
  // I'm mystified why (textAscent() + textDescent() would give a wrong leading value here:
  textLeading(rowHeight);
  
  rows = int(height / rowHeight);
      // print("columns: " + columns + " rows: " + rows + "\n");
}

void renderRNDcharsScreen () {
  subsetDisplayedrendersCounter += 1;
  if (subsetDisplayedrendersCounter == numRendersToDisplaySubset) {
    subsetDisplayedrendersCounter = 0;
    setSubCharSet();
  }
  
  background(backGroundColor);
  
  int charsetToUseLength = charsetToUse.size();
  charsDisplayString = "";
  for (int row = 0; row < rows + 1; row++) {
    for (int column = 0; column < columns; column++) {
      charsDisplayString += charsetToUse.get(int(random(0, charsetToUseLength)));
    }
    charsDisplayString += "\n";
  }
  text(charsDisplayString, width/2, 0);
  delay(delayBetweenRenders);
  
  // to mitigate mysterious slowdown via periodic reload of script:
  renderCount += 1;
  if (renderCount == reloadAfterNrenders) {
    print("Calling setup again at renderCount == " + renderCount + "!\n");
    setup();
  }

}

void draw () {
  // to change display on every draw loop:
  renderRNDcharsScreen();
}

// to change display on every mouse press:
//void mousePressed() {
  // renderRNDcharsScreen();
//}
