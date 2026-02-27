// DESCRIPTION
// Supply images which are all the same dimensions in a subfolder (see USAGE), and this Image Bomber Processing script will randomly position, rotate, and scale them, one after another, as rapidly as you instruct it to, into a new image. Definition sets of images to bomb may be configured in layers. It will optionally save animation images of the process, or interactively save any still which you tell it to, and more. See USAGE.

// NO COPYRIGHT
// This is my original code and I dedicate it to the Public Domain. 2026-02-06 Richard Alexander Hall

// USAGE
// - NOTE that no images are provided with this script "shipped." You must provide a subfolder of images, and set the variable instructing the script what that folder name is, in the global variable. Examine comments provided in the "GLOBAL VARIABLES WHICH YOU MAY ALTER" section for instructions.
// - Examine other comments in that same comment section for instructions on all the global variables which you may alter for your preferences, including by defining global preferences and/or a grid in a JSON configuration file.
// - On run of script, you may:
//  - press the space bar or a mouse button to save a still of what is displayed. The still is named like this: _imageBomber_v1-0-0__anim_run__seed_1409989632_fr_0000000315.png. You might think that file name has too much information. It doesn't. It is all the information required to reproduce exactly the same image again should you want to (provided the same script version, seed, and source image set).
//  - click the canvas or press the spacebar to save the current display to an image
//  - type the letter 'p'(ause) to pause or resume rendering of elements in the grid
//  - type the letter 'v'(ariant) to stop rendering the current variant and start a new one
// See comments in the modifiable GLOBAL VARIANTS area to learn what else this script can do.


// CODE
// TO DO:
// - optional random palette retrieval and recoloring of colorizable source rasters (or SVGs??)
// - randomRotationDegrees implementation and in config
// - behavior update: make it so that with this (and other?) configs:
//   saveFrames: False, stopAtFrame: -1, exitOnRenderComplete: False, renderVariantsInfinitely: False, saveLastFrameEveryVariant: True, saveLayers: False
//   -- after a render completes and I'm guessing noLoop() was run, I can't click the still canvas to save the current frame. I don't like a potential fix: make an independent keypress scan loop (infinite timer)?? :/


// BEGIN GLOBAL VARIABLES which you may alter if you know what you're doing:
JSONObject allImportedJSON;       // intended to store everything imported from JSONconfigFileName
JSONObject globalsConfigJSON;     // stores JSON global value overrides object extracted from allImportedJSON
JSONArray gridConfigsJSON;        // stores JSON grid config values extracted from allImportedJSONx

// json configuration to load; see the sibling file imageBomberDefaultConfig.json for a complete example of options. Read on for config options and JSON config usage.
// String JSONconfigFileName = "image_bomber_configs/imageBomberDefaultConfig.json";
String JSONconfigFileName = "image_bomber_configs/test.json";
// NOTE that all of these below globals have counterpart values you can set in the .json file name assigned to the JSONconfigFileName (and parsed for usage after that). Any variables in that file which are assigned a null value will not have that value used, and the correspoding value assigned below will instead be used. (You must have useful values hard-coded to all the below globals; they function as defaults.) Any variables in the .json config file which are assigned a non-null value (such as an integer or float) will *override* any corresponding values below:
boolean doSeedOverride = false;    // if set to true, overrideSeed will be used as the random seed for the first displayed variant. Any variants after that -- see renderVariantsInfinitely -- will have a random seed assigned. If doSeedOverride is set to false, a seed will be chosen randomly for the first variant, and also all variants after. Setting doSeedOverride to true with a dedicated value for overrideSeed will result in the same pseudo-randomness and result image for the first variant every time, given the same image resources and grid configurations.
int overrideSeed = 936942080;   // see notes for doSeedOverride. The seed of the first feature complete version demo output was -289762560. Another early used seed: 936942080
boolean saveFrames = true;    // set to true to save animation frames (images), false to not save them.
int frameRate = 60;   // how many frames per second to display changes to art. But if saveFrames is set to true, this is not used: Processing built-in frameRate function will not be called, and therefore the default no max or no throttle framerate will be used.
boolean useFrameRate = false;  // if set to true, frameRate value will be used via call of Processing built-in function frameRate(n). See also comment for saveFrames.
boolean useCustomCanvasSize = true;    // if set to true, customCanvasWidth and customCanvasHeight will define the canvas dimensions. Ff set to false, the full screen size will be detected and used.
int customCanvasWidth = 1920;  // set to any arbitrary width you want for the complete, composite image. for 1.33 aspect, I suggest 1280.
int customCanvasHeight = 1080;  // set to any arbitrary height you want for ". for 1.33 aspect, I suggest 960.
int stopAtFrame = -1;   // Processing program will exit after this many animation frames. If set to a negative number, the program runs forever until you manually stop it. If set to 0 it makes 1 frame regardless, because of the way the draw() and exit() functions work: exit() waits for draw() to finish. 764 may be a good number for this if you use a positive value. NOTES: intended use with this value and a gridIterator class is that the gridIterator keeps making images over cell areas of nested finer grids until stopAtFrame is reached. If stopAtFrame is -1 then a gridIterator will be used until all intended elements in the grid are rendered. After a render completes, other globals control what happens: see notes for exitOnRenderComplete and renderVariantsInfinitely.
boolean exitOnRenderComplete = false;   // causes program to terminate after completion of first variant render, even if renderVariantsInfinitely is set to true
boolean renderVariantsInfinitely = false;   // causes program to render a new variant after the first one completes, and another after that, ad infinitum.
boolean saveLastFrameEveryVariant = false;    // causes program to use manualSaveFrame(); for the final frame of every variant. Useful for finding a favorite among many variants. (Including if stopAtFrame causes an early variant render stop.)
boolean saveLayers = true;    // set to true to enable layer rendering mode - saves each grid as a separate transparent layer
String layersOutputDir = "";           // will be set automatically with timestamp
color backgroundColorWithAlpha = color(144,145,145,255);   // alter the three integer RGB values and alpha in that to set the background color. For neutral (as perceived by humans) gray, set all three RGB values to 145.

