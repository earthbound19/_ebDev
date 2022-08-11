// DESCRIPTION
// Prints variants of constructed random character sets (hard-coded but hackable: block characters), one complete constructed screen of them after another, with character color morph (randomization).

// USAGE
// - Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.
// - Click or press any key to run a new variant.
// KNOWN ISSUES
// If you hack this to display thousands of frames per variation, it slows down.

// DEPENDENCIES
// Babel Stone True Type Font from: https://www.babelstone.co.uk/Fonts/Shapes.html
// or my copy of it from:   http://earthbound.io/data/dist/BabelStoneShapes.ttf
// also to toy with:        http://earthbound.io/data/dist/bitBlocks.ttf

// CODE
// Changes this version:
// Rework documentation comments per preferences.
// GLOBAL VARIABLE DECLARATIONS
String versionNumber = "1.13.2";


// TO DO
// - reduce the huge font file to only the glyphs I want (dramatically reduce its size).
// - something with this? https://stackoverflow.com/questions/51702011/can-we-create-partially-colored-text-in-processing
// - unique rnd colors of rows? Might entail:
//  - converting text to PShape; possibly re: https://discourse.processing.org/t/convert-text-to-pshape/15552/2
// - tweet image with current char set text?
// - save SVG?
// - svg numbering and save anim mode, for anims?
// - optionally use the bit blocks font


int delayBetweenRenders;
// to figure ffmpegAnim.sh "source" framerate, calculate: 1000 / delayBetweenRenders

boolean booleanOverrideSeed = false;
// rnd seed may be in range (-2147483648, 2147483647) :
// RND seeds and their emergent properties:
// 71028736 starts blue-cyan and gets really interesting fast.
// 1980151040 starts blue-cyan interesting pattern start. Leads to 71028736 (above).
int seed = 71028736;

color[] bgColors = new color[]{};
int bgColorsLength;
int bgColorsArrayIndex;
color[] fillColors = new color[]{};
int fillColorsLength;
int fillColorsArrayIndex;

color bgColor;
color fillColor;
boolean rndColorChangeMode = true;

PFont myFont;
float fontPointSize;
float characterWidth;
float columnWidth;
float rowHeight;
int columns;
int rows;

boolean saveImageSeries = false;
boolean rapidBWhdAlphaGenMode = false;		// overrides some of the above globals

// FOR OTHER POSSIBLE characters to use in superset, see: http://s.earthbound.io/RNDblockChars
// SUPER SET DEFINITION from which subsets may be randomly drawn; combining any of these can produce interesting results:
// -- here are some possible subsets of them to use as supersets (from which sub-subsets would
// be made) :
 //String masterCharset = "┈┉┊┋┌└├┤┬┴┼╌╍╎╭╮╯╰╱╲╳╴╵╶╷";     // box drawing subset
 //String masterCharset = "▲△◆◇○◌◍◎●◜◝◞◟◠◡◢◣◤◥◸◹◺◿◻◼";     // geometric shapes subset
 //String masterCharset = "∧∨∩∪∴∵∶∷∸∹∺⊂⊃⊏⊐⊓⊔⊢⊣⋮⋯⋰⋱";      // math operators subset
 //String masterCharset = "◈⟐⟢ːˑ∺≋≎≑≣⊪⊹☱☰☲☳☴☵☶☷፨჻܀";   //Apple emoji subset
 //String masterCharset = "─│┌┐└┘├┤┬┴┼╭╮╯╰╱╲╳▂▃▄▌▍▎▏▒▕▖▗▘▚▝○●◤◥♦";	// Commodore 64 font/drawing glyphs set--which, it happens, combines characters from some of the others interestingly.
 //String masterCharset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWZ!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ 0";  // all usable from bitBlocks.ttf
String masterCharset = "▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟";			// block characters subset
int masterCharsetLength = masterCharset.length();

String subCharSetRND;
int subCharSetRNDlength;

String charsDisplayString;

boolean displayRNDsubsets;
int reloadAfterNrenders;
int renderCount;
int variantCount = 0;

String animFramesSaveDir;
String animFramesSaveSUBdir;

PrintWriter output;
// END GLOBAL VARIABLES DECLARATIONS


