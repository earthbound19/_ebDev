// "By Small and Simple Things"
// Coded by Richard Alexander Hall 2019
// Generates an animated grid of playfully colored concentric nested circles or n-gons (default circles)
// which change on user click/drag. See USAGE for functionality.
//
// Pretty closely imitates art by Daniel Bartholomew, but with random generative constraints:
// https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/by-small-and-simple-things-22x30/
// re: https://www.abstractoons.com/2017/05/03/by-small-and-simple-things/

// USAGE:
// - click or click and drag on shapes to cause them to change.
// - press the RIGHT arrow key to skip the current displayed variant.
// - press the LEFT arrow key to go back one variant (only one variant remembered).
// - if controlling booleans are set true, click/drag also causes PNG/SVG image save
// (only saves first clicked frame and last frame of variant.)
// - see other global variables as documented below for other functionality.
// NOTE: if saveAllFrames is true, SVG animation frames are saved to _anims/ subfolder,
// grouping by number for this run of the program, variation, an rnd string, and SVG files
// named by frame. The SVGs may be copied out of these subfolders into one folder, and they
// will be incrementally numbered IF saveAllFrames was true for the entire program run.
// if that boolean was toggled off and on during run, the SVG file names won't be strictly
// contiguous, but will still be ordered by higher number last.
// - You can dynamically load external palette files and use them for random
// selection of background, light shape fill, dark shape fill, and
// stroke (outline) color. These palettes have the .hexplt extension, and
// are in the /data subfolder. The file format is a list of RGB color codes
// (in hexadecimal format), one color code per line preceded by #. Whether
// it loads from these palette files is controlled by the global boolean
// variable loadColorsFromHexplts (hard-coded default set to = true). Set
// loadColorsFromHexplts to false and the program will only use the internal
// hard-coded color palettes, which are more varied. The external palettes
// are hard-coded to more pastel colors, sorted into background, light,
// dark, and stroke colors. You may alter the color lists in those external
// files to your liking to more quickly try different colors (more quickly
// than finding the hard-coded color lists in the source code and hacking
// them).
// - You can either use only the hard-coded palettes, or load from the
// external palettes and use those, or randomly alternate between both.
// To use the hardcoded, set loadColorsFromHexplts to false. To use the
// external, set loadColorsFromHexplts to true and rndSwapPalettes
// (you'll find that varaible nearby) to false. To randomly alternate between
// both, set loadColorsFromHexplts to true and set rndSwapPalettes to
// true (which is the default hard-coded).
// - the colorMode global variable controls color modes, and works this way:
// if hard-coded to 1, the program will render everything in full color.
// If set to 2, everything will be rendered grayscale. If set to 3, everything
// will be rendered in the three override background, fill and stroke
// colors set in altBackgroundColor, altFillColor, and altStrokeColor.
// However, by default, it reverts to color mode when every time the program
// creates and renders a new variation (which you can manually do by
// pressing the forward (right) arrow key on the keyboard. You can also go back one
// variation with the back (left) arrow key. To have it keep the same color
// mode through every variation, set keepColorModeOnVariantChange to true.
// - You can double-click (or for a kiosk or tablet, double-tap on the screen)
// to cycle color modes in this order: color -> grayscale -> color override
// -> back to color.


// v2.3.3 work log:
// - Grayscale color mode option (in addition to previously developed color override option)
// - Double-tap or click cycles through these color modes:
// from color to grayscale, override colors, then back to color.
// - Option to force color mode set (initially via colorMode hard-coded value
// OR via user interaction) on variation change. Controlled by
// boolean keepColorModeOnVariantChange (default hard-coded false).
// - New global colorMode controls color mode; see comments near it.
// - Option to dynamically load external palette files and initialize
// arrays with them (from /data subfolder, .hexplt files).
// - Optionally shows loaded palette or randomly uses it or hard-coded palette
// See now expanded USAGE section for details.
String versionString = "v2.3.3";

// TO DO; * = doing:
// * ATTEMPT MADE; may need to work off new fake size/dist values in object: (concentricity
// control and) rnd higher/lower concentricity range.
// - rnd range of nesting, with heavier max stroke / smaller min shape size on less nesting?
// - rnd ellipse eccentricity (would mean using PShape for circle)
// - other items / progress are in tracker at https://github.com/earthbound19/_ebDev/projects/3

// DEPENDENCY IMPORTS and associated globals:
import processing.svg.*;
// for logging:
import java.io.BufferedWriter;
import java.io.FileWriter;
String tweetErrorLogOutfileName = "_tweetErrorLog.txt";
// TO ENABLE IMAGE TWEETS, uncomment the last section of code with a varaible named simpletweet,
// uncomment the desired code, then work backward to hunt for the related code earleir that
// defines simpletweet until you get back to the define which follows these comments, then run
// this script and see if it doesn't complain of undefined things.
// I don't want to require that library to be installed just to run this script, so that's
// how I'm managing disabling / enabling tweet dependency.
// NOTE that this requires the presence of a text file in the same folder, named twitterAPIauth.txt,
// containing OAauth keys that will work with twitter's API. Without those the tweet will fail and
// the console and _tweetErrorLog.txt will note the failure.
// ALSO NOTE: do disalble tweeting, comment out this next line of code, then try to run the script
// and comment out all lines where it says there's an error until there are none.
//import gohai.simpletweet.*;
//SimpleTweet simpletweet;
String[] twitterAPIauthLines;
boolean tryToTweet = true;

// BEGIN GLOBAL VARIABLES:
// NOTE: to control additional information contained in saved file names, see comments in the get_detailed_image_file_name_no_ext() function further below.
int variationNumberThisRun = 0;
boolean booleanOverrideSeed = false;    // if set to true, overrideSeed will be used as the random seed for the first displayed variant. If false, a seed will be chosen randomly.
//The following overrideSeed can by any int, in the range -2,147,483,648 to 2,147,483,647.
int overrideSeed = -1401561856;    // some favorites are: -161287679, 858293248, 617092096, 627672576, 1117351680, -1765838336, -731770112, 1528795392, -1401561856
int previousSeed = overrideSeed;
int seed = overrideSeed;
boolean USE_FULLSCREEN = true;  // if set to true, overrides the following values; if false, they are used:
int globalWidth = 1280;
int globalHeight = 1280;    // dim. of kiosk entered in SMOFA: 1080x1920. scanned 35mm film: 5380x3620
int gridNesting = 4;    // controls how many nests of shapes there are for each shape on the grid.
GridOfNestedAnimatedShapes GridOfShapes;
int GridOfShapesNumCols;    // to be reinitialized in each loop of prepareNextVariation()
int GridOfShapesNumRows;    // "
// used by AnimatedShape objects to scale down animation-related values when the shapes are smaller (so that smaller objects do not animate relatively faster;
// this was itself figured as a place of "how fast I want things to animate when there is one column in an image 1080 pix wide;" AND THEN
// multiplied by two! (because this multiple is used by even the largest shapes, which I don't want scaled by 1/2 because I divide everything . . it's complicated);
// -- becomes: ~1382.4 ALSO NOTE this was with ShapesGridXmaxPercent = 0.64, where circle size max was then 691.2; ALSO with motionVectorMax = 0.273 . . .
// but then I futzed it to 187 anyway because I like that speed better at all scales. ::shrug:: ANYWAY:
int motionVectorScaleBaseReference = 168;
color globalBackgroundColor; color globalBackgroundColorBackup;
color altBackgroundColor = color(0);    // though I quite like: color(30,0,60);
color altFillColor = color(255);    // though I quite like: color(255,0,255);
color altStrokeColor = color(117);    // though I quite like: color(80,80,120);
int colorMode = 1;	// 1 = color mode, 2 = grayscale, 3 = color override
boolean keepColorModeOnVariantChange = false;		// If set, whatever colorMode is at launch, it will stay thus until user changes it. Then it will keep that changed mode for every new variant.
// for "frenetic option", loop creates a list of size gridNesting (of ints) :
// IntList nestedGridRenderOrder = new IntList();    // because this list has a shuffle() member function, re: https://processing.org/reference/IntList.html
// TESTING NOTES: states to test:
// true / false for savePNGs, saveSVGs, saveEveryVariation, and (maybe--though I'm confident it works regardless) saveAllFrames, and saveAllFramesWasFalse:
// START VARIABLES RELATED TO image save:
boolean savePNGs = true;  // Save PNG images or not
boolean saveSVGs = true;  // Save SVG images or not
boolean saveAllFrames = false;    // if true, all frames up to renderNtotalFrames are saved (and then the program is terminated), so that they can be strung together in a video. Overrieds saveSVGs, but not savePNGs.
boolean saveAllFramesInteractOverride = false;		// overrides saveAllFrames + saveSVGs on user interact 'till end of variant.
boolean initialSaveAllFramesState = saveAllFrames;		// stores initial state (boolean copy) to revert to after override period.
boolean initialSaveSVGsState = saveSVGs;							// stores initial state (boolean copy) to revert to after override period.
// TEMP OR PERMANENT KLUDGE: not using the following. Could cut off user and close program at museum! :
// int renderNtotalFrames = 7200;    // see saveAllFrames comment
int totalFramesRendered;    // incremented during each frame of a running variation. reset at new variation.
int framesRenderedThisVariation;
boolean saveEveryVariation = false;    // Saves last frame of every variation, IF savePNGs and/or saveSVGs is (are) set to true. Also note that if saveEveryVariation is set to true, you can use doFixedTimePerVariation and a low fixedMillisecondsPerVariation to rapidly generate and save variations.
boolean doFixedTimePerVariation = false;    // if true, each variation will display for N frames, per fixedMillisecondsPerVariation
int fixedMillisecondsPerVariation = (int) (1000 * 11.5);         // milliseconds to display each variation, if previous boolean is true
int minMillisecondsPerVariation = (int) (1000 * 16.5);      // 1000 milliseconds * 16.5 = 16.5 seconds
int maxMillisecondsPerVariation = (int) (1000 * 52);        // 1000 milliesconds * 52 = 52 seconds
int currentTimeMilliseconds;
int runSetupAtMilliseconds;     // at start of each variation, altered to cue time for next variation
String userInteractionString;   // changed to states reflecting whether user interacted with a variation or not (empty or not empty)
// END VARIABLES RELATED TO image save.
boolean estimateFPS = false;		// vestige from estimating / throttling framerate before I learned about frameRate()). Still useful for displaying time to next variation.
int estimatedFPS = 0;    // dynamically modified by program as it runs (and prints running estimatedFPS estimate), IF that afore boolean is true
// reference of original art:
// larger original grid size: 25x14, wobbly circle placement, wobbly concentricity in circles.
// smaller original grid size: 19x13, regular circle placement on grid, wobbly concentricity in circles.
// SMOFA entry configuration for the following values, for ~6' tall kiosk: 1, 21. Before more advanced anim, ~21
// ~4K resolution horizontally larger monitors: 1, 43
int minColumns = 2; int maxColumns = 21;
float ShapesGridXminPercent = 0.231;   // minimum diameter/apothem of shape vs. grid cell size.   Maybe best ~ .2
float ShapesGridXmaxPercent = 0.681;   // maximum ""                                       Maybe best ~ .67
int minimumNgonSides = -11;    // If negative number, n*-1*-1 (many more) chance of choosing circle on rnd shape draw.
int maximumNgonSides = 7;      // Preferred: 7. Max number of shape sides randomly chosen. 0, 1 and 2 will be circles. 3 will be a triangle, 4 a square, 5 a pentagon, and so on.
float parentMaxWanderDistMultiple = 1.372;		// how far beyond origin + max radius, as percent, a parent shape can wander. Default hard-coding: 1.372 (~137% percent past max origin)
float strokeMinWeightMult = 0.0064;		// stroke or outline min size multiplier vs. shape diameter--diameters change! 
float strokeMaxWeightMult = 0.0307;		// stroke or outline max size multiplier vs. shape diameter
float diameterMorphRateMin = 0.0004;	// minimum rate of shape size contract or expand
float diameterMorphRateMax = 0.0031;	// maximum "
float motionVectorMax = 0.6;          // maximum pixels (I think?) an object moves per frame. Randomizes between this and (this * -1) * a downscale multiplier, per shapes' diameter.
float orbitRadiansRateMax = 8.84;			// how many degrees maximum any shape may orbit per call of orbit()
float rotationRadiansRateMax = 4;			// how many degrees maximum any shape may orbit per call of shapeRotate();
boolean lazyParentBoundaryConstraint = false;		// If true, every N ms (13?), shape wander is constrained within parent shape. If false, ALL frames are constrained.
int disableColorMorphAfter_ms = 21426;
//TO IMPLEMENT: int disableWanderIfRoll = 4;
boolean loadColorsFromHexplts = true;    // If set to true, palettes are dynamically loaded from files in the /data folder and used. Otherwise the hard-coded palettes are used.
boolean rndSwapPalettes = true;                  // If set to true, palettes will randomly swap from hard-coded to the dynamically loaded ones IF loadColorsFromHexplts is also true.
//TO IMPLEMENT: int loadColorsFromCodeIfRoll = 7;

