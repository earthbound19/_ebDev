//TO DO:
//- describe this project
//- fix bug: slows down over time. Memory leak? NOW TESTING fix after using .clear instead of reassigning new empty array to it.

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
int columns;
int rows;

String charsDisplayString;

boolean displayRNDsubsets;
int numRowsToDisplaySubset;
int reloadAfterNlines;
int totalRenderedLines;
int subsetDisplayedLinesCounter;

// Alters a global! : Sets charsetToUse to rnd chars and length from masterCharSet:
void setSubCharSet() {
  masterCharSet.shuffle();
  // empty this array so we can rebuild it:
  subCharSet.clear();
  // choose rnd num between 1 and master char set length:
  int rndLen = int(random(1, (masterCharSetLength + 1) * 0.4));    // orig. python script max range mult.: 0.31
  print(rndLen + "\n");
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
  // size(480, 650);

  stringOfCharsToInitFrom = "▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■-_|";
  charsDisplayString = "";
  
  masterCharSet = new StringList();   // because has .shuffle();
  subCharSet = new StringList();
  charsetToUse = new StringList();

  // fontPointSize = 83.4;
  fontPointSize = 43;
  // fontPointSize = 24;
  // fontPointSize = 12;

  backGroundColor = #383838;
  // backGroundColor = #00FFFF;
  // fillColor = #FD00FD;
  // fillColor = #0000FF;
  fillColor = #00FFFF;

  displayRNDsubsets = true;
  numRowsToDisplaySubset = 12;
  reloadAfterNlines = numRowsToDisplaySubset * 42;
  totalRenderedLines = 0;
  subsetDisplayedLinesCounter = 0;

  int lengthOfThat = stringOfCharsToInitFrom.length();
  for (int i = 0; i < lengthOfThat; i++) {
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
  // Uncomment the following two lines to see the available fonts 
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("FiraMono-Bold.otf", fontPointSize);    // on Mac, leads to rendered monospace width of ~49.79
  textFont(myFont);
  textAlign(CENTER, CENTER);
  fill(fillColor);
  background(backGroundColor);
  characterWidth = textWidth('█');
  // characterHeight = textHeight('█')'
  columnWidth = (width / characterWidth);
  columns = int(width / characterWidth);
  textSize(fontPointSize);    // Also sets vertical leading; re
  // https://processing.org/reference/textLeading_.html -- so reset that with:
  textLeading(fontPointSize * 1.486);   // EXACT min/max contact at 83.4 point size, FiraMono-Bold.otf!
  // it seems those block glyphs are literally double tall?!
    rows = 1;
  print("columns: " + columns + " rows: " + rows + "\n");
  renderRNDcharsScreen();
}

void renderRNDcharsScreen () {
  subsetDisplayedLinesCounter += 1;
  if (subsetDisplayedLinesCounter == numRowsToDisplaySubset) {
    subsetDisplayedLinesCounter = 0;
    setSubCharSet();
  }
  
  background(backGroundColor);
  // print(characterWidth + "\n");
  
  int charsetToUseLength = charsetToUse.size();
  for (int row = 0; row < rows; row++) {
    for (int column = 0; column < columns; column++) {
      // for dev testing spacing:
      // charsDisplayString += "_";
      charsDisplayString += charsetToUse.get(int(random(0, charsetToUseLength)));
    }
    charsDisplayString += "\n";
  }
  //text("█_-█\n-=░_", width/2, height/2);
  text(charsDisplayString, width/2, height/2);
  delay(32);
  
  // to mitigate mysterious slowdown via periodic reload of script:
  totalRenderedLines += 1;
  if (totalRenderedLines == reloadAfterNlines) {
    print("Calling setup again at totalRenderedLines == " + totalRenderedLines + "!\n");
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