// BEGIN CUSTOM FUNCTIONS
// given a string, returns a subset of unique random characters from the string,
// of random length from 1 to the length of the string.
String getRNDcharsSubset(String srcString) {
  String rndSubSet = "";
  int rndSubSetBuildToLength = int(random(0, masterCharsetLength + 1));
  for (int i = 0; i <= rndSubSetBuildToLength; i++) {
   boolean isAlreadyInSubset = false;
   while (isAlreadyInSubset == false) {
     int rndSubsetIDX = int(random(0, masterCharsetLength));
     char pickedChar = srcString.charAt(rndSubsetIDX);
     for (int j = 0; j < rndSubSet.length(); j++) {
       if (pickedChar == rndSubSet.charAt(j)) {
         isAlreadyInSubset = true;
       }
     }
     if (isAlreadyInSubset == false) {
       rndSubSet += pickedChar;
       isAlreadyInSubset = true;
     }
   }
  }
  return rndSubSet;
}

void setRNDbgColor() {
	bgColorsArrayIndex = int(random(0, bgColorsLength));
	bgColor = bgColors[bgColorsArrayIndex];
	background(bgColor);
}

// FUNCTION ALTERS A GLOBAL! :
// randomly changes index to select bg color from self, before, or after,
// looping around if past either edge of array index, but only if an rnd color mode bool is true:
void mutateBGcolor() {
  if (rndColorChangeMode == true) {
      int rndChoiceTwo = int(random(-2, 2));
      bgColorsArrayIndex += rndChoiceTwo;
      // if less than zero, set to array max.:
      if (bgColorsArrayIndex <= 0) {
        bgColorsArrayIndex = bgColorsLength;
      }
      // if more than array max., set to zero:
      if (bgColorsArrayIndex >= bgColorsLength) {
        bgColorsArrayIndex = 0;
      }
      bgColor = bgColors[bgColorsArrayIndex];
	background(bgColor);
  }
}

void setRNDfillColor() {
	fillColorsArrayIndex = int(random(0, fillColorsLength));
	fillColor = fillColors[fillColorsArrayIndex];
	fill(fillColor);
}

// FUNCTION ALTERS A GLOBAL! :
// randomly changes index to select foreground color from self, before, or after,
// looping around if past either edge of array index, but only if an rnd color mode bool is true:
void mutateFillColor() {
  if (rndColorChangeMode == true) {
      int rndChoiceOne = int(random(-2, 2));
      fillColorsArrayIndex += rndChoiceOne;
      // if less than zero, set to array max.:
      if (fillColorsArrayIndex <= 0) {
        fillColorsArrayIndex = fillColorsLength;
      }
      // if more than array max., set to zero:
      if (fillColorsArrayIndex >= fillColorsLength) {
        fillColorsArrayIndex = 0;
      }
      fillColor = fillColors[fillColorsArrayIndex];
	fill(fillColor);
  }
}


  // ALTERS A GLOBAL:
  // get a random string and use it as an animation save frames subdir name component:
void setRNDanimFramesSaveDirName() {
  String rndString = "";
  String rnd_string_components = "abcdeghjkmnpqruvwyzABCDEGHJKMNPQRUVWYZ23456789";
  for (int i = 0; i < 12; i++)
  {
    int rnd_choice = (int) random(0, rnd_string_components.length());
    rndString+= rnd_string_components.charAt(rnd_choice);
  }
  animFramesSaveDir = "_anim_run__" + rndString + "/";
}

// END CUSTOM FUNCTIONS


