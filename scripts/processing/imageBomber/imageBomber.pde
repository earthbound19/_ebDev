// DESCRIPTION
// Supply images which are all the same dimensions in a subfolder (see USAGE), and this Image Bomber Processing script will randomly position, rotate, and scale them, one after another, as rapidly as you instruct it to, into a new image. Definition sets of images to bomb may be configured in layers. It will optionally save animation images of the process, or interactively save any still which you tell it to, and more. See USAGE.

// NO COPYRIGHT
// This is my original code and I dedicate it to the Public Domain. 2026-02-06 Richard Alexander Hall

// USAGE
// - NOTE that no images are provided with this script "shipped." You must provide a subfolder of images, and set the variable instructing the script what that folder name is, in the global variable. Examine comments provided in the "GLOBAL VARIABLES WHICH YOU MAY ALTER" section for instructions.
// - Examine other comments in that same comment section for instructions on all the global variables which you may alter for your preferences, including by defining global preferences and/or a grid in a JSON configuration file.
// - On run of script, you may:
//  - press the space bar or a mouse button to save a still of what is displayed. The still is named like this: _rnd_images_processing_v1-0-0__anim_run__seed_1409989632_fr_0000000315.png. You might think that file name has too much information. It doesn't. It is all the information required to reproduce exactly the same image again should you want to (provided the same script version, seed, and source image set).
//  - click the canvas or press the spacebar to save the current display to an image
//  - type the letter 'p'(ause) to pause or resume rendering of elements in the grid
//  - type the letter 'v'(ariant) to stop rendering the current variant and start a new one
// See comments in the modifiable GLOBAL VARIANTS area to learn what else this script can do.


// CODE
// TO DO:
// - optional random palette retrieval and recoloring of colorizable source rasters (or SVGs??)
// - randomRotationDegrees implementation and in config

// BEGIN GLOBAL VARIABLES which you may alter if you know what you're doing:
JSONObject allImportedJSON;       // intended to store everything imported from JSONconfigFileName
JSONObject globalsConfigJSON;     // stores JSON global value overrides object extracted from allImportedJSON
JSONArray gridConfigsJSON;        // stores JSON grid config values extracted from allImportedJSON

// json configuration to load; see the sibling file imageBomberDefaultConfig.json for a complete example of options. Read on for config options and JSON config usage.
// String JSONconfigFileName = "imageBomberDefaultConfig.json";
String JSONconfigFileName = "image_bomber_configs/32_Max_Chroma_Medium_Light_Depth_by_Hue.json";
// NOTE that all of these below globals have counterpart values you can set in the .json file name assigned to the JSONconfigFileName (and parsed for usage after that). Any variables in that file which are assigned a null value will not have that value used, and the correspoding value assigned below will instead be used. (You must have useful values hard-coded to all the below globals; they function as defaults.) Any variables in the .json config file which are assigned a non-null value (such as an integer or float) will *override* any corresponding values below:
boolean booleanOverrideSeed = false;    // if set to true, overrideSeed will be used as the random seed for the first displayed variant. Any variants after that -- see renderVariantsInfinitely -- will have a random seed assigned. If booleanOverrideSeed is set to false, a seed will be chosen randomly for the first variant, and also all variants after. Setting booleanOverrideSeed to true with a dedicated value for overrideSeed will result in the same pseudo-randomness and result image for the first variant every time, given the same image resources and grid configurations.
int overrideSeed = 936942080;   // see notes for booleanOverrideSeed. The seed of the first feature complete version demo output was -289762560. Another early used seed: 936942080
boolean saveFrames = false;    // set to true to save animation frames (images), false to not save them.
int frameRate = 60;   // how many frames per second to display changes to art. But if saveFrames is set to true, this is not used: Processing built-in frameRate function will not be called, and therefore the default no max or no throttle framerate will be used.
boolean useFrameRate = false;  // if set to true, frameRate value will be used via call of Processing built-in function frameRate(n). See also comment for saveFrames.
boolean useCustomCanvasSize = true;    // if set to true, customCanvasWidth and customCanvasHeight will define the canvas dimensions. Ff set to false, the full screen size will be detected and used.
int customCanvasWidth = 1920;  // set to any arbitrary width you want for the complete, composite image. for 1.33 aspect, I suggest 1280.
int customCanvasHeight = 1080;  // set to any arbitrary height you want for ". for 1.33 aspect, I suggest 960.
int stopAtFrame = -1;   // Processing program will exit after this many animation frames. If set to a negative number, the program runs forever until you manually stop it. If set to 0 it makes 1 frame regardless, because of the way the draw() and exit() functions work: exit() waits for draw() to finish. 764 may be a good number for this if you use a positive value. NOTES: intended use with this value and a gridIterator class is that the gridIterator keeps making images over cell areas of nested finer grids until stopAtFrame is reached. If stopAtFrame is -1 then a gridIterator will be used until all intended elements in the grid are rendered. After a render completes, other globals control what happens: see notes for exitOnRenderComplete and renderVariantsInfinitely.
boolean exitOnRenderComplete = false;   // causes program to terminate after completion of first variant render, even if renderVariantsInfinitely is set to true
boolean renderVariantsInfinitely = false;   // causes program to render a new variant after the first one completes, and another after that, ad infinitum.
boolean saveLastFrameOfEveryVariant = false;    // causes program to use manualSaveFrame(); for the final frame of every variant. Useful for finding a favorite among many variants. (Including if stopAtFrame causes an early variant render stop.)
color backgroundColorWithAlpha = color(144,145,145,255);   // alter the three integer RGB values and alpha in that to set the background color. For neutral (as perceived by humans) gray, set all three RGB values to 145.