// Colors arrays designated as HC for Hard Coded, which may copied or not copied to what
// the script uses:
color[] backgroundColors_HC = {
	// colors from _ebArt/blob/master/palettes/fundamental_vivid_hues.hexplt :
	#FF00FF, #FF00E2, #FF007F, #FF0070, #FC2273, #FF0000, #FF1200, #FF5100, #FD730A, #FFA100,
	#FFB700, #FFCD00, #FAE000, #FFFF00, #FAFF54, #AFE300, #75FF00, #00FF00, #25FD73, #52FE79,
	#7FFF7F, #40F37E, #33EB80, #00E77D, #1DCF00, #65D700, #76F1A8, #7FFFFF, #00FFFF, #00E4FF,
	#00CFFF, #00C4FF, #007FFF, #6060FF, #7F40FF, #7202FF, #5F00BE, #4D00A6, #40007F, #3C1CB3,
	#3325D6, #0000FF, #4040FF, #6A6AFF, #7F7FFF, #407FBF, #007F7F, #2B2BAB, #00007F, #54007F,
	#7F007F, #7F0038, #7F0000
};

color[] darkFillColors_HC = {
	// from: _ebArt/blob/master/palettes/fundamental_vivid_hues_darks.hexplt
	#B300BC, #A938A5, #B500A3, #9F0091, #962494, #9E00AA, #870098, #820782, #86007D, #6D006F,
	#6D0085, #590D84, #54007F, #52007C, #460071, #3B007A, #2D006E, #320062, #380044, #490055,
	#55005A, #6C2997, #5D349E, #5C2AB7, #6417C4, #5F00BE, #5000B4, #4D02A6, #4D00A6, #4900A8,
	#4300B1, #4300BA, #3C1CB3, #391CAD, #3D00AE, #3800AE, #3A00A5, #3D009E, #2E00A6, #21009B,
	#002091, #001587, #001175, #00156F, #001865, #001A62, #001E57, #0D234C, #002342, #003268,
	#003074, #192775, #003092, #00399A, #0042A0, #0E4DB4, #0048CF, #0027FF, #1300FC, #0000FF,
	#3400E8, #3325D6, #322FC8, #3631DB, #3721F2, #3F00ED, #422BDA, #442FD1, #471FDA, #5100E8,
	#5B00EC, #5D00E8, #6400E1, #6700F3, #7000FF, #7202FF, #7125F0, #7335D4, #6C40C8, #6D47B0,
	#7D58C1, #7B53D9, #8249E5, #8037FF, #7F40FF, #7F41FF, #635DE2, #5E5BF1, #5B59F9, #4C57FF,
	#5464DB, #446DC9, #0070CC, #006BC3, #3374B3, #0074A5, #00719E, #00748E, #00637C, #005F8D,
	#005490, #004A83, #00447E, #003F7E, #003B56, #00506A, #004A4B, #005757, #006162, #006759,
	#007667, #007674, #007F7F, #008454, #008548, #007439, #007547, #00663A, #00622A, #00562C,
	#004E19, #00451E, #003B00, #003800, #173000, #072800, #002B00, #002100, #001C01, #041800,
	#001300, #041100, #151300, #1C1000, #210C00, #351600, #431B00, #4A2500, #3D2100, #362500,
	#412B00, #4C3900, #403E00, #323300, #2C2A00, #212200, #291E00, #2A1D00, #2E1B00, #491400,
	#440000, #4C0000, #590000, #680000, #720E00, #731900, #7B0000, #810000, #850000, #901107,
	#960000, #9A0F00, #A20000, #AD0200, #B31E00, #C11700, #BC0000, #C62700, #D50000, #BD3523,
	#A72515, #A23100, #AD4000, #B84100, #A35700, #995F00, #8E6600, #826C00, #767200, #727300,
	#626200, #666100, #715C00, #7C5600, #864F00, #8F4700, #7A3700, #723F00, #6E4200, #694500,
	#5F4B00, #555000, #515100, #3C5800, #385900, #2E5B00, #176100, #006000, #006700, #026F00,
	#007500, #007815, #197E00, #128500, #008700, #008616, #2E7300, #467900, #557C00, #557600,
	#476B00, #496700, #005300, #005000, #284500, #304800, #00320E, #142600, #192911, #003429,
	#003637, #00393C, #00262C, #002225, #001F22, #001F20, #00463A, #00574A, #1F63A2, #005CB4,
	#335CB8, #005CDF, #0B5EFF, #006DEF, #006EEF, #0047FF, #4040FF, #424AEA, #4E45E9, #5047E1,
	#544CCE, #4735C1, #4637BD, #373FB9, #2B2BAB, #2927A9, #3500BB, #3800C8, #3900CD, #2E00CE,
	#002EC1, #0000BA, #0000AE, #100080, #00007F, #00095C, #4C1D8C, #4B00BC, #5800D4, #5E00FF,
	#5F00FF, #9300FF, #9A00FF, #8E4EBA, #7D3DA9, #A22551, #A20040, #9F0036, #A20035, #B80046,
	#BB0044, #BB0050, #CE0054, #D20053, #B73660, #8C1041, #7F0038, #740030, #860030, #840026,
	#860025, #650015, #58001E, #3E0004, #350000, #2A0300, #5C3400, #8B2100, #8D1D00
};

color[] lightFillColors_HC = {
	// from: _ebArt/blob/master/palettes/fundamental_vivid_hues_lights.hexplt
	#FF00FF, #FF00E2, #FF007F, #FF0070, #FC2273, #FF0000, #FF1200, #FF5100, #FD730A, #FFA100,
	#FFB700, #FFCD00, #FAE000, #FFFF00, #FAFF54, #AFE300, #75FF00, #00FF00, #25FD73, #52FE79,
	#7FFF7F, #40F37E, #33EB80, #00E77D, #1DCF00, #65D700, #76F1A8, #7FFFFF, #00FFFF, #00E4FF,
	#00CFFF, #00C4FF, #007FFF, #6060FF, #6A6AFF, #7F7FFF, #6A7FEA, #557FD5, #407FBF, #6666CC,
	#8C4CD8, #B233E5, #D819F1, #FE00FE, #FF2CFF, #FF30F4, #FF45FF, #FF56FF, #EC75E4, #FC83F2,
	#FF90FF, #E7A5FF, #D6A6FF, #CEA1FF, #C999FF, #C396FF, #C292FF, #BB8AFF, #B894FF, #C19FFF,
	#CFADFF, #D3AFFF, #D998FF, #CB8AF9, #BC7CEA, #AD6EDB, #9E5ECB, #8C68D2, #8964E9, #915BF5,
	#8D4EFF, #9A62FF, #9F6CFF, #9874F9, #A878FF, #AD7CFF, #A683FF, #AA86F1, #9B77E2, #8D8CFF,
	#8C8DFF, #868CFF, #838BFF, #7E93FF, #7F9BFF, #849EFF, #909AFF, #949AFF, #9A9BFF, #9A9CFF,
	#9DA8FF, #A7AAFF, #A7A9FF, #A9B6FF, #B4B8FF, #B4B7FF, #A6BDFF, #9EBAFF, #99B0FF, #8CAAFF,
	#7EA9FF, #709BF9, #54A2FF, #3C9EFF, #4593FF, #268FFF, #3483FF, #2271FF, #586AFF, #5C6FFF,
	#686BFF, #6B6CFF, #716EF2, #716FEF, #6275EB, #657CFF, #6A7FFF, #7084FB, #728CFF, #628CE9,
	#537DDA, #4583C4, #5593D3, #64A1E3, #72AFF2, #62B1FF, #4DADFF, #5DBBFF, #70BFFF, #80BDFF,
	#8CB7FF, #99C4FF, #8ECBFF, #6CC9FF, #1CCAFF, #00CCFC, #3AD7FF, #2ADAFF, #00DEF9, #00D0EB,
	#00C2DC, #00B3CE, #00A4BE, #0095AF, #0091BF, #008FC8, #009ED8, #00A1CF, #00AFDE, #00ADE7,
	#00BCF6, #00BEED, #30BFC0, #00C6C7, #45CDCE, #1FD1D2, #00D4D5, #2FD8D8, #56DBDB, #27DFDF,
	#00E2E3, #42DBDC, #78D6D6, #6AC9C8, #5BBBBA, #00B8B8, #0EB1B1, #00A9AA, #00A2A3, #3A9E9D,
	#00999A, #009393, #258E8E, #00898A, #008384, #00859F, #0081AF, #007FB8, #307ED4, #497DE3,
	#617DF1, #797CFF, #9553FF, #B12AFF, #CE00FF, #DB00DE, #ED00EF, #F100D6, #FF10E5, #DE00C5,
	#CA00B5, #C700CE, #C318C6, #BF30BE, #BB49B6, #CC59C5, #DC67D5, #FF56B2, #FF56A3, #FF60A5,
	#FF5298, #FF4796, #FF438B, #FF3689, #FF337E, #FF227C, #FC007D, #FF218A, #FF3698, #FF47A5,
	#EF628B, #FF7099, #FF7DA6, #FF8AB3, #FF898F, #FF876A, #FF7B5F, #FF6E53, #F86047, #FF5937,
	#FF5537, #FF4B2B, #FF472C, #FF3C20, #FF3720, #FF2B12, #FF2513, #FF1501, #FF0802, #ED0000,
	#EB0000, #DB3700, #F04600, #FF5404, #FF6117, #FF6E25, #FF7B31, #FF7812, #FF8521, #FF912E,
	#F99C00, #FFA912, #FAB300, #EBA600, #DDAE00, #ECBB00, #DCC300, #CCCA00, #C7CB21, #BEBD00,
	#BABD0C, #B1AE00, #ACAF00, #9EA100, #A2A000, #B19900, #BF9200, #CC8A00, #D98100, #E98F00,
	#DC9800, #CEA000, #C0A800, #CEB500, #98C900, #A4D700, #6FE218, #5DE500, #40E728, #00EC00,
	#00DD00, #2ED915, #50D700, #62D400, #55C500, #41C800, #12CA00, #00CE00, #00BF00, #00BB00,
	#47B600, #00AF00, #00AB00, #1EA900, #38A600, #009E00, #009800, #279600, #009D21, #009726,
	#009B33, #1FA734, #00AD2F, #00AB41, #34B641, #00BA40, #00BA56, #00BB58, #00C963, #00C94D,
	#00CC4A, #45C54E, #54D45A, #17D859, #05D867, #00D86F, #2BE67C, #2DE673, #33E765, #63E266,
	#63DF98, #54D18B, #44C37E, #46BB8D, #49B49C, #4BACAC, #43AF99, #3BB185, #32B471, #19A564,
	#009556, #008B2F, #008A2E, #008A25, #008A14, #008C0E, #008D00, #008900, #638D00, #719C00,
	#7EAC00, #8BBA00, #909200, #949100, #A28B00, #AF8400, #BC7C00, #C87400, #B66500, #AA6E00,
	#9F7500, #937C00, #858200, #818300, #DF5D00, #F26B00, #CC4F00, #D1442F, #E5533B, #DD547D,
	#CA466F, #D20060, #E40063, #E7006E, #F81E70, #E73400, #E63D00, #D74F00, #CF5800, #DF6400,
	#E85A00, #FF6200, #FF6400, #FF6D00, #FF7700, #FF7B00, #FF8200, #FF8600, #FF9000, #FF9100,
	#FF9600, #FF9A00, #FF9B00, #FFA000, #FFA502, #FFA501, #FFAA06, #FFAF17, #FFAF18, #FFBA25,
	#FABC0A, #FFC431, #FFC71D, #FFCE3B, #FFD22A, #FFDD35, #FFDC00, #FFE718, #FFE740, #FCED42,
	#FFF249, #FFF84C, #FFFF55, #FFFF67, #FFF960, #FFF65E, #FEEB54, #F3E04B, #F0E237, #E5D72C,
	#E8D541, #DCCA37, #DACB1F, #E8C600, #F4D100, #DCBA00, #D1BE2C, #CEC00E, #C2B400, #C5B320,
	#D0AF00, #E1A500, #EEB100, #DD8B00, #EE8900, #EF6F00, #FF4C00, #D52700, #CD2E00, #BF4C00,
	#C64300, #AB7600, #B98200, #927A00, #7A7F00, #608300, #518700, #298C08, #379919, #43A726,
	#4FB432, #5BC03C, #66CD47, #71D951, #7CE55B, #86F165, #90FD6E, #9BFF78, #A5FF81, #AFFF8B,
	#B0F800, #BAFF00, #C4FF0B, #CCFF00, #CEFF21, #D6FF0B, #E0FF21, #E9F600, #F3FF13, #FEFF25,
	#FFFD34, #FFF228, #DEEA00, #D3DF00, #C8D300, #BDC800, #B2BC00, #A6AF00, #9BA300, #82AB00,
	#72AF00, #7CBC00, #8DB800, #98C400, #87C800, #91D500, #A2D000, #ADDC00, #B7E800, #A6ED00,
	#9CE100, #00DEA5, #09EAB0, #2DF6BB, #40FFC6, #51FFD0, #5FFFDB, #6CFFE5, #00FFE4, #00FFED,
	#00F6E2, #00EAD6, #00DECB, #00D2BF, #00C6B3, #00B9A7, #00AD9B, #009F8E, #009282, #009290,
	#009F9D, #00ACAA, #00B9B6, #00C5C3, #00D2CF, #00DEDB, #00E9E6, #00F5F2, #00FDFF, #36FFFF,
	#42FFFF, #00FFFD, #24FFF8, #00F5FF, #00F4FF, #00EAFF, #00E7FF, #00E6FF, #00DFFF, #00DEFF,
	#00DCFF, #00DBFF, #00D3FF, #00C7FF, #00C2FF, #00C4F6, #00B8E9, #00B6F3, #00BAFF, #51BDFF,
	#5EC8FF, #6AD4FF, #76DFFF, #82EBFF, #8DF6FF, #98FFFF, #A3FFFF, #82F6EB, #62EDD7, #41E4C2,
	#21DBAE, #00D29A, #00C68F, #00B984, #00AC78, #009F6C, #009260, #008474, #008482, #0083B3,
	#0082BA, #0081BD, #008FCB, #0090C1, #009ECF, #009DD5, #009CD9, #00A9E6, #00AAE3, #00ABDC,
	#00AEFF, #42B1FF, #32A4FF, #00A2FC, #00A1FA, #1C98F6, #0095EE, #0094ED, #008BE8, #0087E0,
	#0087DF, #007EDA, #007AD2, #0079D1, #0076F3, #008BFF, #0E8ACC, #1C8899, #298766, #378533,
	#458400, #5C9500, #6C9100, #779E00, #67A200, #85BD00, #A3D800, #C2F400, #CBD200, #D4B000,
	#DD8E00, #E76C00, #F04B00, #F92900
};

