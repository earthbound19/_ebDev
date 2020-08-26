// DESCRIPTION
// This is in development, and not necessarily to my liking yet. Draws random straight lines connecting clusters of vertices in randomly arranged cells.

// USAGE
// Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.

// CODE
// by Richard Alexander Hall, Copyright and all rights reserved.
// TO DO:
// - fillet (bevel) corners, or more fancy/wonky things, by using curve(), curve_vertex(), or...?
// - save result to SVG file

// GLOBAL VARIABLES
int cols = 5;    // how many columns to divide the canvas into
int rows = 3;    // how many rows to divide the canvas into
boolean pickRNDcolsXrowsSizes = true;    // if true, maxRNDcols and maxRNDrows used
int maxRNDcols = 17; int maxRNDrows = 13;   // randomly picks from 2 to these values if pickRNDcolsXrowsSizes true
int RNDconnectPointsPerCell = 9;   // how many RND vectors (x,y coordinates) to obtain per area?
boolean pickRNDconnectPointsPerCell = true;   // if true, randomizes RNDconnectPointsPerCell up to maxRNDconnPoints
int maxRNDconnPoints = 11;
float previous_point_x, previous_point_y;   // tried that as PVector but memory wonkiness (I think) interfered)
int columnWidth;    // will be int(width / cols via setup()
int rowHeight;    // will be int(height / rows via setup()
rectangularRegion[] rectangularRegions;   // array of point tuples defining rectangualr regions
IntList regions_indices = new IntList();    // will end up length (or size) cols * rows
int regions_indices_length;
int regions_counter = 0;    // reused in at least two functions
int regions_idx = 0;    // for iterating through values of IntList regions_indices
float framesPerSecond = 12;   // human viewing speed: 12?
float globalLineStrokeWeight = 2.82;
boolean make_variants_infinitely = true;   // if true, a new variant is drawn immediately after one completes, and so on forever.
color bg_color = #00ffff;
color light_stroke_color = #0EDEED;
// possibilities for lighter stroke color: #0EDEED #1DBCDA #2B9BC8 #3A77B4 #4856A2 #573590
color dark_stroke_color = #66117c;
float percent_dark_stroke = 0.24;   // percent of lines that are dark (at tail end of scribbles)
int change_to_foreground_stroke_at_index;
// END GLOBAL VARIABLES



// START GLOBAL SUPPLEMENTAL FUNCTIONS
// has vectors that give an upper left corner x and y, and a lower right corner x and y:
class rectangularRegion {
  PVector UL_xy;
  PVector LR_xy;
  rectangularRegion(PVector UL_xy_param, PVector LR_xy_param) {
    UL_xy = new PVector(UL_xy_param.x, UL_xy_param.y);
    LR_xy = new PVector(LR_xy_param.x, LR_xy_param.y);
  }
}

// returns RND PVector within the (intended) rectangular area of two PVectors. 
PVector RNDpvectorWithinArea(PVector upper_left, PVector lower_right) {
  int RNDx = int(random(upper_left.x, lower_right.x));
  int RNDy = int(random(upper_left.y, lower_right.y));
  //print(RNDx + "," + RNDy + "\n");
  return new PVector(RNDx, RNDy);
}

// called first by setup(), then
// TO DO: repeatedly called after rnd delay interval:
void prepare_next_variant() {
  if (regions_counter == regions_indices_length && make_variants_infinitely == true) {
    background(bg_color);
    regions_counter = 0;
    stroke(light_stroke_color);
    regions_indices.clear();
  
    // if boolean says to, override hard-coded cols and rows with rnd selection of them in range:
    // NOTE that the minimum in the following MUST be 2, or errors will occur:
    if (pickRNDcolsXrowsSizes == true) {
      cols = int(random(2, maxRNDcols + 1));		// +1 because random() doesn't include max of range
      rows = int(random(2, maxRNDrows + 1));		// +1 because random() doesn't include max of range
    }
    // if boolean says to, randomize RNDconnectPointsPerCell:
    if ( pickRNDconnectPointsPerCell == true) {
      RNDconnectPointsPerCell = int(random(2, maxRNDconnPoints + 1));    // + 1 because RND not include max
    }
    
    columnWidth = int(width / cols);
    rowHeight = int(height / rows);
    // init rectangularRegion array:
    rectangularRegions = new rectangularRegion[cols * rows];
    int rowsLoop = 0; int colsLoop = 0;
    while (rowsLoop < rows) {
      while (colsLoop < cols) {
        int UL_x = int(colsLoop * columnWidth); int UL_y = int(rowsLoop * rowHeight); 
            // print("UL.x " + UL_x + " UL.y: " + UL_y + "\n");
        int LR_x = int((colsLoop * columnWidth) + columnWidth);
        int LR_y = int((rowsLoop * rowHeight) + rowHeight);
            // print("LR.x " + LR_x + " LR.y: " + LR_y + "\n\n");
        PVector UL_xy_param = new PVector(UL_x, UL_y);
        PVector LR_xy_param = new PVector(LR_x, LR_y);
        rectangularRegions[regions_counter] = new rectangularRegion(UL_xy_param, LR_xy_param);
        colsLoop += 1;
        regions_indices.append(regions_counter);
        regions_counter += 1;
      }
    colsLoop = 0;
    rowsLoop += 1;
    }
    
    // init "previous" point x and y with rnd x,y from first region:
    PVector tmp_vec = RNDpvectorWithinArea(
      rectangularRegions[0].UL_xy,
      rectangularRegions[0].LR_xy
      ); previous_point_x = tmp_vec.x; previous_point_y = tmp_vec.y;
  
    regions_indices_length = regions_indices.size();
    change_to_foreground_stroke_at_index = int(regions_indices_length * (1 - percent_dark_stroke));
    regions_counter = 0;
    regions_indices.shuffle();
  }
}