// color array to randomly select from for fallback vector circles, OR for vector mode:
color[] colorsArray = {
  #FFFFFF, #EDEDED, #DBDCDC, #C9CACA, #B7B7B8, #A3A4A5, #909191,
  #7B7C7D, #656767, #4E5051, #353838, #191B1C,#000000
};

// END GLOBAL VARIABLES which you may alter

// GLOBALS NOT TO CHANGE HERE; program logic or the developer may change them in program runs or updates:
String scriptVersionString = "4-30-1";

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

// layer rendering globals
PGraphics[] layerBuffers;              // array to store each rendered layer (including background at index 0)
int currentGridIndex = 0;              // track which grid we're rendering
boolean layerRenderingComplete = false; // flag for when all layers are done
String layerTimestamp = "";             // timestamp for this layer set
int totalLayersWithBackground;          // total layers including background (grids count + 1)

// Cell state class for precomputed grid cells
class GridCell {
  int col, row;
  int xMin, xMax, yMin, yMax;
  int centerX, centerY;
  boolean active;  // whether this cell should render elements (based on skipCellChance)
  boolean rendered; // whether we've finished rendering this cell's elements
  int elementsDrawn; // count of elements drawn in this cell
  
  GridCell(int c, int r, int x1, int x2, int y1, int y2) {
    col = c;
    row = r;
    xMin = x1;
    xMax = x2;
    yMin = y1;
    yMax = y2;
    centerX = (xMin + xMax) / 2;
    centerY = (yMin + yMax) / 2;
    active = true; // default to active
    rendered = false;
    elementsDrawn = 0;
  }
}

// Grid iterator class that handles cell-by-cell rendering in random order
class GridIterator {
  // Grid dimensions
  int cols, rows;

  // minimum and maxium random alpha from 0 to 255; 0 is transparent (not visible at all), 255 is opaque (no transparency). For example to lock transparency at 126, set minAlpha and maxAlpha to 126. To have random alpha between 60 and 188, set minAlpha to 60 and 188. To always have an element fully opaque, set minimum and maximum both to 255:
  float minAlpha;
  float maxAlpha;

  float minScaleMultiplier;     // minimum amount to randomly scale images down to. It's a multiplier; for example if the source image width is 600, then 600 * 0.27 = 162 px minimum width. Suggested values: 0.15 to 0.27. If smaller max like 0.27, suggest this at 0.081.
  float maxScaleMultiplier;     // maximum amount to randomly scale images up to. Can constrain larger images to a smaller maximum. Not recommended to exceed 1, unless you anticipate images looking good scaled up.
  float minRotation;            // minimum random rotation range in degrees. May be negative or positive.
  float maxRotation;            // maximum random rotation range in degrees. May be negative or positive.
  float minSquishMultiplier;
  float maxSquishMultiplier;    // If you want a range that's stretched (or squished) and admitting normal, set this to 1. You can also set this to more than one to have "squished" to "stretch" range.
  boolean squishImages;             // if set to true, after image size is randomly proportionally scaled down, image widths and heights are further randomly altered without respect for maintaining aspect (a square may be squished or stretched to a rectangle), within constraints of minSquishMultiplier (minimum) to maxSquishMultiplier (maximum). If set to false, no squishing will occur and images will remain at original proportion. Note that you may set a maxSquishMultiplier below 1 for images to always be squished at least to some amount.

  int elementsPerCell;      // number of elements to draw per cell