color[] allFillColors_HC = {
	// from: github.com/earthbound19/_ebArt/blob/master/palettes/rainbowHexColorsByMyEyeManyShadesLoop.hexplt
	#FF1200, #E73400, #E63D00, #D74F00, #CF5800, #DF6400, #E85A00, #FF6200, #FF6400, #FF6D00,
	#FF7700, #FF7B00, #FF8200, #FF8600, #FF9000, #FF9100, #FF9600, #FF9B00, #FFA000, #FFA502,
	#FFA501, #FFAA06, #FFAF17, #FFAF18, #FFB700, #FFBA25, #FABC0A, #FFC431, #FFC71D, #FFCE3B,
	#FFD22A, #FFDD35, #FFDC00, #FAE000, #FFE740, #FCED42, #FFF84C, #FAFF54, #FFFF67, #FFF960,
	#FFF65E, #FEEB54, #F3E04B, #F0E237, #E8D541, #DCCA37, #DACB1F, #E8C600, #F4D100, #DCBA00,
	#D1BE2C, #C2B400, #D0AF00, #E1A500, #EEB100, #DD8B00, #EE8900, #EF6F00, #FF4C00, #D52700,
	#CD2E00, #C11700, #B31E00, #AD0200, #9A0F00, #980000, #8D1D00, #882700, #9B3400, #A12A00,
	#B43700, #AD4000, #BF4C00, #C64300, #BD5400, #B46500, #AB7600, #B98200, #927A00, #7A7F00,
	#608300, #518700, #298C08, #379919, #43A726, #4FB432, #5BC03C, #66CD47, #71D951, #7CE55B,
	#86F165, #90FD6E, #9BFF78, #A5FF81, #AFFF8B, #B0F800, #BAFF00, #C4FF0B, #CEFF21, #D6FF0B,
	#E0FF21, #E9F600, #F3FF13, #FFFD34, #FFF228, #DEEA00, #D3DF00, #C8D300, #BDC800, #B2BC00,
	#A6AF00, #9BA300, #82AB00, #72AF00, #7CBC00, #8DB800, #98C400, #87C800, #91D500, #A2D000,
	#ADDC00, #AFE300, #B7E800, #A6ED00, #9CE100, #65D700, #1DCF00, #00E77D, #00DEA5, #09EAB0,
	#2DF6BB, #40FFC6, #51FFD0, #5FFFDB, #6CFFE5, #00FFE4, #00FFED, #00F6E2, #00EAD6, #00DECB,
	#00D2BF, #00C6B3, #00B9A7, #00AD9B, #009F8E, #009282, #009290, #009F9D, #00ACAA, #00B9B6,
	#00C5C3, #00D2CF, #00DEDB, #00E9E6, #00F5F2, #00FDFF, #00FFFF, #13FFFF, #2BFFFF, #3DFFFF,
	#42FFFF, #4FFFFF, #24FFF8, #00F6FF, #00F2FF, #00E8FF, #00E6FF, #00DFFF, #00DCFF, #00DBFF,
	#00D0FF, #00C7FF, #00C4F6, #00B8E9, #00B6F3, #00BBFF, #51BDFF, #5EC8FF, #6AD4FF, #76DFFF,
	#82EBFF, #8DF6FF, #98FFFF, #A3FFFF, #82F6EB, #62EDD7, #41E4C2, #21DBAE, #00D29A, #00C68F,
	#00B984, #00AC78, #009F6C, #009260, #008454, #007547, #00663A, #00562C, #00451E, #00320E,
	#002B00, #072800, #142600, #212200, #291E00, #2A1D00, #2E1B00, #351600, #4A2500, #412B00,
	#5C3400, #6E4200, #731900, #680000, #810000, #4C0000, #470000, #440000, #2B0000, #270000,
	#041100, #001300, #001C01, #003429, #00463A, #004647, #005757, #00574A, #006759, #006766,
	#007674, #007667, #008474, #008482, #0083B3, #0081BD, #008FC8, #0090C1, #009DD5, #009CD9,
	#00AAE3, #00ABDC, #00AEFF, #42B1FF, #32A4FF, #00A2FC, #00A1FA, #1C98F6, #0095EE, #008BE8,
	#0087DF, #007AD2, #0070CC, #006BC3, #005CB4, #0E4DB4, #0042A0, #003998, #002091, #0B0097,
	#0000AE, #001175, #00156F, #001A62, #003074, #003170, #003268, #004381, #00447E, #004577,
	#00558D, #005490, #005686, #006696, #0064A0, #0073AE, #0074A5, #006DEF, #0076F3, #008BFF,
	#4146E5, #3325D6, #2B2EB5, #3A1FB6, #3C1CB3, #4300BA, #4300B1, #4400AD, #3E00AA, #3D00AE,
	#3A00A5, #3900A5, #4810B6, #5000B4, #5F00BE, #6400D2, #6900E5, #7000FF, #5B10ED, #471FDA,
	#322FC8, #262B9F, #192775, #0D234C, #001F22, #192911, #323300, #304800, #3C5800, #2E5B00,
	#006000, #026F00, #197E00, #467900, #557600, #496700, #005000, #176100, #2E7300, #458400,
	#5C9500, #6C9100, #779E00, #67A200, #85BD00, #A3D800, #C2F400, #CBD200, #D4B000, #DD8E00,
	#E76C00, #F04B00, #F92900
};
// the color palettes that will actually be used, by copy of the avove and or creation and
// assingment from other palettes; and associated variables; initialization of them is done
// here (in earlier revisions they weren't and that was a bad idea), and they may
// be reinistiliazed elsewhere:
color[] backgroundColors = backgroundColors_HC.clone();
color[] darkFillColors = darkFillColors_HC.clone();
color[] lightFillColors = lightFillColors_HC.clone();
color[] allFillColors = allFillColors_HC.clone();
int backgroundColorsArrayLength = backgroundColors.length;
int darkFillColorsArrayLength = darkFillColors.length;
int lightFillColorsArrayLength = lightFillColors.length;
int allFillColorsArrayLength = allFillColors.length;
int RNDbgColorIDX = (int) random(backgroundColorsArrayLength);	    // to be used as random index from array of colors
// For backup and reload of palettes when grayscale mode is toggled:
color[] bgColorsBAK = backgroundColors.clone();
color[] darkFillColorsBAK = darkFillColors.clone();
color[] lightFillColorsBAK = lightFillColors.clone();
color[] allFillColorsBAK = allFillColors.clone();
// END GLOBAL VARIABLES


// BEGIN GLOBAL FUNCTIONS
// LOADS palettes from external files:
// I can't return multiple values or alter an external (dynamic?) object
// from within a java function, so I have to settle for returning a new object,
// then altering the external variables that help work with the object, from
// outside this function:
color[] loadColorsToArray(String source_hexplt) {
	if (loadColorsFromHexplts == false)
	{ print("WARNING: loadColorsToArray called but boolean loadColorsFromHexplts false.\n"); }
		String[] textColors = loadStrings(source_hexplt);
		int[] colorColors;
	  colorColors = new int[textColors.length];
	  for( int i=0; i < textColors.length; i++) {
	    colorColors[i] = color( unhex( textColors[i].substring(1,3) ), unhex( 										textColors[i].substring(3,5) ), unhex( textColors[i].substring(5,7) ) );
	    	// println( textColors[i] + " => (" + int(red(colorColors[i])) + ", " + int(green(colorColors[i])) + ", " + int(blue(colorColors[i])) + ") => " + textColors[i] );
	  }
	return colorColors;
}