// color array to randomly select from for fallback vector circles, OR for vector mode:
color[] colorsArray = {
  #FFFFFF, #EDEDED, #DBDCDC, #C9CACA, #B7B7B8, #A3A4A5, #909191,
  #7B7C7D, #656767, #4E5051, #353838, #191B1C,#000000
};
// END GLOBAL VARIABLES which you may alter

// GLOBALS NOT TO CHANGE HERE; program logic or the developer may change them in program runs or updates:
String scriptVersionString = "2-22-3";

String animFramesSaveDir;
int countedFrames = 0;
int seed;

// controls feedback print:
boolean allGridsRenderedFeedbackPrinted = false;   // when the size of the grid_iterators array becomes zero, a message is printed in the draw() loop, if this boolean is false, a message is printed that rendering is done. Then the boolean is immediately set to true so the message is never reprinted.

// related to automatic download of image bomber images sets subfolders:
boolean enableAutoDownload = true;
String imageArchiveUrl = "http://earthbound.io/data/dist/image_bomber_sets_subfolders.zip";
String archiveFilename = "image_bomber_sets_subfolders.zip";
String extractToFolder = "image_bomber_sets";


// has functions that iterate cell position with related coordinates on a grid. See internal class initializer.
class GridIterator {
  // Grid dimensions
  int cols, rows;

  float minScaleMultiplier;     // minimum amount to randomly scale images down to. It's a multiplier; for example if the source image width is 600, then 600 * 0.27 = 162 px minimum width. Suggested values: 0.15 to 0.27. If smaller max like 0.27, suggest this at 0.081.
  float maxScaleMultiplier;     // maximum amount to randomly scale images up to. Can constrain larger images to a smaller maximum. Not recommended to exceed 1, unless you anticipate images looking good scaled up.
  float minRotation;            // minimum random rotation range in degrees. May be negative or positive.
  float maxRotation;            // maximum random rotation range in degrees. May be negative or positive.
  float minSquishMultiplier;
  float maxSquishMultiplier;    // If you want a range that's stretched (or squished) and admitting normal, set this to 1. You can also set this to more than one to have "squished" to "stretch" range.
  boolean squishImagesBool;             // if set to true, after image size is randomly proportionally scaled down, image widths and heights are further randomly altered without respect for maintaining aspect (a square may be squished or stretched to a rectangle), within constraints of minSquishMultiplier (minimum) to maxSquishMultiplier (maximum). If set to false, no squishing will occur and images will remain at original proportion. Note that you may set a maxSquishMultiplier below 1 for images to always be squished at least to some amount.

  int elementsPerCell;      // when this count is reached, nextCell() is called
  int drawnCellElements;    // for counting drawn elements to check against elementsPerCell

  // Current cell position
  int currentCol, currentRow;

  // Cell boundaries
  int xMin, xMax, yMin, yMax;

  // Grid total boundaries; gridX1 and gridY1 are the coordinate of the upper left corner of the grid.
  int gridX1, gridY1, gridX2, gridY2;

