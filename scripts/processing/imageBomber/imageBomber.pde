// DESCRIPTION
// Supply images which are all the same dimensions in a subfolder (see USAGE), and this Image Bomber Processing script will randomly position, rotate, and scale them, one after another, as rapidly as you instruct it to, into a new image. Definition sets of images to bomb may be configured in layers. It will optionally save animation images of the process, or interactively save any still which you tell it to.

// NO COPYRIGHT
// This is my original code and I dedicate it to the Public Domain. 2026-02-06 Richard Alexander Hall

// USAGE
// - NOTE that no images are provided with this script "shipped." You must provide a subfolder of images, and set the variable instructing the script what that folder name is, in the global variable. Examine comments provided in the "GLOBAL VARIABLES WHICH YOU MAY ALTER" section for instructions.
// - Examine other comments in that same comment section for instructions on all the global variables which you may alter for your preferences.
// - On run of script, you may press the space bar or a mouse button to save a still of what is displayed. The still is named like this: _rnd_images_processing_v1-0-0__anim_run__seed_1409989632_fr_0000000315.png. You might think that file name has too much information. It doesn't. It is all the information required to reproduce exactly the same image again should you want to (provided the same script version, seed, and source image set).


// CODE
// BEGIN GLOBAL VARIABLES AND CLASSES WHICH YOU SHOULD NOT ALTER unless you are me or you know what you might break if you alter them:
String JSONconfigFileName = "imageBomberDefaultConfig.json";
JSONObject allImportedJSON;       // intended to store everything imported from JSONconfigFileName 
JSONObject globalsConfigJSON;     // stores JSON global value overrides object extracted from allImportedJSON
JSONArray gridConfigsJSON;        // stores JSON grid config values extracted from allImportedJSON

// TO DO:
// - optional random palette retrieval and recoloring of colorizable source rasters (or SVGs??)
// - don't exit the program, just skip draw if non-negative stopAtFrame is reached? BUT THEN also how to handle that if:
// - have a mode to make variations infinitely until program termination
// - randomRotationDegrees in config
boolean booleanOverrideSeed = false;    // if set to true, intOverrideSeed will be used as the random seed for the first displayed variant. If false, a seed will be chosen randomly. A dedicated seed will result in the same pseudo-randomness and result image every time, given the same image resources and grid configurations.
int intOverrideSeed = -289762560;  // seed of first feature complete version demo output is -289762560. Another early used seed: 936942080
boolean saveFrames = false;    // set to true to save animation frames (images)
int frameRate = 60;  // how many frames per second to display changes to art. But if saveFrames is set to true, this is not used: Processing built-in frameRate function will not be called, and therefore the default no max or no throttle framerate will be used.
boolean useFrameRate = false;  // if set to true, frameRate value will be used via call of Processing built-in function frameRate(n). But if saveFrames is set to true, behavior overrides so that frameRate value will not be used (as noted on previous line).
boolean useCustomCanvasSize = true;    // if set to true, the next values will be used. if set to false, the full screen size will be detected and used.
int customCanvasWidth = 1920;  // set to any arbitrary height you want for the complete, composite image. for 1.33 aspect, suggest 1280
int customCanvasHeight = 1080;  // set to any arbitrary width you want for ". for 1.33 aspect, suggest 960
int stopAtFrame = -1;   // Processing program will exit after this many animation frames. If set to a negative number, the program runs forever until you manually stop it. If set to 0 it makes 1 frame regardless, because of the way the draw() and exit() functions work: exit() waits for draw() to finish. 764 may be a good number for this if you use a positive value. NOTES: intended use with this value and a gridIterator class is that the gridIterator keeps making images over cell areas of nested finer grids until stopAtFrame is reached. If stopAtFrame is -1 then a gridIterator will not be used.
// DERIVED GLOBALS
int seed = intOverrideSeed;  // this will be overwritten with a random seed if booleanOverrideSeed is set to false