// To initialize and subsequently reinitialize delay to creating and animating next variant:
void setDelayToNextVariant() {
  // SETUP DELAY until this function will be called again by altering the timer control values;
  // otherwise this block here that we're running will be immediately called again (as
  // runSetupAtMilliseconds hasn't incremented) :
  if (doFixedTimePerVariation == true) {
    runSetupAtMilliseconds = currentTimeMilliseconds + fixedMillisecondsPerVariation;
  } else {
    int tmp_MS_to_add_till_next_variation = (int) random(minMillisecondsPerVariation, maxMillisecondsPerVariation);
    runSetupAtMilliseconds = currentTimeMilliseconds + tmp_MS_to_add_till_next_variation;
  }
}


// if less than short number of seconds until next variant, add that + more seconds 'till next variant
// (in circumstances where this function call will be executed) :
void addGracePeriodToNextVariant() {
  int tmp_millis = millis();
  int time_to_next_variant = runSetupAtMilliseconds - tmp_millis;
  if (time_to_next_variant < 13750) {
    runSetupAtMilliseconds += 28750;
    print("ADDED TIME delay until next variation because of user interaction.\n");
  }
}


// Because I want to respond to both mousePressed AND mouseDragged events, those functions can pass mouseX and mouseY to this when they are called:
void change_mode_at_XY(int Xpos, int Ypos, int eventType) {
  // collision detection of mouse x and y pos vs. center and radius of circle via this genius breath: https://happycoding.io/tutorials/processing/collision-detection ;
  // checks if distance between center of shapes and mouse click is less than radius of circle. if smaller, click  was inside circle. if greater, was outside:
  for (int grid_Y = 0; grid_Y < GridOfShapesNumRows; grid_Y ++) {
    for (int grid_X = 0; grid_X < GridOfShapesNumCols; grid_X ++) {
      float shape_center_x = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].centerXY.x;
      // I need to go home and rethink my life. Wait. I _am_ home.
      float shape_center_y = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].centerXY.y;
      float shape_radius = GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[0].diameter / 2;
      // if click was within radius of a circle (or apothem of shape) (which will be caught in the amazing speed of
      // for loops in modern computers), activate color morph mode for that shape and all nested shapes in it:
        if (dist(Xpos, Ypos, shape_center_x, shape_center_y) < shape_radius) {
        // int hooman_column = grid_X + 1; int hooman_row = grid_Y + 1;    // compensate for humans; compy starts count at 0
            // print("Click is within shape at row " + hooman_row + " column " + hooman_column + "!\n");
            // activate color morph mode on all AnimatedShapes in AnimatedShapesArray:
        for (int N = 0; N < gridNesting; N ++) {
			GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].AnimatedShapesArray[N].change_mode(eventType);
        }
      }
    }
  }
}


// get file name without extension -- for use before image save function or alternately before svg save (add extension to returned string)
String get_detailed_image_file_name_no_ext() {
  int N_cols_tmp = GridOfShapes.cols;
	int nesting_tmp = GridOfShapes.ShapesGridOBJ[0][0].nesting;		// assumes (at this writing correctly) that number applies to all objects in that 2d array
  String BGcolorHex = hex(globalBackgroundColor);
  BGcolorHex = BGcolorHex.substring(2, 8);    // take the first two characters (which will, the way this is set up, be FF, for full alpha) off
  String img_file_name_no_ext =
    "By Small and Simple Things " + versionString + " seed " + seed
    // COMMENT OUT any of the below additions that you don't want in the file name,
    // un UNCOMMENT any that you do--and I strongly recommend keeping the
    // frame number and user interaction string in the file name, as this script
    // can save it when a user interacts and then also at the last frame of a
    // displayed variation before the next variation:
     + " cols " + N_cols_tmp
     + " bgHex " + BGcolorHex
		 + " nesting " + nesting_tmp 
    // + " pix " + width + "x" + height
     + " frame " + framesRenderedThisVariation
     + userInteractionString;

  return img_file_name_no_ext;
}

// get simple file name more usable for e.g. what may become part of the text of a tweet:
String get_simple_file_name_no_ext() {
  String simple_img_file_name_no_ext =
  "By Small and Simple Things " + versionString + " seed " + seed
  + " frame " + framesRenderedThisVariation;
  return simple_img_file_name_no_ext;
}


// saves whatever is rendered at the moment (expects PNG or other supported raster image file name):
void save_PNG() {
  String FNNE = get_detailed_image_file_name_no_ext();
  //LOCAL FOLDER SAVE:
  saveFrame(FNNE + ".png");

  // CLOUD SAVE option one (SMOFA kiosk, Windows) ;
   //saveFrame("C:\\Users\\SMOFA_guest\\Dropbox\\By_Small_and_Simple_Things__SMOFA_visitor_image_saves\\" + FNNE + ".png");

  // CLOUD SAVE option two (RAH collecting images, Mac) :
  // saveFrame("/Users/earthbound/Dropbox/small_and_simple_things_RAH_image_saves/" + FNNE + ".png");
}


// checks properties of two shapes to determine whether one is within the other and returns boolean saying which:
boolean is_shape_within_shape(PVector larger_shape_XY, float larger_shape_diameter, PVector smaller_shape_XY, float smaller_shape_diameter) {
  float centers_distance = dist(larger_shape_XY.x, larger_shape_XY.y, smaller_shape_XY.x, smaller_shape_XY.y);
  float radii_difference = (larger_shape_diameter / 2) - (smaller_shape_diameter / 2);
  boolean is_within_shape = true;
  if (centers_distance > radii_difference) { is_within_shape = false; } else { is_within_shape = true; }
  return is_within_shape;
}


// takes six values: the x and y center coordinate and diamter of a larger circle or shape
// (intended use), and the same for a smaller shape. returns a PVector which is the x and y
// coordinates to make the smaller shape interior nearest tangent to the larger shape
// (constrained within its maximum or nearest edge). Intended use: to keep shapes within
// shapes from wandering outside the shape.
PVector get_larger_to_smaller_shape_interior_tangent_PVector(
PVector larger_shape_XY, float larger_shape_diameter,
PVector smaller_shape_XY, float smaller_shape_diameter
) {
  PVector coords_to_return = new PVector(0,0);    // will be 0,0 unless changed
  boolean is_within_shape = is_shape_within_shape(larger_shape_XY, larger_shape_diameter, smaller_shape_XY, smaller_shape_diameter);
  if (is_within_shape == false) {
            // print("circle/shape is outside larger circle/shape.\n");
    float target_centers_dist = (larger_shape_diameter / 2) - (smaller_shape_diameter / 2);
    float shapes_center_to_center_dist = dist(larger_shape_XY.x, larger_shape_XY.y, smaller_shape_XY.x, smaller_shape_XY.y);
    float centers_to_target_dist_mult = target_centers_dist / shapes_center_to_center_dist;
    float Xdiff = larger_shape_XY.x - smaller_shape_XY.x;
    float Ydiff = larger_shape_XY.y - smaller_shape_XY.y;
    float newX = larger_shape_XY.x - (Xdiff * centers_to_target_dist_mult);   // a + will put it tangent opposite side
    float newY = larger_shape_XY.y - (Ydiff * centers_to_target_dist_mult);
    coords_to_return = new PVector(newX, newY);
    }
  return coords_to_return;
}


// FOR LAZY CONSTRAINING to parent inner edge boundary:
// delays to set a boolean true at an interval (boolean will be used to time
// setting a constraint), so we can check every N ms for collissions
// instead of every single run of a loop, which can (maybe?) bog it down.
boolean delay_started = false;  // only false to start, true thereafter and a function never called again after true.
boolean detect_collision_now = false;
int constrainToParentInnerBoundaryDelay_ms = 70;
void start_parent_shape_bound_constrain_timer() {
// only start time if we're even using lazyParentBoundaryConstraint, bcse otherwise
// script constrains all regardless:
  if (delay_started == false && lazyParentBoundaryConstraint == true) {
    thread("set_parent_shape_bound_constrain_on");
    delay_started = true;
  }
}
// ->
void set_parent_shape_bound_constrain_on() {
  delay(constrainToParentInnerBoundaryDelay_ms);
  detect_collision_now = true;
  thread("set_parent_shape_bound_constrain_off");
}
// ->
void set_parent_shape_bound_constrain_off() {
  delay(constrainToParentInnerBoundaryDelay_ms);
  detect_collision_now = false;
  thread("set_parent_shape_bound_constrain_on");
}


String get_random_string(int length) {
	// https://programming.guide/java/generate-random-character.html
	String felf = "";
	String rnd_string_components = "abcdeghijklmnopqruvwyzABCDEGHIJKLMNOPQRUVWYZ23456789";
	for (int i = 0; i < length; i++)
	{
	int rnd_choice = (int) random(0, rnd_string_components.length());
	felf+= rnd_string_components.charAt(rnd_choice);
	}
	return felf;
}

String get_formatted_datetime() {
int d = day(); String dS = nf(d, 2);
int m = month(); String mS = nf(m, 2);
int y = year(); String yS = nf(y, 4);
int h = hour(); String hS = nf(h, 2);
int min = minute(); String minS = nf(min, 2);
int s = second(); String sS = nf(s, 2);
String formattedDateTime = yS + "_" + mS + "_" + dS + "__" + hS + "_" + minS + "_" + sS;
return formattedDateTime;
}

// for logging:
// creates file if it doesn't exist, appending data only:
void appendTextToFile(String filename, String text) {
  File f = new File(sketchPath(filename));
  if(!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  } catch (IOException e) {
      e.printStackTrace();
  }
}
// also for logging:
// creates a new file including all subfolders:
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  } catch (Exception e) {
    e.printStackTrace();
  }
}


void global_shapes_grid_update_colors() {
  for (int grid_Y = 0; grid_Y < GridOfShapesNumRows; grid_Y ++) {
    for (int grid_X = 0; grid_X < GridOfShapesNumCols; grid_X ++) {
      GridOfShapes.ShapesGridOBJ[grid_Y][grid_X].updateNestedShapesColors();
    }
  }
}
// END GLOBAL FUNCTIONS




// BEGIN CLASSES
// class that contains persisting, modifiable information on a circle.
// NOTE: uses the above global darkFillColors array of colors.
class AnimatedShape {
	PVector originXY;
	PVector centerXY;
	PVector wanderedXY;
  float jitter_max_step_mult;
  float max_jitter_dist; float original_max_jitter_dist;
  float max_wander_dist; float original_max_wander_dist;
  float original_diameter;		// a separate thing we want to remember from current_diameter
	float diameter;
  float diameter_min;
	float original_diameter_min;
  float diameter_max;
	float original_diameter_max;
  float diameter_morph_rate; float original_diameter_morph_rate;
  color stroke_color;
	color alt_stroke_color;
  int stroke_color_palette_idx;
  float stroke_weight;
	boolean use_dark_color_fill;
  color fill_color;
	color alt_fill_color;
  int fill_color_palette_idx;
  int milliseconds_elapse_to_color_morph;
  int milliseconds_at_last_color_change_elapsed;
  boolean color_morph_on;
	int ms_color_morph_active;
  float motion_vector_max; float original_motion_vector_max;
  PVector additionVector;
	PVector orbitVector;		// Wanted because additionVector randomizes periodically but I want constant orbit.
	float orbit_radians_rate;
	float rotation = 0;		// tracked separate from PShapes which have this internal, bcse can recreate PShape and want same rot.
	float rotate_radians_rate;
  //FOR NGON:
  int sides;
	int minNgonSides = 3;			// quasi-global (can only set here in class declaration); no nGon can have less sides than this.
	int maxNgonSides = 7;			// " no nGon can have more sides than this.
  PShape nGon;
  PVector radiusVector;    // used to construct the nGon
  // The following is used to scale all animation variables vs. an original animation size/speed tuning reference grid.
  // See comments for motionVectorScaleBaseReference. Because the shapes vary in size as the program runs, if animation
  // increments are constant, things move relatively "faster" when shapes are smaller. This multiplier throttles those
  // values up or down so that animation has the same relative distances/speeds as shapes grow/shrink. See how this is
  // initialized in the constructor..
  float animation_scale_multiplier;
  int change_mode_if_ms_elapsed;
  int ms_at_last_mode_change;