void draw_iteration() {
  // iterate through rectangular region, creating and drawing through RNDconnectPointsPerCell
  // per region:
  if (regions_counter < regions_indices_length) {
    // change to foreground stroke color if at threshold:
    if (regions_counter == change_to_foreground_stroke_at_index) {
        stroke(dark_stroke_color);
    }
    // this only does anything other than left to right scan because regions_indices is shuffled:
    regions_idx = regions_indices.get(regions_counter);
            // test code to verify full iteration through and corners of regions; ALTHOUGH,
            // it's actually pretty interesting as potentially adding to the art itself:
            fill(0,255,255);
            ellipse(
              rectangularRegions[regions_idx].UL_xy.x, rectangularRegions[regions_idx].UL_xy.y,
              30, 30
              );
            fill(255,0,255);
            ellipse(
              rectangularRegions[regions_idx].LR_xy.x, rectangularRegions[regions_idx].LR_xy.y,
              15, 15
              );
    // declare and init list of random vertices within this rectangular region.
    PVector[] vertices = new PVector[RNDconnectPointsPerCell];
    for (int i = 0; i < RNDconnectPointsPerCell; i++) {
      vertices[i] = RNDpvectorWithinArea(   // this is a function call.
        rectangularRegions[regions_idx].UL_xy,
        rectangularRegions[regions_idx].LR_xy
        );
    }
// MY INTENDED ALTERATIONS, using curve function; reference:
//curve(cpx1, cpy1, x1, y1, x2, y2, cpx2, cpy2);
//cpx1, cpy1  Coordinates of the first control point
//x1, y1  Coordinates of the curve’s starting point
//x2, y2  Coordinates of the curve’s ending point
//cpx2, cpy2  Coordinates of the second control point
//MY INTENDED USE:
//(cpx1, cpy1), (x1, y1) different. (x2, y2), (cpx2, cpy2) same.
//then (cpx2, cpy2) are (cpx1, cpy1).
    line(previous_point_x, previous_point_y, vertices[0].x, vertices[0].y);
    // that declared, use the vertices to draw things with them:
    int vertices_array_length = vertices.length;
    for (int j = 1; j < vertices_array_length; j++) {
      line(vertices[j - 1].x, vertices[j - 1].y, vertices[j].x, vertices[j].y);
      //curve(previous_point_x, previous_point_y, vertices[0].x, vertices[0].y, vertices[j].x, vertices[j].y, vertices[j].x, vertices[j].y);
      previous_point_x = vertices[j].x; previous_point_y = vertices[j].y;    // redundant use but unavoidable
      }
    regions_counter += 1;
    // print("Drew an iteration.\n");
  }
}
// END GLOBAL SUPPLEMENTAL FUNCTIONS


// MAIN FUNCTIONALITY
void setup() {
  fullScreen();
  // size(1200, 800);
  ellipseMode(CENTER);
  noFill();
  stroke(light_stroke_color);
  strokeWeight(globalLineStrokeWeight);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  frameRate(framesPerSecond);
  background(bg_color);
  prepare_next_variant();
}


void draw() {
  draw_iteration();
}

//void keyPressed() {
//  prepare_next_variant();
//}

void mousePressed() {
  prepare_next_variant();
}