  String imagesPath;

  // Cell dimensions
  int cellWidth, cellHeight;

  // Boolean info of whether last row was surpassed and wrapped around to first;
  // by design this will be checked and if necessary changed from outside an instance of GridIterator:
  boolean wrappedPastLastRow;

  ArrayList<PImage> allImagesList;
  int imagesArrayListLength;
  int widthOfImagesInArrayList;
  int heightOfImagesInArrayList;

  float skipCellChance;           // if nonzero there is a chance that when nextCell() is called it will skip the next cell (advance two cells)
  float skipDrawElementChance;    // if nonzero there is a chance that when drawRNDelement() is called it will skip drawing an element

  boolean circlesOverride;       // flag to use vector circles instead of images. Overridden to true if images load fails.

  // a class instance is initialized with a JSON object imported from (by default) imageBomberDefaultConfig.json or any other JSON
  GridIterator(JSONObject gridJSON) {
    gridX1 = gridJSON.getInt("gridX1");
    gridY1 = gridJSON.getInt("gridY1");
    gridX2 = gridJSON.getInt("gridX2");
    gridY2 = gridJSON.getInt("gridY2");
    cols = gridJSON.getInt("cols");
    rows = gridJSON.getInt("rows");
    // Calculate cell dimensions
    cellWidth = gridX2 / cols;
    cellHeight = gridY2 / rows;
    minScaleMultiplier = gridJSON.getFloat("minScale");
    maxScaleMultiplier = gridJSON.getFloat("maxScale");
    minRotation = gridJSON.getFloat("minRotation");
    maxRotation = gridJSON.getFloat("maxRotation");
    minSquishMultiplier = gridJSON.getFloat("minSquish");
    maxSquishMultiplier = gridJSON.getFloat("maxSquish");
    squishImagesBool = gridJSON.getBoolean("booleanSquishImages");
    imagesPath = gridJSON.getString("imagesPath");
    elementsPerCell = gridJSON.getInt("elementsPerCell");
    skipCellChance = gridJSON.getFloat("skipCellChance");
    skipDrawElementChance = gridJSON.getFloat("skipDrawElementChance");
    circlesOverride = gridJSON.getBoolean("booleanCirclesOverride");

    // initializes members to default, ready-to-start-render state:
    reset();

    allImagesList = new ArrayList<PImage>();

    // logic to create array of png file names from subfolder /source_files:
    String path = sketchPath() + "/" + imagesPath;

    ArrayList<File> allFiles = listFilesRecursive(path);

    // Filter that list to only the image files we want, and add them to the image array:
    for (File f : allFiles) {
      if (f.isDirectory() == false) {
        String fullPathToFile = f.getAbsolutePath();
        // only add file names that end with .png:
        if (fullPathToFile.matches("(.*).png")) {
          println("Adding file " + fullPathToFile + " to images ArrayList . . .");
          PImage tmpImage = loadImage(fullPathToFile);
          // add image to list if valid, otherwise skip add, and warn
          if (tmpImage != null) {allImagesList.add(tmpImage);}
          else {println("WARNING: Could not load image: " + fullPathToFile);}
        }
      }
    }

    // check if images list empty; if so, create dummy values and rend drawRNDelement() will fallback to circle vectors
    if (allImagesList.isEmpty()) {
      println("WARNING: No valid images found in " + imagesPath + ". Will use fallback circles.");
      circlesOverride = true;
      // Set these to dummy / default values since we won't be using actual images
      imagesArrayListLength = colorsArray.length - 1;    // -1 because it will be used with zero-based indexing
      // println("Set imagesArrayListLength to " + imagesArrayListLength + " (colorsArray length: " + colorsArray.length + ")");
      widthOfImagesInArrayList = 450;     // max diameter for fallback circles
      heightOfImagesInArrayList = 450;
    } else {    //  otherwise set values derived from images:
      imagesArrayListLength = allImagesList.size() - 1;   // -1 because it will be used with zero-based indexing
      widthOfImagesInArrayList = allImagesList.get(0).width;
      heightOfImagesInArrayList = allImagesList.get(0).height;
      // println("Using images. imagesArrayListLength: " + imagesArrayListLength);
    }

  }