  // class constructor--sets random diameter and morph speed values from passed parameters;
  // IF nGonSides is 0, we'll know it's intended to be a circle:
  AnimatedShape(int xCenter, int yCenter, float diameterMin, float diameterMax, int sidesArg, boolean darkColorFillArg) {
    originXY = new PVector(xCenter,yCenter);
    centerXY = new PVector(xCenter,yCenter);
		wanderedXY = new PVector(0,0);
    diameter_min = diameterMin; original_diameter_min = diameter_min;
		diameter_max = diameterMax; original_diameter_max = diameter_max;
    diameter = random(diameterMin, diameterMax);
		original_diameter = diameter;
    //randomly make that percent positive or negative to start (which will cause grow or expand animation if used as intended) :
    int RNDtrueFalse = (int) random(0, 2);  // gets random 0 or 1
    if (RNDtrueFalse == 1) {
      diameter_morph_rate *= (-1);
    }  // flips it to negative if RNDtrueFalse is 1
    jitter_max_step_mult = random(0.007, 0.0097);  // 0.005 amounts to nothing visible.
    max_jitter_dist = diameter * jitter_max_step_mult;
		original_max_jitter_dist = max_jitter_dist;
    max_wander_dist = diameter * parentMaxWanderDistMultiple;		// Only for outer circle (or shape) of nested circle (or shape).
		original_max_wander_dist = max_wander_dist;
    // set RND stroke and fill colors and stroke weight;
		// stroke RND from all fill colors:
    int RNDarrayIndex = (int) random(allFillColorsArrayLength);  // use all fill colors for stroke
    stroke_color = allFillColors[RNDarrayIndex]; alt_stroke_color = stroke_color;
    stroke_color_palette_idx = RNDarrayIndex;
    stroke_weight = random(diameter_max * strokeMinWeightMult, diameter_max * strokeMaxWeightMult);   // have tried as high as 0.042 tweaked up from v.1.3.6 size: 0.028
		use_dark_color_fill = darkColorFillArg;
		if (use_dark_color_fill == true) {
			RNDarrayIndex = (int) random(darkFillColorsArrayLength);
			fill_color = darkFillColors[RNDarrayIndex]; alt_fill_color = fill_color;
		} else {
			RNDarrayIndex = (int) random(lightFillColorsArrayLength);
			fill_color = lightFillColors[RNDarrayIndex]; alt_fill_color = fill_color;
		}
    fill_color_palette_idx = RNDarrayIndex;
    //TO DO? : control the folling rnd range with parameters?
    milliseconds_elapse_to_color_morph = (int) random(42, 111);    // on more powerful hardware, 194 is effectively true with no throttling of this.
    milliseconds_at_last_color_change_elapsed = millis();
    color_morph_on = false;
    animation_scale_multiplier = diameter / motionVectorScaleBaseReference; // print("animation_scale_multiplier: " + animation_scale_multiplier + "\n");
		original_motion_vector_max = motionVectorMax;
    motion_vector_max = motionVectorMax * animation_scale_multiplier;    // assigning from global there, then modifying further for local size/speed scale (animation_scale_multiplier)
		diameter_morph_rate = random(diameterMorphRateMin, diameterMorphRateMax) * animation_scale_multiplier;		// also * animation_scale_multiplier because it's anim
		original_diameter_morph_rate = diameter_morph_rate;
		jitter_max_step_mult = jitter_max_step_mult / animation_scale_multiplier;
    additionVector = getRandomVector();
		orbitVector = getRandomVector();
		orbit_radians_rate = random(orbitRadiansRateMax * -1, orbitRadiansRateMax);
		rotate_radians_rate = random(rotationRadiansRateMax * -1, rotationRadiansRateMax);
		// sides assignment taken care of in constructShape():
    change_mode_if_ms_elapsed = 438;
    ms_at_last_mode_change = millis();
		constructShape(sidesArg);
  }

	void scaleDiameterBounds(float multiplier) {
		diameter = original_diameter * multiplier;
		diameter_min = original_diameter_min * multiplier;
		diameter_max = original_diameter_max * multiplier;
	}

	// Build or rebuild nGon as PShape via number of sides:
	void constructShape(int sidesArg) {
		// FOR NGON: conditionally alter number of sides:
		if (sidesArg < minNgonSides) { sidesArg = minNgonSides - 1; }		// force sphere if below min
		if (sidesArg > maxNgonSides) { sidesArg = maxNgonSides; }
		// if sidesArg is negative number, don't worry about changing it--it will be interpreted as a circle. Unless I change that? :
		sides = sidesArg;
		if (sides < 3) { scaleDiameterBounds(1); }
		// scale up shapes with less area, VIA CONSTANTS I found that approximate same area as circle if multiply apothem by:
		if (sides == 3) { scaleDiameterBounds(1.209199); }
		if (sides == 4) {	scaleDiameterBounds(1.110720); }
		if (sides == 5) {	scaleDiameterBounds(1.068959); }
		if (sides == 6) {	scaleDiameterBounds(1.047197); }
		if (sides == 7) {	scaleDiameterBounds(1.034376); }
		
		// if at least at minimum nGon sides, build polygon:
		if (sides >= minNgonSides) {
			radiusVector = new PVector(0, (diameter / 2 * (-1)) );    // This init vector allows us to construct an n-gon with the first vertex at the top of a conceptual construction circle
			nGon = createShape();
			nGon.beginShape();
			float angle_step = 360.0 / sides;
			for (int i = 0; i < sides; i ++) {
				nGon.vertex(radiusVector.x, radiusVector.y);
				radiusVector.rotate(radians(angle_step));
			}
			nGon.endShape(CLOSE);
			PVector zero_index_loc = nGon.getVertex(0);
			PVector one_index_loc = nGon.getVertex(1);
					// DEV TESTING: find+print area of polygon (PShape) AND MULTIPLIER to make any nGon < 8 sides same area as circle.
					// AREA OF POLYGON = 1/2 x perimeter x apothem
					// float nGonEdgeDistance = dist(zero_index_loc.x, zero_index_loc.y, one_index_loc.x, one_index_loc.y);
					// float nGonPerimeter = nGonEdgeDistance * sides;
					// float apothem = diameter / 2;
					// float nGon_area = 0.5 * nGonPerimeter * apothem;	// 1/2 x perimeter x apothem (or "radius");
					// float circle_mode_area = PI * apothem * apothem;		// apothem here is AKTULLY RLLY radius in circle mode
					// 	print("~ apothem:" + apothem + " sides:" + sides + " perimeter:" + nGonPerimeter + " ");
					// 	print("nGon area:" + nGon_area + " circle mode area:" + circle_mode_area + " ");
					// float nGon_to_circle_multiplier = circle_mode_area / nGon_area;
					// 	print("(circle mode area / nGon area) : " + nGon_to_circle_multiplier + "\n");
					// float scaled_nGon = (0.5 * nGonPerimeter * apothem * nGon_to_circle_multiplier);
					// 	print("->area of nGon if apothem is multiplied up by that: " + scaled_nGon + "\n");
			// turns n-gons with one side that isn't parallel with horizontal so they are:
			int two_division_remainder = sides % 2;
			if (two_division_remainder == 0) {
				nGon.rotate(radians(angle_step / 2));
				// rotation += (angle_step / 2);
			}
			nGon.rotate(radians(rotation));
		}	else {		// otherwise build a circle:
			nGon = createShape(ELLIPSE,0,0,diameter,diameter);
		}
	}

  // member functions
  void morphDiameter() {
    // grow diameter (positive or negative) :
		float old_diameter = diameter;  // for later reference in scaling nGon
    float tmp = diameter / old_diameter;
    diameter = diameter + (diameter * diameter_morph_rate);
		diameter = constrain(diameter, diameter_min, diameter_max);
    // if diameter is at min or max, alter the grow rate to positive or negative (depending):
    if (diameter == diameter_max) {
			diameter_morph_rate *= (-1);
			// print("\n\n~~shrinking . .\n");
		}
    if (diameter == diameter_min) {
			diameter_morph_rate *= (-1);
			// print("\n\n~~growing . . .\n");
		}

		float percent_change_multiplier = diameter / old_diameter;
    nGon.scale(percent_change_multiplier);
  }

  void jitter() {
    max_jitter_dist = diameter * jitter_max_step_mult;
    // SETUP x AND y ADDITION (positive or negative) of morph coordinate:
    wanderedXY.x = ((int) random(max_jitter_dist * (-1), max_jitter_dist));
    wanderedXY.y = ((int) random(max_jitter_dist * (-1), max_jitter_dist));
    // I think this will accompish this? :
    centerXY.add(wanderedXY);
  }

// Java (Processing) always passes by value (makes a copy of a paremeter
// passed to a function), so we just create and get new things with this function
// (as it won't work directly on the values of anything we decided to pass
// to the function if we coded it that way, which would mean copying twice == less efficient) :
  PVector getRandomVector() {
    float vector_x = random(motion_vector_max * -1, motion_vector_max + 0.001);    // using a global variable
    float vector_y = random(motion_vector_max * -1, motion_vector_max + 0.001);
    PVector RNDvector = new PVector(vector_x, vector_y);
    // if a.x and a.y are both 0, that means no motion--which we don't want; so:
    // randomize again--by calling this function itself--meta! :
    while (RNDvector.x == 0 && RNDvector.y == 0) {
      RNDvector = getRandomVector();
    }
    return RNDvector;
  }

  PVector wander(PVector parent_shape_XY, float parent_shape_diameter) {
    PVector vector_to_return = new PVector(0,0);    // will be northing unless changed
    // updating variable within the object this function is a part of:
    centerXY.add(additionVector);
    // check if we just made the shape go outside its parent, and if so undo that translate:
    boolean is_shape_within_parent = is_shape_within_shape(parent_shape_XY, parent_shape_diameter, centerXY, diameter);
    if (is_shape_within_parent == true) {
      vector_to_return = additionVector.copy();		// NOT by reference, by COPY--dunno if it makes difference here though :/
    } else {    // undo that translate, and change wander direction:
      centerXY.sub(additionVector);
//NOTE: if the following allows angles too near 90, collissions happen before they happen, and freaky atomic jitter results:
      float rotation_angle = random(130, 230);
      additionVector.rotate(radians(rotation_angle));
    }
    return vector_to_return;
  }

	void orbit() {
	additionVector.rotate(radians(orbit_radians_rate));
	}

	void rotateShape() {
    if (sides >= minNgonSides) {
      nGon.rotate(radians(rotate_radians_rate));
			rotation += rotate_radians_rate;
			// keeps rotation < 360 yet still true to angle; math magic! :
			rotation = rotation % 360.0;
    }
	}

  void morphColor() {
		// variable names reference:
		// int darkFillColorsArrayLength = darkFillColors.length;
		// int lightFillColorsArrayLength = lightFillColors.length;
		// int allFillColorsArrayLength = allFillColors.length;
    int localMillis = millis();
    if ((localMillis - milliseconds_at_last_color_change_elapsed) > milliseconds_elapse_to_color_morph && color_morph_on == true) {
// KLUDGE try statements all over heck and gone :(
			stroke_color_palette_idx += 1;		// reset that if it went out of bounds of array indices:
			if (stroke_color_palette_idx >= allFillColorsArrayLength) {
				stroke_color_palette_idx = 0;
			}    
				try {	stroke_color = allFillColors[stroke_color_palette_idx]; }
				catch (Exception e) {
					//print("WARNING: attempted to change stroke color with null value.\n");
				}
			// morph dark or light color fill index and color, depending on whether shape in dark or light mode:
			fill_color_palette_idx += 1;
			if (use_dark_color_fill == true) {
				// reset that if it went out of bounds:
				if (fill_color_palette_idx >= darkFillColorsArrayLength) {
					fill_color_palette_idx = 0;
				}
					try {	fill_color = darkFillColors[fill_color_palette_idx]; }
					catch (Exception e) {
						//print("WARNING: attempted to change (dark) fill color with null value.\n");
					}
			} else {		// light mode, so adjust idx / color for light palette:
				if (fill_color_palette_idx >= lightFillColorsArrayLength) {
					fill_color_palette_idx = 0;
				}
					try {	fill_color = lightFillColors[fill_color_palette_idx]; }
					catch (Exception e) {
						//print("WARNING: attempted to change (light) fill color with null value.\n");
					}
			}
	    milliseconds_at_last_color_change_elapsed = millis();
    }
  }
	