color backgroundColorWithAlpha = color(144,145,145,255);   // alter the three integer RGB values and alpha in that to customize. For neutral (as perceived by humans) gray, set all three RGB values to 145.

String scriptVersionString = "2-16-0";

String animFramesSaveDir;
int countedFrames = 0;

// has functions that iterate cell position with related coordinates on a grid. See internal class initializer.
class GridIterator {
  // Grid dimensions
  int cols, rows;
  
  float minimumScaleMultiplier;     // minimum amount to randomly scale images down to. It's a multiplier; for example if the source image width is 600, then 600 * 0.27 = 162 px minimum width. Suggested values: 0.15 to 0.27. If smaller max like 0.27, suggest this at 0.081.
  float maximumScaleMultiplier;     // maximum amount to randomly scale images up to. Can constrain larger images to a smaller maximum. Not recommended to exceed 1, unless you anticipate images looking good scaled up.
  float minimumSquishMultiplier;
  float maximumSquishMultiplier;    // If you want a range that's stretched (or squished) and admitting normal, set this to 1. You can also set this to more than one to have "squished" to "stretch" range.
  boolean squishImagesBool;             // if set to true, after image size is randomly proportionally scaled down, image widths and heights are further randomly altered without respect for maintaining aspect (a square may be squished or stretched to a rectangle), within constraints of minimumSquishMultiplier (minimum) to maximumSquishMultiplier (maximum). If set to false, no squishing will occur and images will remain at original proportion. Note that you may set a maximumSquishMultiplier below 1 for images to always be squished at least to some amount.
  
  int elementsPerCell;   // when this count is reached, nextCell() is called
  int drawnCellElements;        // for counting drawn elements to check against elementsPerCell

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

  // initialized with a JSON object imported from (by default) imageBomberDefaultConfig.json or any other JSON
  GridIterator(JSONObject gridJSON) {
    this.gridX1 = gridJSON.getInt("gridX1");
    this.gridY1 = gridJSON.getInt("gridY1");
    this.gridX2 = gridJSON.getInt("gridX2");
    this.gridY2 = gridJSON.getInt("gridY2");
    this.cols = gridJSON.getInt("cols");
    this.rows = gridJSON.getInt("rows");
    // Calculate cell dimensions
    cellWidth = gridX2 / cols;
    cellHeight = gridY2 / rows;
    this.minimumScaleMultiplier = gridJSON.getFloat("minScale");
    this.maximumScaleMultiplier = gridJSON.getFloat("maxScale");
    this.minimumSquishMultiplier = gridJSON.getFloat("minSquish");
    this.maximumSquishMultiplier = gridJSON.getFloat("maxSquish");
    this.squishImagesBool = gridJSON.getBoolean("squishImagesBool");
    this.imagesPath = gridJSON.getString("imagesPath");
    this.elementsPerCell = gridJSON.getInt("elementsPerCell");
    this.drawnCellElements = 0;

    // Start at first cell (column 0, row 0)
    reset();
    updateCellBounds();

    this.wrappedPastLastRow = false;

    allImagesList = new ArrayList<PImage>();
    
    // logic to create array of png file names from subfolder /source_files:
    String path = sketchPath() + "/" + imagesPath;

    ArrayList<File> allFiles = listFilesRecursive(path);
    
    // Filter that list to only the image files we want, and add them to the image array:
    for (File f : allFiles) {
      if (f.isDirectory() == false) {
        String fullPathToFile = f.getAbsolutePath();
        // only add file names that end with .png:
        if (fullPathToFile.matches("(.*).png") == true) {
          println("Adding file " + fullPathToFile + " to images ArrayList . . .");
          PImage tmpImage = loadImage(fullPathToFile);
          allImagesList.add(tmpImage);
        }
      }
    }

    imagesArrayListLength = allImagesList.size() - 1;   // -1 because it will be used with zero-based indexing
    widthOfImagesInArrayList = allImagesList.get(0).width;
    heightOfImagesInArrayList = allImagesList.get(0).height;
  }
  
