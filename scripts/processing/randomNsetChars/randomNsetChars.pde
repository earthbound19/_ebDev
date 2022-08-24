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
String versionNumber = "1.16.3";


// TO DO
// - require minimum two unique glyphs in character subset, to avoid problem of one glyph which is fill block char, which means just a uniform color field -- IF THAT IS THE PROBLEM. Debug variant 802289152 to figure out.
// - reduce the huge font file to only the glyphs I want (dramatically reduce its size).
// - merge glyphs I want to use from disparate fonts into one purpose-only hacked font? Using proper unicode areas in the case of C64 font?
// - move everything I need to change for new variations into one function if possible or needed.
// MAYBE VERSION 2: forsake the text render approach and divide the canvase into cells on a grid. Give each cell a random character, and:
//  - Randomly mutate characters by next nearest most similar (position in masterCharset array).
//   - Sometimes just randomly jump to somewhere else altogether in the array.
//    - Sometimes do that with all characters (already doing this every call of draw() at this writing; change it to sometimes after the above are done).
//  - Randomly mutate indidual character colors.
//  - Sometimes randomly mutate _all_ character colors at the same time.
// - something with this? https://stackoverflow.com/questions/51702011/can-we-create-partially-colored-text-in-processing
// - unique rnd colors of rows? Might entail:
//  - converting text to PShape; possibly re: https://discourse.processing.org/t/convert-text-to-pshape/15552/2
// - tweet image with current char set text?
// - save SVG?
// - svg numbering and save anim mode, for anims?
// - optionally use the bit blocks font


int delayBetweenRenders;    // time in milleseconds before redraw of each image; to figure ffmpegAnim.sh "source" framerate, calculate: 1000 / delayBetweenRenders

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

ArrayList<String> masterCharsSETS = new ArrayList<String>();

String masterCharset;
int masterCharsetLength;

String subCharSetRND;
int subCharSetRNDlength;

String charsDisplayString;

int reloadAfterNrenders;
int renderCount;
int variantCount = 0;

String animFramesSaveDir;
String animFramesSaveSUBdir;

PrintWriter output;

IntList screenDivisors = new IntList();
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

// settings() is called ONCE before all other functions, and exists to accomodate either the need to call size() before setup() and other functions AND/OR to do things outside of the Processing IDE.
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

    reloadAfterNrenders = 0;

    fontPointSize = width/32;

    rndColorChangeMode = true;  // no BW images will be made, only black (because of rnd func nature/call)
    // unless that is true; so override to true here in case it is set by user in global vars as false
	} else {
		// fullScreen();
		// OR:
	  size(1920, 1080);
    // these palettes use gradients and colors adapted from the following palettes, with additions:
    // soil_pigments_darker_and_dark_backgrounds_tweak_gradient.hexplt, soil_pigments_accents_and_32_max_chroma_tweak_gradient.hexplt
		bgColors = new color[]{
      #a4a19f, #a8a198, #ada090, #b1a088, #b59f80, #b19876, #ad916b, #a88b61,
      #a48456, #a07d53, #9b764f, #976f4c, #926849, #8e694c, #8b6a4f, #876a52,
      #836b55, #7f6c57, #7c6d5a, #786e5c, #746f5e, #736f62, #716f67, #686761,
      #5f5e5c, #565656, #5b5550, #60544a, #655344, #6a523d, #654c39, #5f4635,
      #5a4032, #553a2e, #58382c, #5c372a, #5f3528, #623326, #592e25, #512a24,
      #482523, #402122, #3f2220, #3e221e, #3c231c, #3b231a, #39241c, #37251e,
      #342520, #322622, #292123, #201d23, #171823, #0e1323, #0f1323, #101224,
      #111124, #313141, #54545f, #7b797e
		};
		bgColorsLength = bgColors.length;
		bgColorsArrayIndex = 0;
		fillColors = new color[]{
			#25ffff, #37f7fd, #44f0fb, #4de8f9, #55e1f7, #5adef3, #5fdbee, #63d8ea,
      #67d5e6, #59d4ec, #48d2f3, #32d1f9, #00cfff, #00ccfd, #00c9fc, #00c7fa,
      #00c4f8, #56d1d7, #80dcb2, #a4e584, #c5ed3a, #d4dc33, #e0cb2c, #eaba24,
      #f3a81c, #f99512, #ff8005, #f2823e, #e68358, #da846c, #cd847d, #d99183,
      #e69f89, #f2ac8f, #ffba95, #fcb894, #fab794, #f7b593, #f5b492, #f1ac8f,
      #eea58c, #ea9d89, #e69686, #ec9387, #f38f89, #f98b8a, #ff878b, #fc878a,
      #f98789, #f68789, #f38788, #f08c9a, #ed90ab, #ea94bc, #e798cd, #de96ce,
      #d694ce, #cd92cf, #c590cf, #c28fc9, #bf8ec4, #bd8dbe, #ba8cb9, #bf8db7,
      #c48fb5, #ca90b3, #cf91b1, #cc90ad, #c98faa, #c68ea6, #c38da3, #bd8ca1,
      #b78a9f, #b2899d, #ac879b, #a48597, #b4838a, #c4817b, #d37d6c, #e2795a,
      #f07445, #ff6d26, #ff5735, #ff3c3f, #ff0047, #fd014e, #fb0155, #fa015b,
      #f80061, #fa046f, #fb077c, #fd0789, #ff0596, #ff08a3, #ff08af, #fd10c2,
      #fb12d6, #fa0ee9, #f800fc, #e81cfd, #d727fe, #c72efe, #b732ff, #a241f9,
      #8c4bf3, #7552ed, #5b57e7, #5e5edf, #6165d7, #656bce, #6970c6, #737ace,
      #7e84d6, #888edd, #9398e5, #8796e5, #7b94e6, #6e91e6, #608fe6, #5babed,
      #53c7f4, #44e3fa
		};
		fillColorsLength = fillColors.length;
		fillColorsArrayIndex = 0;

    delayBetweenRenders = (int) random(87, 875); // has been: 84, 112, 141, 640
	  reloadAfterNrenders = (int) random(28, 65);

    // get divisors of screenWidth that result from dividing by multiples of 2 between M and N; but we're counting by a larger multiple of 2 to give fewer possibilities; NOTE that this assumes the screen width is an even number:
    for (int i=20; i<80; i+=2) {
      int divisor = width / i;
      screenDivisors.append(divisor);
    }

    // get and use the last item of that list:
    fontPointSize = screenDivisors.get(screenDivisors.size() - 1);
	}

	setRNDanimFramesSaveDirName();
}