	// returns 1 if error, 0 if no error.
	int updateColor() {
		try {
			stroke_color = allFillColors[stroke_color_palette_idx];
			if (use_dark_color_fill == true) {		// if dark mode, fill with dark color:
				fill_color = darkFillColors[fill_color_palette_idx];
			} else {		// if light mode, fill with light color:
// Also, stack overflow exception here :( if I recursively call updateColor().
				fill_color = lightFillColors[fill_color_palette_idx];
			}
	    milliseconds_at_last_color_change_elapsed = millis();
			return 0;
		} catch (Exception e) {
	    //print("WARNING: Attempted to update color while value null.\n");
			return 1;
		}
  }

  void drawShape() {
		// NOTE: it's a weird semantic, but this function always uses alt_fill_color.
		// fill_color is then simply a backup of a preferred color . . . which may not be preferred.
				// OPTIONAL STROKE AND FILL color overrides!
				if (colorMode == 3) {
					alt_fill_color = altFillColor;		// the latter taken from a global
					alt_stroke_color = altStrokeColor;		// the latter taken from a global
				} else {
					alt_fill_color = fill_color;
					alt_stroke_color = stroke_color;
				}
				// END OPTIONAL STROKE AND FILL color overrides!
		nGon.setFill(alt_fill_color);
		nGon.setStroke(alt_stroke_color);
		if (sides >= minNgonSides) {    // as manipulated by constructShape(), this will mean an nGon, so render that:
			nGon.setStrokeWeight(stroke_weight * 1.3);    // * because it just seems to be better as heavier for nGons than circles.
		} else {
			nGon.setStrokeWeight(stroke_weight);
		}
// LEARNED: it displays them YUGE if I also pass diameter, diameter because that means _that much past existing size_ (which is already ~same as if circle)
      shape(nGon, centerXY.x, centerXY.y);
  }

  void translate(PVector addArg) {
    centerXY.add(addArg);
  }

  void udpate_animation_scale_multiplier() {
    animation_scale_multiplier = diameter / motionVectorScaleBaseReference;
    motion_vector_max = original_motion_vector_max * animation_scale_multiplier;
		diameter_morph_rate = original_diameter_morph_rate * animation_scale_multiplier;
		max_jitter_dist = original_max_jitter_dist * animation_scale_multiplier;
  }
	
	void change_mode(int eventType) {		// interaction event type 1 is click, 2 is drag
		// The succession of changes I want is:
		// - first interaction: activate color morph if it is off.
		// - subsequent interactions: add 1 side (if circle, go "down" to triangle),
		// unless at max number of sides, then go back to circle.
		// so: 
		// if color morph off, activate it. otherwise, add a side but cycle back to circle if needed.
    // ALSO, only if time diff since ms_at_last_mode_change and current time > a period,
		// ALSO, only depending on other things I won't explain having to do with click or drag.
		int diff = millis() - ms_at_last_mode_change; ms_at_last_mode_change = millis();
		if (diff > change_mode_if_ms_elapsed || eventType == 1) {
			if (color_morph_on == false) {
				color_morph_on = true;
				ms_color_morph_active = millis();
			} else {
				sides += 1;		// try += 1 or -= 1.
				// BUT:
				if (sides > maxNgonSides) {
					sides = minNgonSides - 1;			// minNgonSides - 1 is a circle
				}	else {
					if (sides < minNgonSides - 1) { sides = maxNgonSides; }		// in case I hack += 1 to -= 1
				}

				constructShape(sides);
			}
		}
	}
	
	void disable_color_morph_if_time() {
		int current_millis = millis();
		int diff = current_millis - ms_color_morph_active;
		if (diff > disableColorMorphAfter_ms) { color_morph_on = false; }		// compare to a global val.
	}

}


class NestedAnimatedShapes {
  int nesting;
  AnimatedShape[] AnimatedShapesArray;
// TO DO: declare and init as PShape with children (for svg grouping on svg save) :
  // PShape nestedShapes;

  // class constructor: same as for AnimatedShape but adding int nesting to start of list:
  NestedAnimatedShapes(int xCenterArg, int yCenterArg, float RND_min_diameter_mult, float RND_max_diameter_mult, int nGonSides, int nestingArg) {

    nesting = nestingArg;
    AnimatedShapesArray = new AnimatedShape[nesting];
    // float donwMultiplyConstantMin = 0.67; float downMultiplyConstantMax = 0.92;		// vestigal from experiment
    // float percentOfMinDiameterToMax = RND_min_diameter_mult / RND_max_diameter_mult;		// vestigal "


    // PRE-DETERMINE diameter/apothem ("diameter" / 2) sizes for an array of animated shapes.
    // Then pass them as max and min radius for each shape as we build the array of shapes.
    // METHOD: get a fixed number of random numbers from a range divided by an interval, descending.
    // (for nested circle diameters or nested shape apothems)
    int interval = nesting + 9;    // divide min and max possible radius by how many intervals to determine size slices?
    float dividend = (RND_max_diameter_mult - RND_min_diameter_mult) / interval;
    int radii_to_get = nesting + 1;   // or the last circle/shape will have no min. radius!
    int low_range_excluder = radii_to_get;
    int selected = interval;    // a lie to start with but starts the loop as we wish
    float[] radii = new float[radii_to_get];
    for (int i = 0; i < radii_to_get; i++) {
               //print("sel. range: " + low_range_excluder + ":" + selected + " ");
      int selected_num = (int) random(low_range_excluder, selected + 1);
      float result_num = RND_min_diameter_mult + (selected_num * dividend);
      radii[i] = result_num;
      selected = selected_num - 1;
      low_range_excluder -= 1;
    }
    // END PRE-DETERMINE diameter/apothem sizes.
		// randomly choose true or false for dark color fill (will be used for outermost shape),
		// and toggle it to opposite in each iteration of loop (to alternate light/dark fill) :
		boolean darkColorFillArg = random(1) > .5;    // I thank a genius breath: https://forum.processing.org/two/discussion/1433/random-boolean-howto
    				// print("chose " + darkColorFillArg + "\n");
// TO DO: get this working? Couldna first tries:
		// float new_RND_rotate_origin_for_nesting = random(0.0, 361.0);
    for (int i = 0; i < nesting; i++) {
			// print(radii[i+1] + ":" + radii[i] + "\n");
			//print("darkColorFillArg for " + i + " is " + darkColorFillArg + "\n");
      AnimatedShapesArray[i] = new AnimatedShape(
        xCenterArg,
        yCenterArg,
        radii[i+1],
        radii[i],
        nGonSides,
        darkColorFillArg
      );
						// BUT one out of five times, do _not_ toggle it, and continue with dark if dark or light if light:
						int five_sided_die_roll = (int) random(1, 6);		// 6 because not inclusive: max of range is 5
						if (five_sided_die_roll != 5) {
          		if (darkColorFillArg == false) { darkColorFillArg = true; } else { darkColorFillArg = false; }
																					}
		// override orbitVector, rotation rate, and starting rotation of all nested shapes to match outermost
		// (lockstep / make visually similar them all)
		// NOTE that the following assigns by reference, which is fine, it saves memory and does what we want:
		AnimatedShapesArray[i].orbitVector = AnimatedShapesArray[0].orbitVector;
		AnimatedShapesArray[i].rotate_radians_rate = AnimatedShapesArray[0].rotate_radians_rate;
		// Also "unrotate" them from whatever their original random rotation was, then reset rnd rotation and
		// rotation to here-determined value:
		// float unrotate_degrees = (AnimatedShapesArray[i].rotation * -1); print("unrotation: " + unrotate_degrees + "\n");
		// AnimatedShapesArray[i].nGon.rotate(unrotate_degrees);
		// AnimatedShapesArray[i].rotation = new_RND_rotate_origin_for_nesting;
		// AnimatedShapesArray[i].nGon.rotate(radians(new_RND_rotate_origin_for_nesting));
    }
  }

	void drawAndChangeNestedShapes() {
    for (int j = 0; j < nesting; j++) {
      AnimatedShapesArray[j].drawShape();
      AnimatedShapesArray[j].morphDiameter();
      AnimatedShapesArray[j].udpate_animation_scale_multiplier();
			AnimatedShapesArray[j].orbit();
			AnimatedShapesArray[j].rotateShape();
      // AnimatedShapesArray[j].jitter();    // so dang silky smooth without jitter; also maybe edge collisions are now less spastic _without_ that (the opposite case used to be).
///*
        // START WANDERING
        for (int k = j + 1; k < nesting; k++) {
          PVector tmp_vec;
          // if we're at the outmost shape or circle, pass made-up PVector and diameter by extrapolation from max_distance;
          // otherwise pass those properties of the parent shape:
          if (j == 0) {     // wander under these conditions:
            PVector INVISIBL_PARENT_XY = AnimatedShapesArray[0].originXY.copy();
            float INVISIBL_RADIUS = AnimatedShapesArray[0].max_wander_dist;
            tmp_vec = AnimatedShapesArray[0].wander(INVISIBL_PARENT_XY, INVISIBL_RADIUS);
          } else {          // or under these conditions (one or the other) :
            PVector parent_center_XY = AnimatedShapesArray[j].centerXY.copy();
            tmp_vec = AnimatedShapesArray[k].wander(parent_center_XY, AnimatedShapesArray[j].diameter);
          }
          // drag all inner circles/shapes with outer translated circle/shape, using that gotten vector;
          // this won't always actually move anything (as sometimes tmp_vec is (0,0), but it's a waste to check if it will:
          AnimatedShapesArray[k].translate(tmp_vec);
          // DONE WANDERING
				// CONSTRAINING inner shapes within borders of outer ones
				// if shape has wandered beyond border of parent, drag it within parent, tangent on nearest edge;
				// ONLY EVERY N milliseconds, as controlled by functions that set detect_collision_now true;
				// UNLESS lazyParentBoundaryConstraint is false (always do this in that case) :
				if (detect_collision_now == true && lazyParentBoundaryConstraint == true || lazyParentBoundaryConstraint == false) {
					boolean is_within_parent = is_shape_within_shape(
					AnimatedShapesArray[j].centerXY,
					AnimatedShapesArray[j].diameter,
					AnimatedShapesArray[k].centerXY,
					AnimatedShapesArray[k].diameter);
					if (is_within_parent == false) {      // CONSTRAIN it:
								// print(is_within_parent + "\n");
						PVector relocate_XY = get_larger_to_smaller_shape_interior_tangent_PVector(
						AnimatedShapesArray[j].centerXY,
						AnimatedShapesArray[j].diameter,
						AnimatedShapesArray[k].centerXY,
						AnimatedShapesArray[k].diameter
						);
								// print(relocate_XY + "\n");
						AnimatedShapesArray[k].centerXY = relocate_XY.copy();		// could probably get away with reference here? Eh.
					}
				}
				  // DONE CONSTRAINING
        }
				// END WANDERING
//*/
      // COLOR MORPHING makes it freaking DAZZLING, if I may say so:
      AnimatedShapesArray[j].morphColor();
			AnimatedShapesArray[j].disable_color_morph_if_time();	// But let's stop it after an interval. Interaction will restart it.
    }
  }