  // Reset to first cell (column 0, row 0)
  void reset() {
    currentCol = 0;   // Using 0-based indexing
    currentRow = 0;
  }
  
  // Update the cell boundaries based on current position
  void updateCellBounds() {
    // print("xMin, xMax, yMin, yMax before update: " + xMin + ", " + xMax, ", " + yMin + ", " + yMax + "\n");
    xMin = gridX1 + currentCol * cellWidth;    // when currentCol is 0, via order of operations (currentCol * cellWidth) will be 0, which is correct
    xMax = xMin + cellWidth;
    yMin = gridY1 + currentRow * cellHeight;   // same calculation as for xMin = 0 if currentRow is 0 applies here.
    yMax = yMin + cellHeight;
    // print("xMin, xMax, yMin, yMax AFTER update: " + xMin + ", " + xMax, ", " + yMin + ", " + yMax + "\n");
  }
  
  // Move to the next cell (left to right, top to bottom)
  void nextCell() {
    print("currentCol and currentRow are: " + currentCol + ", " + currentRow + "\n");
    // Move to next column
    currentCol++;

    // If we've passed the last column, wrap to the first column
    if (currentCol >= cols) {
      print("currentCol is >= cols (" + cols + "); will update.\n");
      currentCol = 0;
      currentRow++;
      print("currentCol and currentRow are now: " + currentCol + ", " + currentRow + "\n");
      
      // If we've passed the last row, wrap to the first row
      if (currentRow >= rows) {
        print("currentRow >= rows (" + rows + "); will update.\n");
        currentRow = 0;
        print("currentRow was updated to: " + currentRow + "\n");
        wrappedPastLastRow = true;
        print("set wrappedPastLastRow to true, as currentRow wrapped and was reset to zero.\n");
      }
    }
    
    print("currentCol and currentRow ARE NOW: " + currentCol + ", " + currentRow + "\n");
    // Update the cell boundaries (needed after nextCell)
    updateCellBounds();
  }
  
  // Jump to specific cell (0-based index)
  // void gotoCell(int col, int row) {
  //   currentCol = constrain(col, 0, cols);
  //   currentRow = constrain(row, 0, rows);
  //   updateCellBounds();
  // }

  // draws an element in current cell boundaries with scale, squish, and location randomization constraints:
  void drawRNDelement() {
    // pushMatrix();  // you need to uncomment this if you animate things. If you don't animate things, it isn't necessary. I think.
    int xCenter = (int) random(xMin, xMax);
    int yCenter = (int) random(yMin, yMax);
    translate(xCenter, yCenter);
    float randomRotateDegree = random(0, 360);
    rotate(radians(randomRotateDegree));
    translate(xCenter * -1, yCenter * -1);
    // get random index for an image in the array:
    int rnd_imagesArray_idx = (int) random(0, imagesArrayListLength + 1);    // + 1 bcse random max range is not included in range
    // set random height and width to scale image to (within constraints):
    // randomize width and height within scale range, and maintain aspect (will alter aspect after this if told to) :
    float width_and_height_scalar = random(minimumScaleMultiplier, maximumScaleMultiplier);
    float scaled_width = (int) widthOfImagesInArrayList * width_and_height_scalar;
    float scaled_height = (int) heightOfImagesInArrayList * width_and_height_scalar;

    // if boolean instructs to do so, alter dimensions to random squish:
    if (squishImagesBool == true) {
      float widthSquishMultiplier = random(minimumSquishMultiplier, maximumSquishMultiplier);
      scaled_width = (int) scaled_width * widthSquishMultiplier;
    }

    image(allImagesList.get(rnd_imagesArray_idx), xCenter, yCenter, scaled_width, scaled_height);

    drawnCellElements += 1;
    // FIX: using == here leads to unentended result of wrappedPastLastRow set to true; using >= avoids that:
    if (drawnCellElements >= elementsPerCell) {
      nextCell();
      drawnCellElements = 0;
    }
    //popMatrix();  // you need to uncomment this if you animate things. If you don't animate things, it isn't necessary. I think.
  }
}