  // Update the cell boundaries based on current position
  void updateCellBounds() {
    // println("xMin, xMax, yMin, yMax before update: " + xMin + ", " + xMax, ", " + yMin + ", " + yMax);
    xMin = gridX1 + currentCol * cellWidth;    // when currentCol is 0, via order of operations (currentCol * cellWidth) will be 0, which is correct
    xMax = xMin + cellWidth;
    yMin = gridY1 + currentRow * cellHeight;   // same calculation as for xMin = 0 if currentRow is 0 applies here.
    yMax = yMin + cellHeight;
    // println("xMin, xMax, yMin, yMax AFTER update: " + xMin + ", " + xMax, ", " + yMin + ", " + yMax);
  }

  // avoids duplicate logic but hard for hooman to math :)
  void nextCellHelper() {
    // println("currentCol and currentRow are: " + currentCol + ", " + currentRow);
    currentCol++;

    // If we've passed the last column, wrap to the first column
    if (currentCol >= cols) {
      // println("currentCol is >= cols (" + cols + "); will update.");
      currentCol = 0;
      currentRow++;
      // println("currentCol and currentRow are now: " + currentCol + ", " + currentRow);

      // If we've passed the last row, wrap to the first row
      if (currentRow >= rows) {
        // println("currentRow >= rows (" + rows + "); will update.");
        currentRow = 0;
        // println("currentRow was updated to: " + currentRow);
        wrappedPastLastRow = true;
        // println("set wrappedPastLastRow to true, as currentRow wrapped and was reset to zero.");
      }
    }
    // println("currentCol and currentRow ARE NOW: " + currentCol + ", " + currentRow);
  }

  // Move to the next cell (left to right, top to bottom)
  void nextCell() {
    // randomly skip a cell if we draw a random number less than skipCellChance
    if (random(1) < skipCellChance) {
      // println("SKIPPING CELL because of random draw of number less than skipCellChance, " + skipCellChance + "!");
      nextCellHelper();
      nextCellHelper();   // do this TWICE to effectively skip a cell
      updateCellBounds();
      return; // Skip normal cell advance logic
    }

    // if we didn't draw a random number less than skipCellChance in that logic block, advance a cell:
    nextCellHelper();
    updateCellBounds();
  }

  // draws an element in current cell boundaries with scale, squish, and location randomization constraints:
  void drawRNDelement() {
    // if we randomly draw a number within range skipDrawElementChance, skip drawing any element. (This will never happen if skipDrawElementChance is 0.)
    if (random(1) < skipDrawElementChance) {
      // println("SKIPPING ELEMENT DRAW because of random draw of number less than skipDrawElementChance, " + skipDrawElementChance + "!");
      return;   // we just return without drawing anything; no element drawn
    }

    int xCenter = (int) random(xMin, xMax);
    int yCenter = (int) random(yMin, yMax);

    pushMatrix();
    translate(xCenter, yCenter);
    float randomRotateDegree = random(minRotation, maxRotation);
    rotate(radians(randomRotateDegree));

    // set random height and width to scale image to (within constraints):
    // randomize width and height within scale range, and maintain aspect (will alter aspect after this if told to) :
    float width_and_height_scalar = random(minScaleMultiplier, maxScaleMultiplier);
    float scaled_width = widthOfImagesInArrayList * width_and_height_scalar;
    float scaled_height = heightOfImagesInArrayList * width_and_height_scalar;

    // if boolean instructs to do so, alter dimensions to random squish:
    if (squishImagesBool) {
      float widthSquishMultiplier = random(minSquishMultiplier, maxSquishMultiplier);
      scaled_width *= widthSquishMultiplier;
    }

    if (!circlesOverride) {
      // we have images to use; get random index for an image in the array:
      int rnd_imagesArray_idx = (int) random(0, imagesArrayListLength + 1);    // + 1 bcse random max range is not included in range
      // if we don't do pushMatrix() and popMatrix(), xCenter and yCenter should be specied as nonzero; otherwise we translate() to those coordinates and they are 0, 0
      // image(allImagesList.get(rnd_imagesArray_idx), xCenter, yCenter, scaled_width, scaled_height);    // use xCenter and yCenter if we don't push and pop matrix, use 0 otherwise?
      image(allImagesList.get(rnd_imagesArray_idx), 0, 0, scaled_width, scaled_height);
    } else {
      int colorIndex = (int) random(0, colorsArray.length);
      fill(colorsArray[colorIndex]);
      noStroke();
      // no images available -- use fallback circles:
      ellipse(0, 0, scaled_width, scaled_height);  // Draw at translated origin
    }
    popMatrix();

    // THIS GLOBAL iterated here immediately after we render any element; strictly the program may render many more frames than this, but we only want to reference frames that we "count" and which are in the numbered animation sequence:
    countedFrames += 1;

    // if told to save an animation frame, do so:
    if (saveFrames == true) {
      String paddedFrameNumber = String.format("%06d", countedFrames);
      saveFrame(animFramesSaveDir + "/" + paddedFrameNumber + ".png");
    }

    // iterate grid config internal value:
    drawnCellElements += 1;

    // FIX: using == here leads to unentended result of wrappedPastLastRow set to true; using >= avoids that:
    if (drawnCellElements >= elementsPerCell) {
      nextCell();
      drawnCellElements = 0;
    }
    //popMatrix();  // you need to uncomment this if you animate things. If you don't animate things, it isn't necessary. I think.
  }