  // Grid total boundaries; gridX1 and gridY1 are the coordinate of the upper left corner of the grid.
  int gridX1, gridY1, gridX2, gridY2;
  
  // Stickiness controls
  boolean useStickiness;         // master switch to enable/disable all stickiness behavior for this grid
  float skipStickiness;          // chance to skip cell when nearest cell in previous grid is active; NOTE that 0 means never skip cells in that case
  float renderStickiness;        // multiplier used with global skipDrawElementChance when nearest cell in previous grid is active; NOTE that 1 means never skip element render in that case

  String imagesPath;

  // Cell dimensions
  int cellWidth, cellHeight;

  ArrayList<PImage> allImagesList;
  int imagesArrayListLength;
  int widthOfImagesInArrayList;
  int heightOfImagesInArrayList;

  float skipCellChance;           // if nonzero there is a chance that a cell will be marked inactive
  float skipDrawElementChance;    // if nonzero there is a chance that when drawing it will skip drawing an element

  boolean circlesOverride;       // flag to use vector circles instead of images. Overridden to true if images load fails. Circle maximum diameter will be diagonal of cells times an overshoot.

  float elementOvershootMax;     // multiplier for random location range: 1 + overshoot value (converted from JSON input)
  
  // Cell management
  ArrayList<GridCell> cells;      // list of all cells in this grid
  int[] renderOrder;              // randomized order of cell indices
  int currentRenderPosition;      // position in renderOrder array
  boolean gridComplete;           // whether we've rendered all cells
  
  // Reference to previous grid for stickiness
  GridIterator previousGrid;

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
    minAlpha = gridJSON.getFloat("minAlpha");
    maxAlpha = gridJSON.getFloat("maxAlpha");
    minScaleMultiplier = gridJSON.getFloat("minScale");
    maxScaleMultiplier = gridJSON.getFloat("maxScale");
    minRotation = gridJSON.getFloat("minRotation");
    maxRotation = gridJSON.getFloat("maxRotation");
    minSquishMultiplier = gridJSON.getFloat("minSquish");
    maxSquishMultiplier = gridJSON.getFloat("maxSquish");
    squishImages = gridJSON.getBoolean("squishImages");
    imagesPath = gridJSON.getString("imagesPath");
    elementsPerCell = gridJSON.getInt("elementsPerCell");
    skipCellChance = gridJSON.getFloat("skipCellChance");
    skipDrawElementChance = gridJSON.getFloat("skipDrawElementChance");
    circlesOverride = gridJSON.getBoolean("circlesOverride");
    // STICKINESS CONTROLS - with assigned defaults (not from JSON)
    useStickiness = false;      // default
    skipStickiness = 0.234;     // default chance to skip cell; NOTE: if set to 0, it will NEVER skip a cell if the nearest cell in the previous grid is active
    renderStickiness = 0.265;   // default stickiness multiplier; NOTE: if set to 1, it will NEVER skip an element render for a cell if the nearest cell in the previous grid is active
    // Override stickiness values from JSON if present:
    if (gridJSON.hasKey("useStickiness") && !gridJSON.isNull("useStickiness")) {
      useStickiness = gridJSON.getBoolean("useStickiness");
    }
    if (gridJSON.hasKey("skipStickiness") && !gridJSON.isNull("skipStickiness")) {
      skipStickiness = gridJSON.getFloat("skipStickiness");
    }
    if (gridJSON.hasKey("renderStickiness") && !gridJSON.isNull("renderStickiness")) {
      renderStickiness = gridJSON.getFloat("renderStickiness");
    }

    // Convert elementOvershootMax from JSON (if present) to 1 + value
    if (gridJSON.hasKey("elementOvershootMax") && !gridJSON.isNull("elementOvershootMax")) {
      float overshootValue = gridJSON.getFloat("elementOvershootMax");
      elementOvershootMax = 1.0 + overshootValue;
      println("  elementOvershootMax set to " + elementOvershootMax + " (from input " + overshootValue + ")");
    } else {
      elementOvershootMax = 1.0; // Default to no overshoot
    }

    // initializes members to defaults for a state that's ready to start rendering:
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

    // check if images list empty; if so, create dummy values and fallback to circle vectors
    if (allImagesList.isEmpty()) {
      println("WARNING: No valid images found in " + imagesPath + ". Will use fallback circles.");
      circlesOverride = true;
      // Set these to dummy / default values since we won't be using actual images
      imagesArrayListLength = colorsArray.length - 1;    // -1 because it will be used with zero-based indexing

      // Set fallback circle dimensions; calculate cell diagonal for circumscribed circle size
      float cellDiagonal = sqrt(cellWidth * cellWidth + cellHeight * cellHeight);
      float circleDiameter = cellDiagonal * 1.32;   // that multiplier overshoots the diameter that circumscribes the rectangle
      widthOfImagesInArrayList = (int) circleDiameter;
      heightOfImagesInArrayList = (int) circleDiameter;
      println("  Fallback circle size set to " + (int) circleDiameter + " pixels (cell diagonal: " + (int) cellDiagonal + ")");
    } else {    //  otherwise set values derived from images:
      imagesArrayListLength = allImagesList.size() - 1;   // -1 because it will be used with zero-based indexing
      widthOfImagesInArrayList = allImagesList.get(0).width;
      heightOfImagesInArrayList = allImagesList.get(0).height;
    }
    