// OUTSIDE SETUP, DECLARE ArrayList of GridIterators:
GridIterator grid_iterator;   // main instance of class to which instances in the following array will be assigned by reference for convenience
ArrayList<GridIterator> grid_iterators;    // grid_iterators to be used in succession per previous comment
// END GLOBAL VARIABLES AND CLASSES WHICH YOU SHOULD NOT ALTER

// Function that handles values etc. for new animated variation to be displayed:
void prepareNextVariation() {
  if (booleanOverrideSeed == true) {
    seed = intOverrideSeed;
    booleanOverrideSeed = false;
  } else {
    seed = (int) random(-2147483648, 2147483647);
  }
  randomSeed(seed);
  print("Value of booleanOverrideSeed: " + booleanOverrideSeed + "\n");
  print("Seed value: " + seed + "\n");

    // Only call frameRate if saveFrames is false, because if we're saving animation frames we (or I--deciding for the user!) don't want any other slowdown; saving frames is slower already.
    if (saveFrames == false) {
      frameRate(frameRate);
    } else {
// ALTERS A GLOBAL:
      animFramesSaveDir = "_rnd_images_processing__anim_run__v" + scriptVersionString + "_seed__" + seed;
    	print("animFramesSaveDir value: " + animFramesSaveDir + "\n");
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
    print("ERROR: Could not load " + JSONconfigFileName + ". Message: " + e);
    print("Please create that file or examine it for validity.");
    exit();
  }
}

// obtains JSON values from "global_settings" object and, for any of them which do not have a null value, overiddes hard-coded globals in this script with their value from the corresponding JSON object's field; e.g. if the "boolanSaveFrames" field is "true" or "false" instead of null, it uses that "true" or "false" value:
void overrideGlobals() {
  try {
    if (allImportedJSON == null) {loadConfigurationJSON();}
    globalsConfigJSON = allImportedJSON.getJSONObject("global_settings");
    print("Global settings in-memory JSON object loaded successfully.");
    // Check if a key exists and is not null; assign value from it if so; this is cumbersome but eh?
    if (globalsConfigJSON.hasKey("booleanOverrideSeed") && !globalsConfigJSON.isNull("booleanOverrideSeed")) {
      booleanOverrideSeed = globalsConfigJSON.getBoolean("booleanOverrideSeed");
    }
    if (globalsConfigJSON.hasKey("intOverrideSeed") && !globalsConfigJSON.isNull("intOverrideSeed")) {
      intOverrideSeed = globalsConfigJSON.getInt("intOverrideSeed");
    }
    if (globalsConfigJSON.hasKey("boolanSaveFrames") && !globalsConfigJSON.isNull("boolanSaveFrames")) {
      saveFrames = globalsConfigJSON.getBoolean("boolanSaveFrames");
    }
    if (globalsConfigJSON.hasKey("intFrameRate") && !globalsConfigJSON.isNull("intFrameRate")) {
      frameRate = globalsConfigJSON.getInt("intFrameRate");
    }
    if (globalsConfigJSON.hasKey("booleanUseFrameRate") && !globalsConfigJSON.isNull("booleanUseFrameRate")) {
      useFrameRate = globalsConfigJSON.getBoolean("booleanUseFrameRate");
    }
    if (globalsConfigJSON.hasKey("booleanUseCustomCanvasSize") && !globalsConfigJSON.isNull("booleanUseCustomCanvasSize")) {
      useCustomCanvasSize = globalsConfigJSON.getBoolean("booleanUseCustomCanvasSize");
    }
    if (globalsConfigJSON.hasKey("intCustomCanvasWidth") && !globalsConfigJSON.isNull("intCustomCanvasWidth")) {
      customCanvasWidth = globalsConfigJSON.getInt("intCustomCanvasWidth");
    }
    if (globalsConfigJSON.hasKey("intCustomCanvasHeight") && !globalsConfigJSON.isNull("intCustomCanvasHeight")) {
      customCanvasHeight = globalsConfigJSON.getInt("intCustomCanvasHeight");
    }
    if (globalsConfigJSON.hasKey("intStopAtFrame") && !globalsConfigJSON.isNull("intStopAtFrame")) {
      stopAtFrame = globalsConfigJSON.getInt("intStopAtFrame");
    }
    if (globalsConfigJSON.hasKey("backGroundColorWithAlpha") && !globalsConfigJSON.isNull("backGroundColorWithAlpha")) {
      JSONArray bgColorArray = globalsConfigJSON.getJSONArray("backGroundColorWithAlpha");
      backgroundColorWithAlpha = color(bgColorArray.getInt(0), bgColorArray.getInt(1), bgColorArray.getInt(2));
    }
    // if assignment failed, exit with print of error
  } catch (Exception e) {
    print("ERROR: Could not initialize global settings from in-memory JSON object. Message: " + e);
    print("Please check the source JSON global configuration (\"global_settings\" object).");
    exit();
  }
}