  boolean isComplete() {
    return wrappedPastLastRow;    // set to true in a Class function when we've gone through all cells
  }

  // to reset class members which will allow us to start a new variant for renderVariantsInfinitely mode, OR to initialize a GridIterator from the constructor:
  void reset() {
    drawnCellElements = 0;
    // Start at first cell (column 0, row 0)
    currentCol = 0;   // Using 0-based indexing
    currentRow = 0;
    wrappedPastLastRow = false;
    updateCellBounds();
  }
}

// OUTSIDE SETUP, DECLARE ArrayList of GridIterators:
GridIterator grid_iterator;   // main instance of class to which instances in the following array will be assigned by reference for convenience
ArrayList<GridIterator> grid_iterators;    // grid_iterators to be used in succession
// END GLOBAL VARIABLES AND CLASSES to not alter


// Function that handles values etc. for new animated variant to be displayed;
// intended only to be called at the moment we know a render of a variant is complete:
void prepareNextVariant() {
  // notify that program will conditionally exit if so; but I want the information after this printed last so I'm checking exitOnRenderComplete twice:
  if (exitOnRenderComplete == true) {println("exitOnRenderComplete boolean set to true; program will exit.");}

  // handle variant render complete feedback print
  if (allGridsRenderedFeedbackPrinted == false) {
    println("RENDERING COMPLETE (grid_iterators.size == 0).");
    allGridsRenderedFeedbackPrinted = true;
    if (saveFrames == true) {
      println("Animation save frames are in the directory:\n  " + animFramesSaveDir);
    }
  }

  // conditionally save the last frame of the variant if a boolean says so:
  if (saveLastFrameOfEveryVariant == true) {manualSaveFrame();}
  // conditionally exit program as earlier notified will happen:
  if (exitOnRenderComplete == true) {
    exit();
  }

  // handle setting up next variant if we haven't exited the program
  if (booleanOverrideSeed == true) {   // this will only be the case the first time we check booleanOverrideSeed if it is initially set to true; after we set it false this will always be false:
    println("booleanOverrideSeed true; overrideSeed value " + overrideSeed + " will be used to seed pseudorandom number generator.");
    seed = overrideSeed;
    // set this false so that the above only happens once, because for renderVariantsInfinitely (if set true) we want a new random seed for every variant after the first one:
    booleanOverrideSeed = false;
  } else {
    seed = (int) random(-2147483648, 2147483647);
  }

  // reset / reinitialize globals and objects:
  randomSeed(seed);

  // if we haven't added anything to the grid_iterators ArrayList (if it is null), add to it via initGrids(); if we have (if it is not null), reset them. The whole reason of this is avoiding reload of image paths / resources when we can reuse them for a new variant, but still change other things in the list of grid iterators to a default / reset state to render a new variant:
  if (grid_iterators == null) {
    initGrids();    // intended for first time, creates everything
  } else {
    // subsequent variants - just reset existing grids:
    for (GridIterator g : grid_iterators) {
      g.reset();
    }
  }

  grid_iterator = null;   // will be reassigned on next draw
  grid_iterator = grid_iterators.get(0);
  clearTheCanvas = true;

  // DEPRECATED; moved to draw() loop which is really where it goes:
  // background(backgroundColorWithAlpha);     // clear canvas
  countedFrames = 0;
  allGridsRenderedFeedbackPrinted = false;

  // Only call frameRate if saveFrames is false, because if we're saving animation frames we (or I--deciding for the user!) don't want any other slowdown; saving frames is slower already.
  if (saveFrames == false) {
    if (useFrameRate == true) {
      frameRate(frameRate);
    }
  } else {
  // ALTERS A GLOBAL:
    animFramesSaveDir = "_rnd_images_processing__anim_run__v" + scriptVersionString + "_seed__" + seed;
  }

  println(">> New variant prepared. Seed: " + seed);

  // Restart the draw loop if it was stopped
  if (!looping) {
    loop();
  }
}