    // Initialize cells list
    cells = new ArrayList<GridCell>();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int x1 = gridX1 + c * cellWidth;
        int x2 = x1 + cellWidth;
        int y1 = gridY1 + r * cellHeight;
        int y2 = y1 + cellHeight;
        cells.add(new GridCell(c, r, x1, x2, y1, y2));
      }
    }
  }

  // Precompute which cells are active based on skipCellChance
  void precomputeActiveCells() {
    for (GridCell cell : cells) {
      // Random chance to mark cell inactive
      if (random(1) < skipCellChance) {
        cell.active = false;
      } else {
        cell.active = true;
      }
      cell.rendered = false;
      cell.elementsDrawn = 0;
    }
  }
  
  // Find cell in given grid closest to (x, y)
  GridCell findNearestCell(GridIterator grid, int x, int y) {
    if (grid == null || grid.cells == null || grid.cells.isEmpty()) return null;
    
    GridCell nearest = null;
    float minDist = Float.MAX_VALUE;
    
    for (GridCell cell : grid.cells) {
      float dist = dist(x, y, cell.centerX, cell.centerY);
      if (dist < minDist) {
        minDist = dist;
        nearest = cell;
      }
    }
    return nearest;
  }

  // Generate random order of cell indices for rendering
  int[] generateRandomRenderOrder() {
    int[] indices = new int[cells.size()];
    for (int i = 0; i < indices.length; i++) {
      indices[i] = i;
    }
    // Fisher-Yates shuffle
    for (int i = indices.length - 1; i > 0; i--) {
      int j = (int) random(i + 1);
      int temp = indices[i];
      indices[i] = indices[j];
      indices[j] = temp;
    }
    return indices;
  }

  // Initialize rendering for this grid
  void startRendering() {
    precomputeActiveCells();
    renderOrder = generateRandomRenderOrder();
    currentRenderPosition = 0;
    gridComplete = false;
  }

  // Get current cell we're working on (based on random render order)
  GridCell getCurrentCell() {
    if (renderOrder == null || currentRenderPosition >= renderOrder.length) return null;
    int cellIndex = renderOrder[currentRenderPosition];
    return cells.get(cellIndex);
  }

  // Mark current cell as having drawn an element
  void elementDrawnInCurrentCell() {
    if (currentRenderPosition < renderOrder.length) {
      int cellIndex = renderOrder[currentRenderPosition];
      GridCell cell = cells.get(cellIndex);
      cell.elementsDrawn++;
      
      // If we've drawn enough elements in this cell, move to next cell in random order
      if (cell.elementsDrawn >= elementsPerCell) {
        cell.rendered = true;
        currentRenderPosition++;
      }
    }
    
    // Check if we're done
    if (currentRenderPosition >= renderOrder.length) {
      gridComplete = true;
    }
  }

  boolean isComplete() {
    return gridComplete;
  }

  // Reset to start a new variant
  void reset() {
    gridComplete = false;
    currentRenderPosition = 0;
    renderOrder = null;
    
    // Reset all cells
    if (cells != null) {
      for (GridCell cell : cells) {
        cell.rendered = false;
        cell.elementsDrawn = 0;
        cell.active = true; // Will be properly set in precomputeActiveCells
      }
    }
  }
  
  void setPreviousGrid(GridIterator prev) {
    previousGrid = prev;
  }
}

// OUTSIDE SETUP, DECLARE ArrayList of GridIterators:
GridIterator grid_iterator;   // main instance of class to which instances in the following array will be assigned by reference for convenience
ArrayList<GridIterator> grid_iterators;    // grid_iterators to be used in succession
// END GLOBAL VARIABLES AND CLASSES to not alter