	void updateNestedShapesColors() {
		 // 1 means error; so default here is keep trying until there's NOT an error:
		 int error_code = 1;
		 for (int j = 0; j < nesting; j++) {
			 error_code = AnimatedShapesArray[j].updateColor();
		 }
	}

}


// class that contains information for a grid of shapes.
class GridOfNestedAnimatedShapes {
  int graph_xy_len;
  int cols;
  int rows;
  NestedAnimatedShapes ShapesGridOBJ[][];
  int grid_to_canvas_x_offset;
  int grid_to_canvas_y_offset;

  // class constructor
  GridOfNestedAnimatedShapes(int canvasXpx, int canvasYpx, int passedColumns, float RND_min_diameter_multArg, float RND_max_diameter_multArg, int nestingArg) {
    graph_xy_len = canvasXpx / passedColumns;   // it seems this discards any remainder if it divides unevenly.
    cols = passedColumns;
    rows = canvasYpx/graph_xy_len;
    //information and a standard (to Processing) function call that will center the grid on the canvas:
    int canvasToGridXremainder = canvasXpx - (cols * graph_xy_len);   // gets us the earlier discarded remainder
    grid_to_canvas_x_offset = canvasToGridXremainder / 2;
    int canvasToGridYremainder = canvasYpx - (rows * graph_xy_len);
    grid_to_canvas_y_offset = canvasToGridYremainder / 2;
    ShapesGridOBJ = new NestedAnimatedShapes[rows][cols];
							// START CONTROL of sides of shapes in grids
							// draw a number between 1 and 4. if 4, make number of sides of every shape in grid random.
							// Otherwise, randomly choose N sides between minimumNgonSides and maximumNgonSides, and
							// make every shape in grid have that many sides. BUT alter the chances of choosing how many
							// sides there: if the minimum sides is set below -2, bring it up to -2 in a temp,
							// altered copy of minimumNgonSides which is used instead of minimumNgonSides.
							boolean do_rnd_sides_every_shape = false;
							int rndShapeSides = 0;		// declared here for scope, value change decisions will be made on this
							// int rndShapeSides = minimumNgonSides;    // need to declare here for scope--may override
              // int kludge_minRange = minimumNgonSides;  // also
							int kludge_minimumNgonSides;
							int dice = (int) random(1, 5);
							if (dice == 4) {
								do_rnd_sides_every_shape = true;
							} else {
								if (minimumNgonSides < 0) { kludge_minimumNgonSides = 0; } else { kludge_minimumNgonSides = minimumNgonSides; }
								rndShapeSides = (int) random(kludge_minimumNgonSides, maximumNgonSides + 1);
							}
							// END CONTROL of sides of shapes in grids
    for (int i = 0; i < ShapesGridOBJ.length; i++) {          // that comparison measures first dimension of array ( == cols)
      for (int j = 0; j < ShapesGridOBJ[0].length; j++) {    // that comparision measures second dimension of array ( == rows)
        // OY the convolution of additional offests just to make a grid centered! :
        int shapeLocX = ((graph_xy_len * j) - (int) graph_xy_len / 2) + grid_to_canvas_x_offset + graph_xy_len;
        int shapeLocY = ((graph_xy_len * i) - (int) graph_xy_len / 2) + grid_to_canvas_y_offset + graph_xy_len;
							// ALTER CONTROL of sides of shapes if boolean says so:
							if (do_rnd_sides_every_shape == true) {
								// low range 1 or 2 still does circles more often, but not so many as if minimumNgonSides is neg.
								rndShapeSides = (int) random(minimumNgonSides, maximumNgonSides + 1);
							} // else do nothing; rndShapeSides as set before this nested i/j for loop will be used.
        float minDiam = graph_xy_len * RND_min_diameter_multArg;
        float maxDiam = graph_xy_len * RND_max_diameter_multArg;
        ShapesGridOBJ[i][j] = new NestedAnimatedShapes(shapeLocX, shapeLocY, minDiam, maxDiam, rndShapeSides, nestingArg);    // I might best like: 1, 8
      }
    }
  }

  void ShapesGridDrawAndChange() {
    //int counter = 0;    // uncomment code that uses this to print a number count of shapes in the center of each shape.
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        fill(255);
        //stroke(255,0,255);
                // print("~~\n");
        ShapesGridOBJ[i][j].drawAndChangeNestedShapes();
        fill(0);
        //counter += 1;
        // debug numbering print of shapes:
        //text(counter, ((graph_xy_len * j) - (int) graph_xy_len / 2) + graph_xy_len, ((graph_xy_len * i) - graph_xy_len / 2) + graph_xy_len);
      }
    }
  }

  void ShapesGridUpdateColors() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        ShapesGridOBJ[i][j].updateNestedShapesColors();
      }
    }
  }

}
// END CLASSES


// BEGIN MAIN FUNCTIONS
void settings() {
  // SEE these controlling variables in the global variables section near start of script:
  if (USE_FULLSCREEN == true) {
    fullScreen();
  } else {
    size(globalWidth, globalHeight);
  }

	// If loadColorsFromHexplts is true, the following creates dynamically loaded color
	// palettes to use! :
	if (loadColorsFromHexplts == true) {
			print("Palettes loaded from files available for use.\n");
			backgroundColors = loadColorsToArray("backgroundColors.hexplt");
			darkFillColors = loadColorsToArray("darks.hexplt");
			lightFillColors = loadColorsToArray("lights.hexplt");
			allFillColors = loadColorsToArray("colorLoop.hexplt");
		} else {		// If we got "tails" (0) from that virtual coin toss:
			print("External palettes will not be loaded; will use hard-coded palettes.\n");
			backgroundColors = backgroundColors_HC.clone();
			darkFillColors = darkFillColors_HC.clone();
			lightFillColors = lightFillColors_HC.clone();
			allFillColors = allFillColors_HC.clone();
		}
	backgroundColorsArrayLength = backgroundColors.length;
	darkFillColorsArrayLength = darkFillColors.length;
	lightFillColorsArrayLength = lightFillColors.length;
	allFillColorsArrayLength = allFillColors.length;

  // initializes runSetupAtMilliseconds before draw() is called:
  setDelayToNextVariant();
  
  // FOR TWITTER API auth; load from local file; throw warning if try fails (instead of crashing);
  // also set "don't even try to tweet" boolean to true on failure.
  // This will only fail here if file not found or if there's an error during loading it.
  try {
    twitterAPIauthLines = loadStrings("../twitterAPIauth.txt");
		if (twitterAPIauthLines.length != 4) { tryToTweet = false; }	// because the expected format is 4 lines; encrytped, it isn't.
    //simpletweet = new SimpleTweet(this);
    //simpletweet.setOAuthConsumerKey(twitterAPIauthLines[0]);
    //simpletweet.setOAuthConsumerSecret(twitterAPIauthLines[1]);
    //simpletweet.setOAuthAccessToken(twitterAPIauthLines[2]);
    //simpletweet.setOAuthAccessTokenSecret(twitterAPIauthLines[3]);
  } catch (Exception e) {
    tryToTweet = false;
    print("NO TEXT FILE twitterAPIauth.txt found.\n");
  }
}


boolean runSetup = false;                      // Controls when to run prepareNextVariation() again. Manipulated by script logic.
boolean savePNGnow = false;                    // Controls when to save PNGs. Manipulated by script logic.
boolean recordSVGnow = false;                  // Controls when to save SVGs. Manipulated by script logic.
boolean userInteractedThisVariation = false;   // affects those booleans via script logic.
String animFramesSaveSubdir = "";


// handles values etc. for new animated variation to be displayed:
void prepareNextVariation() {
  if (booleanOverrideSeed == true) {
    seed = previousSeed;
    booleanOverrideSeed = false;
  } else {
    previousSeed = seed;
    seed = (int) random(-2147483648, 2147483647);
  }
  randomSeed(seed);
  ellipseMode(CENTER);

	if (loadColorsFromHexplts == true && rndSwapPalettes == true) {
		int rnd_tmp_num = int(random(0, 2));	// non-inclusive (returns one less than highest num)
		if (rnd_tmp_num == 1) {		// If we got "heads" (1) from that virtual coin toss:
				// print("Randomly using palettes that were imported at program launch.\n");
			backgroundColors = loadColorsToArray("backgroundColors.hexplt");
			darkFillColors = loadColorsToArray("darks.hexplt");
			lightFillColors = loadColorsToArray("lights.hexplt");
			allFillColors = loadColorsToArray("colorLoop.hexplt");
		} else {		// If we got "tails" (0) from that virtual coin toss:
				// print("Randomly using hard-coded palettes.\n");
			backgroundColors = backgroundColors_HC.clone();
			darkFillColors = darkFillColors_HC.clone();
			lightFillColors = lightFillColors_HC.clone();
			allFillColors = allFillColors_HC.clone();
		}
	} else {		// How can I compress this logic?
			// print("Boolean settings determine to always use imported palettes; will do.\n");
		backgroundColors = loadColorsToArray("backgroundColors.hexplt");
		darkFillColors = loadColorsToArray("darks.hexplt");
		lightFillColors = loadColorsToArray("lights.hexplt");
		allFillColors = loadColorsToArray("colorLoop.hexplt");
	}
	backgroundColorsArrayLength = backgroundColors.length;
	darkFillColorsArrayLength = darkFillColors.length;
	lightFillColorsArrayLength = lightFillColors.length;
	allFillColorsArrayLength = allFillColors.length;

  // Randomly change the background color to any color from backgroundColors array at each run;
	RNDbgColorIDX = (int) random(backgroundColorsArrayLength);
	globalBackgroundColor = backgroundColors[RNDbgColorIDX];

	backupCurrentColors();

	// Necessary for if we are in another mode when this function is called; also note
	// this backs up the color mode for reference of this if -> switch block:
	int previousColorMode = colorMode;
	colorMode = 1;
	// If a boolean is set to maintain a certain mode between variations, do so:
	if (keepColorModeOnVariantChange == true && previousColorMode != 1) {
		// print("Will try to change from color mode back to previous, other mode.\n");
		switch(previousColorMode)
		{
			case 2:	// if grayscale, reset to grayscale (all the above provided colors set
				// up for that adjustment:
				enableGrayscaleMode();
				break;
			case 3:	// if color override mode, reset to that mode (after
				// all the above set it to color):
				enableColorsOverrideMode();
				break;
		}
	}
	
  int gridXcount = (int) random(minColumns, maxColumns + 1);  // +1 because random doesn't include max range. Also, see comments where those values are set.

  GridOfShapes = new GridOfNestedAnimatedShapes(width, height, gridXcount, ShapesGridXminPercent, ShapesGridXmaxPercent, gridNesting);

  GridOfShapesNumCols = GridOfShapes.cols;
  GridOfShapesNumRows = GridOfShapes.rows;

  // for "frenetic option" :
  // for (int x = 0; x < gridNesting; x++) {
  //	nestedGridRenderOrder.append(x);
  //  print(x + "\n");
  //}

  userInteractionString = "";
  framesRenderedThisVariation = 0;  // reset here and incremented in every loop of draw()
  runSetup = false;
  savePNGnow = false;
  recordSVGnow = false;
  userInteractedThisVariation = false;
	// restore these to whatever was backed up when changed elsewhere
	// (even if "restore" is to the same) :
	saveAllFrames = initialSaveAllFramesState;
	saveSVGs = initialSaveSVGsState;
	
	// prep for subfolder names capturing every frame as SVG if script will do so:
	variationNumberThisRun += 1;
	String variationNumberThisRun_padded = nf(variationNumberThisRun, 6);
	String seedFolderNameCollisionAvoidance_extra_RND = get_random_string(5);
	// prep actual subfolder name:
	animFramesSaveSubdir = "_anims/"
	+ "BSaST_run_"
	+ formattedDateTime + "_"
	+ subdirRunNumberNameCollisionAvoidString + "/"
	+ variationNumberThisRun_padded +
	"__frames__seed_" + seed
	+ "_" + seedFolderNameCollisionAvoidance_extra_RND;
}