// I here adapt a function by Daniel Shiffman which recursively traverses subdirectories; the "ArrayList<File> a" is passed by reference (directly modifies the Arraylist), I think:
void recurseDir(ArrayList<File> a, String dir) {
  File file = new File(dir);
  // if the file is a directory, recurse through it with a call of this function istelf! :
  if (file.isDirectory()) {
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      recurseDir(a, subfiles[i].getAbsolutePath());
    }
  // otherwise (if it is a file), add it to the list:
  } else {
    a.add(file);
  }
}


// I here adapt a function by Daniel Shiffman to get a list of all files in a directory and all subdirectories:
ArrayList<File> listFilesRecursive(String dir) {
  // Validate directory exists and is not a file before proceeding; throw and exit if it is either:
  File dirFile = new File(dir);
  if (!dirFile.exists()) {
    println("WARNING: Directory does not exist: " + dir);
    println("Full path: " + dirFile.getAbsolutePath());
  }

  if (!dirFile.isDirectory()) {
    println("WARNING: Path is not a directory: " + dir);
  }

  // If neither of those threw, it will proceed:
  ArrayList<File> fileList = new ArrayList<File>();
  recurseDir(fileList, dir);
  return fileList;
}


// loads external config file to initialize globals and grid iterators. Call before initGrids() or overrideGlobals(), but they are coded to call this if globalsConfigJSON is null:
void loadConfigurationJSON() {
  // attempt external JSON config file load
  try {
    allImportedJSON = loadJSONObject(JSONconfigFileName);
    // if load config failed, exit with print of error
  } catch (Exception e) {
    println("ERROR: Could not load " + JSONconfigFileName + ". Message: " + e);
    println("Please create that file or examine it for validity.");
    exit();
  }
}


// returns an acquired boolean value if an investigated JSON field is non-null; otherwise returns the original value passed:
boolean setBooleanFromJSON(boolean booleanToSet, JSONObject configJSON, String fieldName) {
  if (configJSON.hasKey(fieldName) && !configJSON.isNull(fieldName)) {
    return configJSON.getBoolean(fieldName);
  } else {
    return booleanToSet;
  }
}


// returns acquired int value if an investigated JSON field is non-null; otherwise returns the original value passed:
int setIntFromJSON(int intToSet, JSONObject configJSON, String fieldName) {
  if (configJSON.hasKey(fieldName) && !configJSON.isNull(fieldName)) {
    return configJSON.getInt(fieldName);
  } else {
    return intToSet;
  }
}