// Function that handles values etc. for new animated variant to be displayed;
// intended only to be called at the moment we know a render of a variant is complete:
void prepareNextVariant() {
  // DO NOT print completion messages here - this is for STARTING a variant, not completing one
  // The completion messages should only come from draw() when rendering actually finishes

  // handle setting up next variant
  if (doSeedOverride == true) {
    println("doSeedOverride true; overrideSeed value " + overrideSeed + " will be used to seed pseudorandom number generator.");
    seed = overrideSeed;
    // set this false so that the above only happens once
    doSeedOverride = false;
  } else {
    seed = (int) random(-2147483648, 2147483647);
  }

  // reset / reinitialize globals and objects:
  randomSeed(seed);

  // Initialize grids if needed
  if (grid_iterators == null) {
    initGrids();    // intended for first time, creates everything
    // Now start rendering all grids
    for (GridIterator g : grid_iterators) {
      g.startRendering();
    }
  } else {
    // subsequent variants - just reset existing grids:
    for (GridIterator g : grid_iterators) {
      g.reset();
      g.startRendering();
    }
  }
  
  // Set up grid relationships for stickiness
  if (grid_iterators != null && grid_iterators.size() > 0) {
    // First grid has no previous
    grid_iterators.get(0).setPreviousGrid(null);
    
    // Subsequent grids get previous grid reference
    for (int i = 1; i < grid_iterators.size(); i++) {
      grid_iterators.get(i).setPreviousGrid(grid_iterators.get(i-1));
    }
  }

  // Initialize layer rendering if enabled
  if (saveLayers) {
    initLayerRendering();
  } else {
    // Reset layer rendering state for non-layer mode
    layerBuffers = null;
    currentGridIndex = 0;
    layerRenderingComplete = false;
  }

  grid_iterator = null;
  if (grid_iterators != null && grid_iterators.size() > 0) {
    grid_iterator = grid_iterators.get(0);
  }
  clearTheCanvas = true;
  countedFrames = 0;
  allGridsRenderedFeedbackPrinted = false;  // Reset this for the new variant

  // Only call frameRate if saveFrames is false
  if (saveFrames == false) {
    if (useFrameRate == true) {
      frameRate(frameRate);
    }
  } else {
    animFramesSaveDir = "_imageBomber__anim_run__v" + scriptVersionString + "__seed__" + seed;
  }

  println(">> New variant prepared. Seed: " + seed);

  // Restart the draw loop if it was stopped
  if (!looping) {
    loop();
  }
}

// initialize layer rendering buffers and directories
void initLayerRendering() {
  // Create timestamp for this layer set
  int d = day();
  int m = month();
  int y = year();
  int h = hour();
  int min = minute();
  int s = second();
  layerTimestamp = String.format("%04d-%02d-%02d_%02d-%02d-%02d", y, m, d, h, min, s);

  // Create output directory
  layersOutputDir = sketchPath() + "/" + "_imageBomber__layers__v" + scriptVersionString + "__seed_" + seed;
  java.io.File dir = new java.io.File(layersOutputDir);
  if (!dir.exists()) {
    dir.mkdirs();
  }

  // Calculate total layers including background (grids + background at index 0)
  totalLayersWithBackground = grid_iterators.size() + 1;

  // Initialize layer buffers array (including space for background layer at index 0)
  layerBuffers = new PGraphics[totalLayersWithBackground];

  // Create and save background layer (index 0)
  layerBuffers[0] = createGraphics(width, height);
  layerBuffers[0].beginDraw();
  layerBuffers[0].background(backgroundColorWithAlpha);
  layerBuffers[0].endDraw();

  // Save background layer immediately
  String bgFilename = layersOutputDir + "/layer_00_background.png";
  layerBuffers[0].save(bgFilename);
  println("Saved background layer to: " + bgFilename);

  // Reset grid index and completion flag
  // Note: currentGridIndex of 1 means we're starting with first actual grid (index 1 in buffers array)
  currentGridIndex = 1;
  layerRenderingComplete = false;

  println("Layer rendering mode enabled. Output directory: " + layersOutputDir);
  println("Total layers (including background): " + totalLayersWithBackground);
  println("Will render " + grid_iterators.size() + " content layers.");
}