String formattedDateTime = "";
String subdirRunNumberNameCollisionAvoidString = "";
void setup() {
  // uncomment if u want to throttle framerate--RECOMMENDED or
  // a fast CPU will DO ALL THE THINGS TOO MANY TOO FAST and heat up--
  // also it will make for properly timed animations if you save all frames to PNGs or SVGs:
  frameRate(30);
	subdirRunNumberNameCollisionAvoidString = get_random_string(4);
	formattedDateTime = get_formatted_datetime();
	prepareNextVariation();
  thread("start_parent_shape_bound_constrain_timer");
	// to produce one static image, uncomment the next function:
	//noLoop();
}


// DOES ALL THE THINGS for one frame of animation:
void animate() {

  // SVG RECORD, CONDITIONALLY:
  if (recordSVGnow == true) {
    String svg_file_name_no_ext = get_detailed_image_file_name_no_ext();
    beginRecord(SVG, svg_file_name_no_ext + ".svg");
  }

// TO DO? refactor so this try/catch isn't necessary because globalBackgroundColor is never null:
	try {
  background(globalBackgroundColor);  // clears canvas to white before next animaton frame (so no overlap of smaller shapes this frame on larger from last frame) :
	} catch (Exception e) {}

  // randomizes list--for frenetic option (probably will never want) :
  //nestedGridRenderOrder.shuffle();
  //println(nestedGridRenderOrder);

  GridOfShapes.ShapesGridDrawAndChange();

  if (recordSVGnow == true) {
    endRecord();
    recordSVGnow = false;
  }

  totalFramesRendered += 1;
  framesRenderedThisVariation += 1;   // this is reset to 0 at every call of prepareNextVariation()

  // conditionally calculate and print running display of frames per second.
  if (estimateFPS == true) {
    int current_millis = millis();
    if (current_millis - last_captured_millis > 999) {
      estimatedFPS = totalFramesRendered - last_captured_totalFramesRendered;
      int countdown_to_next_render = runSetupAtMilliseconds - current_millis;
      print("Estimated frames per second: " + estimatedFPS + ". total frames rendered: " + totalFramesRendered + ". Next variation in " + countdown_to_next_render + "ms\n");
      //reset these values or this won't work:
      last_captured_millis = current_millis;
      last_captured_totalFramesRendered = totalFramesRendered;
    }
  }
}


int last_captured_millis = 0;
int last_captured_totalFramesRendered = 0;
void draw() {
  // SAVE SVG FRAME AS PART OF ANIMATION FRAMES conditioned on boolean:
// TO DO: remove && saveSVGs == true as part of condition? (saveAllAnimationFrames overrides?) :
  if (saveAllFrames == true && saveSVGs == true) { beginRecord(SVG, animFramesSaveSubdir + "/##########.svg"); }
  animate();
  if (saveAllFrames == true && saveSVGs == true) { endRecord(); }

  // SAVE PNG FRAME AS PART OF ANIMATION FRAMES conditioned on boolean:
  if (saveAllFrames == true && savePNGs == true) {
    saveFrame(animFramesSaveSubdir + "/##########.png");
// TEMP OR PERMANENT KLUDGE; NO:
//    if (totalFramesRendered == renderNtotalFrames) {
//      exit();
//    }
  }

  // NOTE: runSetupAtMilliseconds (on which this block depends) is initialized in settings() :
  currentTimeMilliseconds = millis();
  if (currentTimeMilliseconds >= runSetupAtMilliseconds) {
    // IF WE DON'T DO THE FOLLOWING, this block here is invoked immediately in the
    // next loop of draw() (which we don't want to happen) :
    setDelayToNextVariant();
    // this captures PNG if boolean controlling says do so, before next variant starts via prepareNextVariation() :
    if (saveEveryVariation == true && savePNGs == true || userInteractedThisVariation == true && savePNGs == true ) {
      save_PNG();
    }
    // captures SVG if booleans controlling says to:
    if (saveEveryVariation == true && saveSVGs == true || userInteractedThisVariation == true && saveSVGs == true ) {
      noLoop();
      recordSVGnow = true;
      animate();
      loop();
    }
		// tweets final frame of image if controlling boolean says so:
		if (userInteractedThisVariation == true) {
			try_to_tweet();
		}
    runSetup = true;
  }

  if (runSetup == true) {
    prepareNextVariation();
  }
}




// START Functions that alter color palettes used.
// backup palettes and background color:
void backupCurrentColors() {
	globalBackgroundColorBackup = globalBackgroundColor;
	bgColorsBAK = backgroundColors.clone();
	darkFillColorsBAK = darkFillColors.clone();
	lightFillColorsBAK = lightFillColors.clone();
	allFillColorsBAK = allFillColors.clone();
}

void restoreColors() {
	globalBackgroundColor = globalBackgroundColorBackup;
	backgroundColors = bgColorsBAK.clone();
	darkFillColors = darkFillColorsBAK.clone();
	lightFillColors = lightFillColorsBAK.clone();
	allFillColors = allFillColorsBAK.clone();
	GridOfShapes.ShapesGridUpdateColors();
}

// Creates and returns a grayscale palette from (a copy of) whatever palette you pass to it:
color[] getGrayscalePaletteCopy(color[] palette_to_copy) {
	int paletteLength = palette_to_copy.length;
	color[] grayscalePaletteDynamicCopy = new color[palette_to_copy.length];
	for (int i=0; i < paletteLength; i++) {
		color tmp_color = palette_to_copy[i];
		String tmp_str = hex(tmp_color);
		int R = unhex( tmp_str.substring(2,4) );
		int G = unhex( tmp_str.substring(4,6) );
		int B = unhex( tmp_str.substring(6,8) );
		int average = int((R + G + B) / 3);
		// print(R + "," + G + "," + B + "\n");
		// print("average: " + average + "\n");
		//averaged_gray = color(average);
		grayscalePaletteDynamicCopy[i] = color(average);
	}
	return grayscalePaletteDynamicCopy.clone();
}

void changeToNextColorMode() {
	switch(colorMode)
	{
		case 1:	// if color, enable grayscale:
			enableGrayscaleMode();
			break;
		case 2:	// if grayscale, enable color override:
			enableColorsOverrideMode();
			break;
		case 3:	// if color override, loop back to color:
			enableColorMode();
			break;
	}
}

void enableGrayscaleMode() {
	if (colorMode != 2) {
		colorMode = 2;
		// colors (including selected background color) are backed up in prepareNextVariation()
		// after they are instantiated (which happens before this function call is made--I hope?!--
		// unless somehow a user calls this funciton before that one completes?), so there'void setup() {
		// no need to do it here.
		// convert loaded palettes to grayscale and overwrite loaded palettes with that:
		// It's not necessary to get a grayscale copy of backgroundColors,
		// as no function cycles through background colors (it will be necessary to do that if
		// the program is changed thus), and all we need to do is update the already selected.
		// backgroundColors = getGrayscalePaletteCopy(backgroundColors);
		float R = red(globalBackgroundColor);
		float G = green(globalBackgroundColor);
		float B = blue(globalBackgroundColor);
		int average_gray_of_those = int( (R + G + B) / 3);
		globalBackgroundColor = average_gray_of_those;
		darkFillColors = getGrayscalePaletteCopy(darkFillColors);
		lightFillColors = getGrayscalePaletteCopy(lightFillColors);
		allFillColors = getGrayscalePaletteCopy(allFillColors);
		GridOfShapes.ShapesGridUpdateColors();
	}
}

void enableColorsOverrideMode() {
	if (colorMode != 3) {
		colorMode = 3;
		// globalBackgroundColorBackup = globalBackgroundColor;    // back up so we can restore when this mode toggled off
		globalBackgroundColor = altBackgroundColor;    // render users global bg is why
		// animate();
		// print("Color override mode enabled.\n");
	}
}

void enableColorMode() {
	if (colorMode != 1) {
		colorMode = 1;
		restoreColors();
		GridOfShapes.ShapesGridUpdateColors();
		// print("Standard color mode enabled.\n");
	}
}
// END Functions that alter color palettes used.


// This function can, via double-click, call functions that alter palettes used:
void mousePressed(MouseEvent evt) {

	//things that happen no matter what:
	addGracePeriodToNextVariant();
  userInteractionString = "__user_interacted";    // intended use by other functions / reset to "" by other functions

  if (userInteractedThisVariation == false) {    // restricts the functionality in this block to once per variation
    // (because prepareNextVariation(), which is called to create every variation, sets that false)
    //save PNG on click, conditionally:
		userInteractedThisVariation = true;

    if (savePNGs == true) {
      save_PNG();
    }
    // save SVG on click, conditionally:
    if (saveSVGs == true) {
      noLoop();
      recordSVGnow = true;
      animate();
      loop();
    }
		
		// NOTE THIS ALSO will execute only once per variation (per condition of outer control
		// of this block), which we want; if the following is set more than once per variation,
		// the "initial" saveAllFrames state becomes true even if it was false:
		if (saveAllFramesInteractOverride == true) {		// overrides that on user interact 'till end of variant.
			initialSaveAllFramesState = saveAllFrames; initialSaveSVGsState = saveSVGs;
			saveAllFrames = true; saveSVGs = true;
		}
		
		try_to_tweet();
  }
	
  if (evt.getCount() == 2) {
		changeToNextColorMode();
  }	else {		// if event was any kind of mouse press event besides double-click:
		change_mode_at_XY(mouseX, mouseY, 1);			// 1 means event type: click
	}
}


void mouseDragged() {
  change_mode_at_XY(mouseX, mouseY, 2);		// 2 means event type: drag
	addGracePeriodToNextVariant();
}


void keyPressed() {
  // if user presses left arrow key, go back to previous variant:
  if (keyCode == LEFT) {
    booleanOverrideSeed = true;
    runSetupAtMilliseconds = 0;
  }
  // if user presses right arrow key, skip this variant:
  if (keyCode == RIGHT) {
    // booleanOverrideSeed = false;
    runSetupAtMilliseconds = 0;
  }

  // Is there a more elegant way to do this where switches aren't available?
  // If I add more key responses above, I have to add them here:
  if (keyCode != LEFT && keyCode != RIGHT) {
    addGracePeriodToNextVariant();
  }
}

boolean try_to_tweet() {
	boolean tweet_success = false;		// half empty kinda guy?
	//TRY TO TWEET, if boolean that says we may is so set; will print exception + warning if fail:
	if (tryToTweet == true) {
		String simpleFileNameNoExt = get_simple_file_name_no_ext();
		try {
			
		// OPTION ONE--uncomment if this is what you want:
			// String tweet = simpletweet.tweetImage(get(), simpleFileNameNoExt + " saved via visitor interaction at Springville Museum of Art! More visitor images at: http://s.earthbound.io/BSaST #generative #generativeArt #processing #processingLanguage #creativeCoding"); println("Posted " + tweet);
		// OR:
		// OPTION TWO--uncomment if this is what you want:
			//String tweet = simpletweet.tweetImage(get(), simpleFileNameNoExt + " created during development or manual run of program. #generative #generativeArt #processing #processingLanguage #creativeCoding"); println("Posted " + tweet);
			tweet_success = true;
		} catch (Exception e) {
			print("Failure during tweet attempt. Attempting to log..\n");
			String date_time = get_formatted_datetime();
			String error_log_string = "Error on attempt to tweet at " + date_time + " seed " + seed;
			appendTextToFile(tweetErrorLogOutfileName, error_log_string);
			tweet_success = false;
		}
	} else {
		print("Could have tweeted, but told not to.\n");
		tweet_success = false;
	}
	return tweet_success;
}
