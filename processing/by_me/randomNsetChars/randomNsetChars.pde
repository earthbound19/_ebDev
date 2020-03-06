PFont myFont;
String stringOfCharsToInitFrom = "▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■-_|";
// comment bcse those dble tall!
StringList masterCharSet = new StringList();   // because has .shuffle();
int masterCharSetLength;
StringList subCharSet = new StringList();
int subCharSetLength;
StringList charsetToUse = new StringList();

// float fontPointSize = 83.4;
float fontPointSize = 43;
// float fontPointSize = 24;

float characterWidth;
color backGroundColor = #383838;
// color backGroundColor = #00FFFF;
// color fillColor = #FD00FD;
// color fillColor = #0000FF;
color fillColor = #00FFFF;
float columnWidth;
int columns;
int rows;

String charsDisplayString = "";

boolean displayRNDsubsets = true;
int numRowsToDisplaySubset = 12;
int subsetDisplayedLinesCounter = 0;

// Alters a global! : Sets charsetToUse to rnd chars and length from masterCharSet:
void setSubCharSet() {
  masterCharSet.shuffle();
  // empty this array so we can rebuild it:
  subCharSet = new StringList();
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
  //size(600, 400);
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
  delay(26);
}

void draw () {
  // to change display on every draw loop:
  renderRNDcharsScreen();
}

// to change display on every mouse press:
void mousePressed() {
  // renderRNDcharsScreen();
}