// obtains JSON values from "global_settings" object and, for any of them which do not have a null value, overiddes hard-coded globals in this script with their value from the corresponding JSON object's field; e.g. if the "boolanSaveFrames" field is "true" or "false" instead of null, it uses that "true" or "false" value:
void overrideGlobals() {
  try {
    if (allImportedJSON == null) {loadConfigurationJSON();}
    globalsConfigJSON = allImportedJSON.getJSONObject("global_settings");
    println("Global settings in-memory JSON object loaded successfully.");
    // Check if various keys (intended globals) exist and are not null; assign value from them if so:
    // fields for set~JSON functions:        boolean booleanToSet/int intToSet, JSONObject configJSON, String fieldName
    booleanOverrideSeed =       setBooleanFromJSON(booleanOverrideSeed, globalsConfigJSON, "booleanOverrideSeed");
    overrideSeed =              setIntFromJSON(overrideSeed, globalsConfigJSON, "intOverrideSeed");
    saveFrames =                setBooleanFromJSON(saveFrames, globalsConfigJSON, "boolanSaveFrames");
    useFrameRate =              setBooleanFromJSON(useFrameRate, globalsConfigJSON, "booleanUseFrameRate");
    frameRate =                 setIntFromJSON(frameRate, globalsConfigJSON, "intFrameRate");
    useCustomCanvasSize =       setBooleanFromJSON(useCustomCanvasSize, globalsConfigJSON, "booleanUseCustomCanvasSize");
    customCanvasWidth =         setIntFromJSON(customCanvasWidth, globalsConfigJSON, "intCustomCanvasWidth");
    customCanvasHeight =        setIntFromJSON(customCanvasHeight, globalsConfigJSON, "intCustomCanvasHeight");
    stopAtFrame =               setIntFromJSON(stopAtFrame, globalsConfigJSON, "intStopAtFrame");
    exitOnRenderComplete =      setBooleanFromJSON(exitOnRenderComplete, globalsConfigJSON, "booleanExitOnRenderComplete");
    renderVariantsInfinitely =  setBooleanFromJSON(renderVariantsInfinitely, globalsConfigJSON, "booleanRenderVariantsInfinitely");
    saveLastFrameOfEveryVariant = setBooleanFromJSON(saveLastFrameOfEveryVariant, globalsConfigJSON, "booleanSaveLastFrameOfEveryVariant");
    // color
    if (globalsConfigJSON.hasKey("backGroundColorWithAlpha") && !globalsConfigJSON.isNull("backGroundColorWithAlpha")) {
      JSONArray bgColorArray = globalsConfigJSON.getJSONArray("backGroundColorWithAlpha");
      backgroundColorWithAlpha = color(bgColorArray.getInt(0), bgColorArray.getInt(1), bgColorArray.getInt(2));
    }
    // if assignment failed, exit with print of error
  } catch (Exception e) {
    println("ERROR: Could not initialize global settings from in-memory JSON object. Message: " + e);
    println("Please check the source JSON global configuration (\"global_settings\" object).");
    exit();
  }
}


void initGrids() {
  try {
    if (allImportedJSON == null) {loadConfigurationJSON();}
    gridConfigsJSON = allImportedJSON.getJSONArray("grid_configs");
    println("Configuration file " + JSONconfigFileName + " loaded successfully. Found " + gridConfigsJSON.size() + " grid configs.");
  // if assignment failed, exit with print of error
  } catch (Exception e) {
    println("ERROR: Could not initialize grid configuration from in-memory JSON object. Message: " + e);
    println("Please check the source JSON grid configuration (\"grid_configs\" array).");
    exit();
  }

  // attempt grid_iterator object init from JSON config
  grid_iterators = new ArrayList<GridIterator>();

  for (int i = 0; i < gridConfigsJSON.size(); i++) {
    try {
      JSONObject gridJSON = gridConfigsJSON.getJSONObject(i);
      GridIterator grid = new GridIterator(gridJSON);
      grid_iterators.add(grid);
      println("Created grid: " + gridJSON.getString("name"));

    } catch (Exception e) {
      println("ERROR creating grid iterator from config " + i + ": " + e);
      println("Skipping this grid configuration.");
    }
  }

  if (grid_iterators.isEmpty()) {
    println("FATAL: No valid grid iterators created.");
    exit();
  }
}


// checks for and auto-downloads image resources which this script uses, if target dir does not exist and boolean says to and
void downloadAndExtractImages() {
  // this creates a file object in memory and does nothing on disk; we can use that object to check if a disk object of the same path exists:
  File dir = new File(sketchPath() + "/" + extractToFolder);
  if (enableAutoDownload && !dir.exists() && !dir.isDirectory()) {
    println("Image bomber resources directory " + extractToFolder + " Not found. Starting automatic images archive download...");
    try {
      // Create directories if needed
      java.nio.file.Files.createDirectories(java.nio.file.Paths.get(extractToFolder));

      // Download the archive
      String archivePath = sketchPath() + "/" + archiveFilename;
      println("Downloading from: " + imageArchiveUrl);

      // Download inline
      byte[] data = loadBytes(imageArchiveUrl);
      if (data == null) {
        println("ERROR: Failed to download " + imageArchiveUrl);
        return;
      }
      saveBytes(archivePath, data);
      println("Download complete.");

      // Extract it inline
      println("Extracting to: " + extractToFolder);

      // Simple ZIP extraction using Java's ZipInputStream
      java.util.zip.ZipInputStream zis = new java.util.zip.ZipInputStream(new java.io.FileInputStream(archivePath));
      java.util.zip.ZipEntry zipEntry;
      byte[] buffer = new byte[1024];

      while ((zipEntry = zis.getNextEntry()) != null) {
        String entryName = zipEntry.getName();
        java.io.File newFile = new java.io.File(sketchPath() + "/" + extractToFolder + "/" + entryName);

        if (zipEntry.isDirectory()) {
          newFile.mkdirs();
        } else {
          newFile.getParentFile().mkdirs();
          java.io.FileOutputStream fos = new java.io.FileOutputStream(newFile);
          int len;
          while ((len = zis.read(buffer)) > 0) {
            fos.write(buffer, 0, len);
          }
          fos.close();
        }
      }
      zis.closeEntry();
      zis.close();

      println("Extraction complete.");

      // Clean up the archive if desired
      java.nio.file.Files.deleteIfExists(java.nio.file.Paths.get(archivePath));

      // Trigger a new variant with the new resources
      if (grid_iterators != null) {
        // Force reload of grids to pick up new images
        grid_iterators = null;
        prepareNextVariant();
      }

    } catch (Exception e) {
      println("ERROR during download/extraction: " + e.getMessage());
      e.printStackTrace();
    }
  }
}