void initGrids() {
  try {
    if (allImportedJSON == null) {loadConfigurationJSON();}
    gridConfigsJSON = allImportedJSON.getJSONArray("grid_configs");
    print("Configuration file " + JSONconfigFileName + " loaded successfully. Found " + gridConfigsJSON.size() + " grid configs.");
  // if assignment failed, exit with print of error
  } catch (Exception e) {
    print("ERROR: Could not initialize grid configuration from in-memory JSON object. Message: " + e);
    print("Please check the source JSON grid configuration (\"grid_configs\" array).");
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
  imageMode(CENTER);   // default is (CENTER)
  background(backgroundColorWithAlpha);
  prepareNextVariation();
  // loadConfigurationJSON();
  initGrids();
  grid_iterator = grid_iterators.get(0);
}

void draw() {
// some of the organization / drawing logic:
// - if we still have any grid iterators (if the size of the arrayList of them is greater then 0):
// - draw the next random element for that grid.
// - if everything for a grid_iterator has been drawn (grid_iterator[0].wrappedPastLastRow == true), remove that first grid iterator from the arrayList so that we operate on the next grid if we operate on index 0 in the arrayList of them.
if (grid_iterators.size() > 0) {
    // to draw an element at any randomly selected place on the canvas in a range:
    // drawRNDelement(int xMin, int xMax, int yMin, int yMax)
    grid_iterator.drawRNDelement();

    if (grid_iterator.wrappedPastLastRow == true) {
      print("------------------------------ WRAPPED AROUND FROM LAST ROW of grid_iterator! ------------------------------\n");
      grid_iterators.remove(0);
      if (grid_iterators.size() > 0) {
        // assign the next grid_iterator if there is any left, then do other relevant things:
        grid_iterator = grid_iterators.get(0);
      }
    }

    if (saveFrames == true) {
      saveFrame(animFramesSaveDir + "/######.png");
    }

    // conditional program run end (or never end unless the user manually terminates the program run):
    if (stopAtFrame > -1) {
      countedFrames += 1;
      if (countedFrames >= stopAtFrame) {
        exit();
      }
    }
  }
}

// save frame function (save png)
void saveStill() {
  saveFrame("_rnd_images_processing_" + "v" + scriptVersionString + "__anim_run__seed_" + seed + "_fr_##########.png");
}
// if the below is uncommented, save frame on mouse press
void mousePressed() {
  saveStill();
}
// if the below is uncommented, advance grid on SPACEBAR key press
void keyPressed() {
  if (keyCode == ' ') {
    grid_iterator.nextCell();
  }
}
