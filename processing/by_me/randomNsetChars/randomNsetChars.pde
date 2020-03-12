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
String versionNumber = "1.0.0";
// Changes this version:
// - use unifont-12.1.04.ttf font instead of Fira Mono. Has non-crazy vertical metrics for block chars.
// - Hack-Regular.ttf is good alternate.
// Tossup: I like the finer "gray" or "hatch" block chars of unifont; I like the more square glyphs of Hack. ?
// - add optional other char supersets as comments.
// - reintroduce color morph per render (variant) as it looks good with full-screen changing noise.
// - tweak defaults

int delayBetweenRenders = 84;    // has been: 141;

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

  // SUPER SET DEFINITION from which subsets may be randomly drawn; combining any of these can produce interesting results:
  // COULD USE: BOX DRAWING unicode block set, re: https://en.wikipedia.org/wiki/Box_Drawing_(Unicode_block)
  //stringOfCharsToInitFrom = "─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋╌╍╎╏═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╰╱╲╳╴╵╶╷╸╹╺╻╼╽╾╿";
  // OR: Block Elements; re: https://en.wikipedia.org/wiki/Block_Elements
   stringOfCharsToInitFrom = "▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟";
  // OR: GEOMETRIC SHAPES unicode block:
  // stringOfCharsToInitFrom = "■□▢▣▤▥▦▧▨▩▪▫▬▭▮▯▰▱▲△▴▵▶▷▸▹►▻▼▽▾▿◀◁◂◃◄◅◆◇◈◉◊○◌◍◎●◐◑◒◓◔◕◖◗◘◙◚◛◜◝◞◟◠◡◢◣◤◥◦◧◨◩◪◫◬◭◮◯◰◱◲◳◴◵◶◷◸◹◺◻◼◽◾◿";
  // OR: MATH OPERATORS block:
  // stringOfCharsToInitFrom = "∀∁∂∃∄∅∆∇∈∉∊∋∌∍∎∏∐∑−∓∔∕∖∗∘∙√∛∜∝∞∟∠∡∢∣∤∥∦∧∨∩∪∫∬∭∮∯∰∱∲∳∴∵∶∷∸∹∺∻∼∽∾∿≀≁≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩≪≫≬≭≮≯≰≱≲≳≴≵≶≷≸≹≺≻≼≽≾≿⊀⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊰⊱⊲⊳⊴⊵⊶⊷⊸⊹⊺⊻⊼⊽⊾⊿⋀⋁⋂⋃⋄⋅⋆⋇⋈⋉⋊⋋⋌⋍⋎⋏⋐⋑⋒⋓⋔⋕⋖⋗⋘⋙⋚⋛⋜⋝⋞⋟⋠⋡⋢⋣⋤⋥⋦⋧⋨⋩⋪⋫⋬⋭⋮⋯⋰⋱⋲⋳⋴⋵⋶⋷⋸⋹⋺⋻⋼⋽⋾⋿";
  // There's also a Commodore 64 character set, PETSCII, an Atari one, etc..
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

  fontPointSize = 44;    // tried sizes list: 83.4 51.5 43 39.1 32 24 12

  backGroundColor = #383838;
  fillColor = #00FFFF;  // NOTE: the following may override that with RND color:
  if (rndColorChangeMode == true) {
    fillColor = fillColors[int(random(0, fillColorsLength))];
  }
  
  background(backGroundColor);
  fill(fillColor);

  displayRNDsubsets = true;
  numRendersToDisplaySubset = 21;
  reloadAfterNrenders = numRendersToDisplaySubset * 7;
  renderCount = 0;
  subsetDisplayedrendersCounter = 0;
  
  // Uncomment the following two renders to see the available fonts 
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("unifont-12.1.04.ttf", fontPointSize);
  textFont(myFont);
  textAlign(CENTER, TOP);

  textSize(fontPointSize);    // Also sets vertical leading; re
  // https://processing.org/reference/textLeading_.html -- so reset that with textLeading():
  characterWidth = textWidth('▆');
  columns = int(width / characterWidth);
  rowHeight = fontPointSize * 0.987;
  // I'm mystified why (textAscent() + textDescent() gave wrong val here with Fira Mono:
  textLeading(rowHeight);
  
  rows = int(height / rowHeight);
}

void renderRNDcharsScreen () {
  subsetDisplayedrendersCounter += 1;
  if (subsetDisplayedrendersCounter == numRendersToDisplaySubset) {
    subsetDisplayedrendersCounter = 0;
    setSubCharSet();
  }
  
  background(backGroundColor);
  setRNDfillColor();
  
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