void settings() {
  pixelDensity(1);    // or (2) for high def/dotpitch screens?
  // obtains any non-null values from imported JSON config and overrides corresponding globals from them;
  // NOTE that this way, you can for example specify a temporarily used custom canvas size in the JSON config, instead of hard-coding it in this file! :
  overrideGlobals();
  if (useCustomCanvasSize == true) {
    size(customCanvasWidth, customCanvasHeight);
  } else {
    fullScreen();
  }
}


void setup() {
  downloadAndExtractImages();
  imageMode(CENTER);
  prepareNextVariant();
}


boolean clearTheCanvas = true;
void draw() {
  // clear canvas at start of new variant
  if (clearTheCanvas) {
    background(backgroundColorWithAlpha);
    clearTheCanvas = false;
  }

  if (grid_iterators != null && grid_iterators.size() > 0) {
    // find first incomplete grid
    GridIterator currentGrid = null;
    for (GridIterator g : grid_iterators) {
      if (!g.isComplete()) {
        currentGrid = g;
        break;
      }
    }

    if (currentGrid != null) {
      currentGrid.drawRNDelement();
    } else {
      // all grids complete!
      if (renderVariantsInfinitely) {
        // reset all grids for next variant
        for (GridIterator g : grid_iterators) {
          g.reset();
        }
        clearTheCanvas = true;
        prepareNextVariant();
      } else {
        noLoop();  // Stop rendering if not infinite
      }
    }

    // stop condition - frame count limit reached
    if (stopAtFrame > -1 && countedFrames >= stopAtFrame) {
      if (renderVariantsInfinitely) {
        // reset all grids for next variant
        for (GridIterator g : grid_iterators) {
          g.reset();
        }
        clearTheCanvas = true;
        prepareNextVariant();
      } else {
        noLoop();
      }
    }

  } else {
    // no grids exist yet (first run) - shouldn't happen after initGrids()
    println("ERROR: No grid iterators available.");
    noLoop();
  }
}


void manualSaveFrame() {
  if (countedFrames != 0) {   // I don't like this bandaid but it's a simple ouchie fix; it prevents saving a frame when there's only a blank canvas (no elements rendered)
    String paddedFrameNumber = String.format("%06d", countedFrames);
    String saveFileName = "_manual_save__rnd_images_processing_" + "v" + scriptVersionString + "__anim_run__seed_" + seed + "_fr_" + paddedFrameNumber + ".png";
    saveFrame(saveFileName);
    println("image of current canvas saved to " + saveFileName);
  }
}


// save image frame on mouse press, with file name indicating manual save
void mousePressed() {
  manualSaveFrame();
}


// hotkeys for various things
void keyPressed() {
  if (key == 'p' || key == 'P') {
    if (looping) {
      noLoop();  // Pause the sketch
      println("|| PAUSED");
      println("Press 'p' again to resume");
    } else {
      loop();    // Resume the sketch
      println("|> RESUMED");
      println("Press 'p' again to pause");
    }
  }
  if (key == ' ') {
    manualSaveFrame();
  }
  if (key == 'v' || key == 'V') {
    println("Keypress of 'n' detected; ending current variant render and starting a new one . . .");
    prepareNextVariant();
  }
}