// save current layer buffer to file (adjusted for background at index 0)
void saveCurrentLayer(int bufferIndex) {
  if (bufferIndex < layerBuffers.length && layerBuffers[bufferIndex] != null) {
    String layerFilename;
    if (bufferIndex == 0) {
      layerFilename = layersOutputDir + "/layer_00_background.png";
    } else {
      // bufferIndex-1 to get the correct grid config (since grids start at index 1 in buffers)
      int gridConfigIndex = bufferIndex - 1;
      layerFilename = layersOutputDir + "/layer_" + String.format("%02d", bufferIndex) + "_" +
                     gridConfigsJSON.getJSONObject(gridConfigIndex).getString("name", "unnamed") + ".png";
    }
    layerBuffers[bufferIndex].save(layerFilename);
    println("Saved layer " + bufferIndex + " to: " + layerFilename);
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

// returns acquired float value if an investigated JSON field is non-null; otherwise returns the original value passed:
float setFloatFromJSON(float floatToSet, JSONObject configJSON, String fieldName) {
  if (configJSON.hasKey(fieldName) && !configJSON.isNull(fieldName)) {
    return configJSON.getFloat(fieldName);
  } else {
    return floatToSet;
  }
}


// obtains JSON values from "global_settings" object and, for any of them which do not have a null value, overiddes hard-coded globals in this script with their value from the corresponding JSON object's field; e.g. if the "saveFrames" field is "true" or "false" instead of null, it uses that "true" or "false" value:
void overrideGlobals() {
  try {
    if (allImportedJSON == null) {loadConfigurationJSON();}
    globalsConfigJSON = allImportedJSON.getJSONObject("global_settings");
    println("Global settings in-memory JSON object loaded successfully.");
    // Check if various keys (intended globals) exist and are not null; assign value from them if so:
    // fields for set~JSON functions:        boolean booleanToSet/int intToSet, JSONObject configJSON, String fieldName
    doSeedOverride =       setBooleanFromJSON(doSeedOverride, globalsConfigJSON, "doSeedOverride");
    overrideSeed =              setIntFromJSON(overrideSeed, globalsConfigJSON, "overrideSeed");
    saveFrames =                setBooleanFromJSON(saveFrames, globalsConfigJSON, "saveFrames");
    useFrameRate =              setBooleanFromJSON(useFrameRate, globalsConfigJSON, "useFrameRate");
    frameRate =                 setIntFromJSON(frameRate, globalsConfigJSON, "frameRate");
    useCustomCanvasSize =       setBooleanFromJSON(useCustomCanvasSize, globalsConfigJSON, "useCustomCanvasSize");
    customCanvasWidth =         setIntFromJSON(customCanvasWidth, globalsConfigJSON, "customCanvasWidth");
    customCanvasHeight =        setIntFromJSON(customCanvasHeight, globalsConfigJSON, "customCanvasHeight");
    stopAtFrame =               setIntFromJSON(stopAtFrame, globalsConfigJSON, "stopAtFrame");
    exitOnRenderComplete =      setBooleanFromJSON(exitOnRenderComplete, globalsConfigJSON, "exitOnRenderComplete");
    renderVariantsInfinitely =  setBooleanFromJSON(renderVariantsInfinitely, globalsConfigJSON, "renderVariantsInfinitely");
    saveLastFrameEveryVariant = setBooleanFromJSON(saveLastFrameEveryVariant, globalsConfigJSON, "saveLastFrameEveryVariant");
    saveLayers =                setBooleanFromJSON(saveLayers, globalsConfigJSON, "saveLayers");
    
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

// Helper function to estimate if an element would be visible on canvas; operates on assumption
// of an ellipse but ignores squishing, stretching or rotation
boolean isElementVisible(int xCenter, int yCenter, float elementWidth, float elementHeight) {
  // Calculate element edges
  float leftEdge = xCenter - elementWidth/2;
  float rightEdge = xCenter + elementWidth/2;
  float topEdge = yCenter - elementHeight/2;
  float bottomEdge = yCenter + elementHeight/2;

  // Padding to keep elements slightly
  int pad = 8;

  // Check if element is probably completely to the left of canvas plus pad distance
  if (rightEdge < pad) {return false;}
  // Check if element is probably completely to the right of canvas minus pad distance
  if (leftEdge > width - pad) {return false;}
  // Check if element is probably completely above canvas plus pad distance
  if (bottomEdge < pad) {return false;}
  // Check if element is probably completely below canvas minus pad distance
  if (topEdge > height - pad) {return false;}
  // If we passed all checks, element is probably at least partly visible
  return true;
}

// Unified rendering function that draws to any PGraphics target
void renderElementToTarget(PGraphics target, GridIterator grid, GridCell cell, float drawAlpha) {
  // Generate random scale first (needed for visibility check)
  float width_and_height_scalar = random(grid.minScaleMultiplier, grid.maxScaleMultiplier);
  float scaled_width = grid.widthOfImagesInArrayList * width_and_height_scalar;
  float scaled_height = grid.heightOfImagesInArrayList * width_and_height_scalar;

  // Apply squish if enabled (affects width only)
  if (grid.squishImages) {
    float widthSquishMultiplier = random(grid.minSquishMultiplier, grid.maxSquishMultiplier);
    scaled_width *= widthSquishMultiplier;
  }

  // For visibility check, use the larger dimension to be safe (since rotation could make either dimension matter)
  float maxElementDimension = max(scaled_width, scaled_height);

  // Find a visible position with overshoot
  int xCenter, yCenter;
  int attempts = 0;
  int maxAttempts = 12; // Prevent infinite loops

  do {
    // Calculate overshoot range based on cell bounds
    int xMinOvershoot = (int) (cell.xMin * grid.elementOvershootMax);
    int xMaxOvershoot = (int) (cell.xMax * grid.elementOvershootMax);
    int yMinOvershoot = (int) (cell.yMin * grid.elementOvershootMax);
    int yMaxOvershoot = (int) (cell.yMax * grid.elementOvershootMax);

    // Generate random position within overshoot range
    xCenter = (int) random(xMinOvershoot, xMaxOvershoot);
    yCenter = (int) random(yMinOvershoot, yMaxOvershoot);

    attempts++;

    // If we've tried too many times, just use the position (better to render something than infinite loop)
    if (attempts >= maxAttempts) {
      println("Warning: Could not find visible position after " + maxAttempts + " attempts");
      break;
    }
  } while (!isElementVisible(xCenter, yCenter, maxElementDimension, maxElementDimension));

  target.pushMatrix();
  target.translate(xCenter, yCenter);

  float randomRotateDegree = random(grid.minRotation, grid.maxRotation);
  target.rotate(radians(randomRotateDegree));

  // Draw element (image or circle)
  if (!grid.circlesOverride) {
    int rnd_imagesArray_idx = (int) random(0, grid.imagesArrayListLength + 1);
    target.tint(255, drawAlpha);
    target.image(grid.allImagesList.get(rnd_imagesArray_idx), 0, 0, scaled_width, scaled_height);
    target.noTint();
  } else {
    int colorIndex = (int) random(0, colorsArray.length);
    color originalColor = colorsArray[colorIndex];
    color transparentColor = color(red(originalColor), green(originalColor), blue(originalColor), drawAlpha);
    target.fill(transparentColor);
    target.noStroke();
    target.ellipse(0, 0, scaled_width, scaled_height);
  }

  target.popMatrix();
}

void draw() {
  // clear canvas at start of new variant
  if (clearTheCanvas) {
    background(backgroundColorWithAlpha);
    clearTheCanvas = false;
  }

  if (grid_iterators == null || grid_iterators.size() == 0) {
    println("ERROR: No grid iterators available.");
    noLoop();
    return;
  }

  // Find first incomplete grid
  GridIterator currentGrid = null;
  int gridIndex = -1;

  for (int i = 0; i < grid_iterators.size(); i++) {
    if (!grid_iterators.get(i).isComplete()) {
      currentGrid = grid_iterators.get(i);
      gridIndex = i;
      break;
    }
  }

  // If all grids are complete, handle variant completion
  if (currentGrid == null) {
    handleVariantCompletion();
    return;
  }

  // Check stop condition - only if we have a grid to render
  if (stopAtFrame > -1 && countedFrames >= stopAtFrame) {
    handleVariantCompletion();
    return;
  }

  // Get current cell (from random render order)
  GridCell currentCell = currentGrid.getCurrentCell();
  if (currentCell == null) {
    // No more cells in this grid, mark as complete
    currentGrid.gridComplete = true;
    return;
  }

  // Start with base skip chance
  float effectiveSkipChance = currentGrid.skipDrawElementChance;
  
  // Apply stickiness if enabled for this grid and we have a previous grid
  if (currentGrid.useStickiness && gridIndex > 0) {
    GridIterator prevGrid = currentGrid.previousGrid;
    if (prevGrid != null) {
      GridCell nearestPrev = currentGrid.findNearestCell(prevGrid, currentCell.centerX, currentCell.centerY);
      
      if (nearestPrev != null) {
        if (!nearestPrev.active) {
          // Lower cell is INACTIVE: chance to skip this entire cell based on this grid's skipStickiness
          if (random(1) < currentGrid.skipStickiness) {
            // Skip this cell entirely
            currentGrid.elementDrawnInCurrentCell(); // Mark as rendered (skipped)
            return;
          }
          // Otherwise proceed normally
        } else {
          // Lower cell is ACTIVE: reduce skip chance based on this grid's renderStickiness
          effectiveSkipChance = effectiveSkipChance * (1 - currentGrid.renderStickiness);
        }
      }
    }
  }
  
  // Apply skip chance
  if (random(1) < effectiveSkipChance) {
    // Skip drawing this element, but still count it for cell progression
    currentGrid.elementDrawnInCurrentCell();
    return;
  }

  // Generate random alpha once for this element
  float drawAlpha = random(currentGrid.minAlpha, currentGrid.maxAlpha);

  // Handle rendering based on mode
  if (saveLayers) {
    // LAYER MODE: Render to buffer only, then display composite
    int bufferIndex = gridIndex + 1; // +1 because buffer[0] is background

    // Handle layer transition
    if (bufferIndex > currentGridIndex) {
      // Save previous layer
      if (currentGridIndex < layerBuffers.length && layerBuffers[currentGridIndex] != null) {
        saveCurrentLayer(currentGridIndex);
      }
      currentGridIndex = bufferIndex;
    }

    // Create layer buffer if needed
    if (layerBuffers[bufferIndex] == null) {
      layerBuffers[bufferIndex] = createGraphics(width, height);
      layerBuffers[bufferIndex].beginDraw();
      layerBuffers[bufferIndex].imageMode(CENTER);
      layerBuffers[bufferIndex].smooth();
      layerBuffers[bufferIndex].background(0, 0, 0, 0); // Transparent
      layerBuffers[bufferIndex].endDraw();
    }

    // Render to layer buffer
    layerBuffers[bufferIndex].beginDraw();
    renderElementToTarget(layerBuffers[bufferIndex], currentGrid, currentCell, drawAlpha);
    layerBuffers[bufferIndex].endDraw();

    // Display composite preview (this is what user sees)
    pushMatrix();
    resetMatrix();
    imageMode(CENTER);

    // Clear main canvas and show all accumulated layers
    background(0); // Clear to black or any color
    image(layerBuffers[0], width/2, height/2); // background layer

    for (int i = 1; i <= currentGridIndex; i++) {
      if (layerBuffers[i] != null) {
        image(layerBuffers[i], width/2, height/2); // each content layer
      }
    }

    popMatrix();

  } else {
    // NORMAL MODE: Render directly to main canvas
    renderElementToTarget(g, currentGrid, currentCell, drawAlpha);
  }

  // Update grid state - mark that we drew an element in this cell
  currentGrid.elementDrawnInCurrentCell();

  // ALWAYS increment frame counter for EVERY element drawn
  countedFrames++;

  // ALWAYS save animation frame if enabled (works in BOTH modes)
  if (saveFrames) {
    String paddedFrameNumber = String.format("%06d", countedFrames);
    saveFrame(animFramesSaveDir + "/" + paddedFrameNumber + ".png");
  }
}


// helper function to handle variant completion consistently
void handleVariantCompletion() {
  // Print completion message once
  if (!allGridsRenderedFeedbackPrinted) {
    println("RENDERING COMPLETE (all grids done or stopAtFrame reached).");
    allGridsRenderedFeedbackPrinted = true;
    if (saveFrames) {
      println("Animation save frames are in the directory:\n  " + animFramesSaveDir);
    }
  }

  // Handle layer mode final saves
  if (saveLayers && !layerRenderingComplete) {
    // Save any unsaved layers
    for (int i = 0; i < layerBuffers.length; i++) {
      if (layerBuffers[i] != null) {
        saveCurrentLayer(i);
      }
    }
    layerRenderingComplete = true;
    println("All layers saved to: " + layersOutputDir);
  }

  // Save last frame if enabled (works in BOTH modes)
  if (saveLastFrameEveryVariant) {
    manualSaveFrame();
  }

  // Check if we should exit
  if (exitOnRenderComplete) {
    println("exitOnRenderComplete boolean set to true; program will exit.");
    exit();
    return;
  }

  // Handle next variant if enabled
  if (renderVariantsInfinitely) {
    println("Preparing next variant...");
    prepareNextVariant();
  } else {
    noLoop();
  }
}


// Updated manualSaveFrame to save composite ONLY to sketch folder (no redundant saves in layer folder)
void manualSaveFrame() {
  if (saveLayers) {
    // In layer mode, save composite image of all layers
    if (layerBuffers != null && layerBuffers.length > 0) {
      println("Layer mode active - saving composite image of all layers...");

      // Create composite from all layers
      PGraphics composite = createGraphics(width, height);
      composite.beginDraw();
      composite.imageMode(CENTER);
      composite.background(backgroundColorWithAlpha); // Start with background color

      // Render all layers in order (including background at 0, then content layers)
      for (int i = 0; i < layerBuffers.length; i++) {
        if (layerBuffers[i] != null) {
          composite.image(layerBuffers[i], width/2, height/2);
          println("  Added layer " + i + " to composite");
        }
      }

      composite.endDraw();

      // Save the composite with manual save naming (ONLY to sketch folder)
      String paddedFrameNumber = String.format("%06d", countedFrames);
      String saveFileName = "_imageBomber__v" + scriptVersionString + "__seed_" + seed + "_fr_" + paddedFrameNumber + ".png";
      composite.save(sketchPath() + "/" + saveFileName);
      println("Composite image saved to: " + saveFileName);

      // Display the composite briefly
      image(composite, width/2, height/2);
    } else {
      println("No layers available to composite yet.");
    }
  } else {
    // Original behavior for non-layer mode
    if (countedFrames != 0) {
      String paddedFrameNumber = String.format("%06d", countedFrames);
      String saveFileName = "_imageBomber__v" + scriptVersionString + "__seed_" + seed + "_fr_" + paddedFrameNumber + ".png";
      saveFrame(saveFileName);
      println("Image of current canvas saved to " + saveFileName);
    }
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
    println("Keypress of 'v' detected; ending current variant render and starting a new one . . .");
    prepareNextVariant();
  }
}