// For repeat calls, to create a new variant:
void setupNewVariant() {
	// ALTERS GLOBALS:
	variantCount += 1;

  // FOR OTHER POSSIBLE characters to use in superset, see: http://s.earthbound.io/RNDblockChars
  // SUPER SETS DEFINITION from which a superset may be randomly drawn;
  // from that drawn in turn a random subset will be drawn.
  masterCharsSETS.add("┈┉┊┋┌└├┤┬┴┼╌╍╎╭╮╯╰╱╲╳╴╵╶╷");     // box drawing subset
  masterCharsSETS.add("▲△◆◇○◌◍◎●◜◝◞◟◠◡◢◣◤◥◸◹◺◿◻◼");         // geometric shapes subset
  // masterCharsSETS.add("∧∨∩∪∴∵∶∷∸∹∺⊂⊃⊏⊐⊓⊔⊢⊣⋮⋯⋰⋱");               // math operators subset
  // masterCharsSETS.add("◈⟐⟢ːˑ∺≋≎≑≣⊪⊹☱☰☲☳☴☵☶☷፨჻܀");           //Apple emoji subset
  // masterCharsSETS.add("─│┌┐└┘├┤┬┴┼╭╮╯╰╱╲╳▂▃▄▌▍▎▏▒▕▖▗▘▚▝○●◤◥♦");	// Commodore 64 font/drawing glyphs set--which, it happens, combines characters from some of the others interestingly.
  // masterCharsSETS.add("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWZ!\"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ 0");  // all usable from bitBlocks.ttf
  // COLLECTION OF SUPERSETS:
  masterCharsSETS.add("▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟");			// block characters subset
  masterCharsSETS.add("▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟");			// adding multipel times to make it used more. Hacky.
  masterCharsSETS.add("▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟");
  masterCharsSETS.add("┈┉┊┋┌└├┤┬┴┼╌╍╎╭╮╯╰╱╲╳╴╵╶╷▲△◆◇○◌◍◎●◜◝◞◟◠◡◢◣◤◥◸◹◺◿◻◼▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟");   // combining some of those sets

  // randomly select a master superset:
  int masterCharsSETSrndIDX = (int) random(0, masterCharsSETS.size());
  masterCharset = masterCharsSETS.get(masterCharsSETSrndIDX);
  masterCharsetLength = masterCharset.length();

  delayBetweenRenders = (int) random(87, 875); // has been: 84, 112, 141, 640
  reloadAfterNrenders = (int) random(28, 65);
  print("delayBetweenRenders: " + delayBetweenRenders + "; reloadAfterNrenders: " + reloadAfterNrenders + ".\n");

	// set up random fontPointSize from options available in screenDivisors (via division);
	// tried sizes list: 83.4 51.5 43 39.1 32 24 12; unifont was last width/28.46. NOTE: a PointSize that doesn't evenly divide by the canvas width may lead to gaps in the text that cause a look like gaps in wallpaper.
	int rndScreenDivisorIDX = (int) random(0, screenDivisors.size());
	int screenDivisor = screenDivisors.get(rndScreenDivisorIDX);
	fontPointSize = width/screenDivisor;
	print("Randomly chose a fontPointSize of " + fontPointSize + " at variantCount " + variantCount + ".\n");

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

// setup is called ONCE, AFTER settings(), to do anything needed before other functions (e.g. before draw()).
void setup() {
  setupNewVariant();
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