void settings() {
  // If boolean rapidBWhdAlphaGenMode set true, set defaults for black and white colors,
  // and rapid creation of large pngs.
  // Otherwise use standard default colors and settings.
	if (rapidBWhdAlphaGenMode == true) {
		size(2400, 2400);
		// color arrays overrides -- yes, other functions will do rnd calls in range 0,0,
		// but I think this is better than creating a fork of the script for HD BW alpha generation.
		bgColors = new color[]{ #FFFFFF	};
		bgColorsLength = bgColors.length;
		bgColorsArrayIndex = 0;
    fillColors = new color[]{ #000000 };
		fillColorsLength = fillColors.length;
		fillColorsArrayIndex = 0;

    delayBetweenRenders = 0;

    reloadAfterNrenders = 1;

    fontPointSize = width/32;

    rndColorChangeMode = true;  // no BW images will be made, only black (because of rnd func nature/call)
    // unless that is true; so override to true here in case it is set by user in global vars as false
	} else {
		// fullScreen();
		// OR:
	  size(1920, 1080);
    // from soil_pigments_darker_and_dark_backgrounds_tweak_gradient.hexplt:
		bgColors = new color[]{
			#a4a19f, #a8a198, #ada090, #b1a088, #b59f80, #b19876, #ad916b, #a88b61,
			#a48456, #a07d53, #9b764f, #976f4c, #926849, #8e694c, #8b6a4f, #876a52,
			#836b55, #7f6c57, #7c6d5a, #786e5c, #746f5e, #736f62, #716f67, #706f6b,
			#6f6f6f, #696969, #626262, #5c5c5c, #565656, #5b5550, #60544a, #655344,
			#6a523d, #654c39, #5f4635, #5a4032, #553a2e, #58382c, #5c372a, #5f3528,
			#623326, #592e25, #512a24, #482523, #402122, #3f2220, #3e221e, #3c231c,
			#3b231a, #39241c, #37251e, #342520, #322622, #292123, #201d23, #171823,
			#0e1323, #0f1323, #101224, #111124, #313141, #54545f, #7b797e
		};
		bgColorsLength = bgColors.length;
		bgColorsArrayIndex = 0;
    // from soil_pigments_accents_and_32_max_chroma_tweak_gradient.hexplt:
		fillColors = new color[]{
			#25ffff, #37f7fd, #44f0fb, #4de8f9, #55e1f7, #5adef3, #5fdbee, #63d8ea,
      #67d5e6, #59d4ec, #48d2f3, #32d1f9, #00cfff, #00ccfd, #00c9fc, #00c7fa,
      #00c4f8, #56d1d7, #80dcb2, #a4e584, #c5ed3a, #aedd73, #97cd94, #81bcad,
      #6caac2, #72adc0, #79afbd, #7fb2bb, #85b4b8, #89adae, #8da5a3, #909e99,
      #92968f, #909590, #8e9592, #8b9493, #899394, #898e92, #8a8a90, #8a858e,
      #8a808c, #938290, #9b8493, #a48597, #ac879b, #b2899d, #b78a9f, #bd8ca1,
      #c38da3, #c68ea6, #c98faa, #cc90ad, #cf91b1, #ca90b3, #c48fb5, #bf8db7,
      #ba8cb9, #bd8dbe, #bf8ec4, #c28fc9, #c590cf, #cd92cf, #d694ce, #de96ce,
      #e798cd, #ea94bc, #ed90ab, #f08c9a, #f38788, #f68789, #f98789, #fc878a,
      #ff878b, #f98b8a, #f38f89, #ec9387, #e69686, #ea9d89, #eea58c, #f1ac8f,
      #f5b492, #f7b593, #fab794, #fcb894, #ffba95, #f2ac8f, #e69f89, #d99183,
      #cd847d, #da846c, #e68358, #f2823e, #ff8005, #ff6d26, #ff5735, #ff3c3f,
      #ff0047, #fd014e, #fb0155, #fa015b, #f80061, #fa046f, #fb077c, #fd0789,
      #ff0596, #ff08a3, #ff08af, #ff05bc, #ff00c8, #fd06d5, #fb08e2, #fa06ef,
      #f800fc, #e81cfd, #d727fe, #c72efe, #b732ff, #a241f9, #8c4bf3, #7552ed,
      #5b57e7, #5e5edf, #6165d7, #656bce, #6970c6, #737ace, #7e84d6, #888edd,
      #9398e5, #8796e5, #7b94e6, #6e91e6, #608fe6, #5babed, #53c7f4, #44e3fa
		};
		fillColorsLength = fillColors.length;
		fillColorsArrayIndex = 0;

    delayBetweenRenders = 640; // has been: 84, 112, 141, 640

	  reloadAfterNrenders = 60;

    fontPointSize = width/48;    // tried sizes list: 83.4 51.5 43 39.1 32 24 12; unifont was last width/28.46. NOTE: a PointSize that doesn't evenly divide by the canvas width may lead to gaps in the text that cause a look like gaps in wallpaper.
	}

	setRNDanimFramesSaveDirName();
}

void setupNewVariant() {
	variantCount += 1;
  // this check ensures manual seed is only done once, expecting no other code to ever set
  // booleanOverrideSeed to true again:
  if (booleanOverrideSeed == true) {
    randomSeed(seed);
    booleanOverrideSeed = false;
  } else {
    seed = (int) random(-2147483648, 2147483647);
    randomSeed(seed);
  }

  subCharSetRND = getRNDcharsSubset(masterCharset);

  setRNDbgColor();
  setRNDfillColor();

  displayRNDsubsets = true;
  renderCount = 0;

  String variantCountPaddedString = nf(variantCount, 5);
  if (saveImageSeries == true) {
    animFramesSaveSUBdir = animFramesSaveDir + "/" + variantCountPaddedString + "/";
    String variantString = str(seed);
    output = createWriter(animFramesSaveSUBdir + variantString + ".txt");
    output.println("The random seed for the variant that produced the images in this folder is " + variantString + ".\n");
    output.flush();
    output.close();
  }
}

void setup() {
  setupNewVariant();

  // Uncomment the following two lines to see the available fonts
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("../BabelStoneShapes.ttf", fontPointSize);
  // OR (and with necessary changes in masterCharset to use what the font offers), try:
  // myFont = createFont("../bitBlocks.ttf", fontPointSize);
  textFont(myFont);
  textAlign(CENTER, TOP);

  textSize(fontPointSize);    // Also sets vertical leading; re
  // https://processing.org/reference/textLeading_.html -- so reset that with textLeading():
  characterWidth = textWidth('█');
  columns = int(width / characterWidth);
  // discovered settings for fontPointSize: BabelStoneShapes.ttf = * 0.965; unifont-12.1.04.ttf = * 1.987; bitBlocks.ttf = 0.7;
  rowHeight = fontPointSize * 0.965;
  // I'm mystified why (textAscent() + textDescent() gave wrong val here with Fira Mono:
  textLeading(rowHeight);

  rows = int(height / rowHeight);
}


// EXCEPT MOAR CUSTOM FUNCTION
void renderRNDcharsScreen () {
	clear();

  mutateBGcolor();
  mutateFillColor();

  // length of subCharSetRND can be changed, so this needs to be done every call of this func.:
  charsDisplayString = "";
  int subCharSetRNDlength = subCharSetRND.length();
  charsDisplayString = "";
  for (int row = 0; row < rows + 1; row++) {
    for (int column = 0; column < columns; column++) {
      int rndInt = int(random(0, subCharSetRNDlength));
      charsDisplayString += subCharSetRND.charAt(rndInt);
    }
    charsDisplayString += "\n";
  }
  text(charsDisplayString, width/2, 0);
  // only delay if we are not saving PNG images:
  if (saveImageSeries == false) {
	delay(delayBetweenRenders);
  }

  // SAVE PNG AS PART OF ANIMATION FRAMES conditioned on boolean;
  if (rapidBWhdAlphaGenMode == false && saveImageSeries == true) {
    saveFrame(animFramesSaveSUBdir + "/##########.png");
  }
  // OR HD BW png named after variation (if in that mode AND
  // the defaults hard-coded for that mode say save pngs:):
  if (rapidBWhdAlphaGenMode == true && saveImageSeries == true) {
    saveFrame("randomNsetChars_Alphas/randomNsetChars_AlphaGenMode__seed_" + seed + ".png");
  }

  // to mitigate mysterious slowdown via periodic reload of script:
  renderCount += 1;
  if (renderCount > reloadAfterNrenders) {
    // print("Calling setup again at renderCount == " + renderCount + "!\n");
    setupNewVariant();
  }
}

void draw () {
  // to change display on every draw loop:
  renderRNDcharsScreen();
}

// call setupNewVariant() for new variation on mouse press AND/OR key press:
void mousePressed() {
  setupNewVariant();
}
void keyPressed() {
  setupNewVariant();
}
