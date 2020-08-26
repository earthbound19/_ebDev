// DESCRIPTION
// This is in development and not useful yet.
// Creates color observation fields of all possible permutations of a list of colors (choosing 3 colors from the list), after a field model diagram I found for the CIECAM02 color observation model. At this writing, it renders all of them very rapidly and quits; it will be useful when it saves svgs and/or pngs of them.

// USAGE
// - Open this file in the Processing IDE (or anything else that can run a Processing file).
// - Copy an adapted list of RGB hex color codes into the color[] palette array.
// - Run the program with the triangle "Play" button.


// CODE

// DEV NOTES
// reference img: 400px wide

//adapted from (and using the same library) : https://github.com/fjenett/combinatorics/blob/master/examples/combinationSets_1/combinationSets_1.pde
import de.bezier.math.combinatorics.*;

color surround_color = color(127,127,127);
// GLOBAL VARIABLES if we want to imitate things about the file CIECAM02_inputs.svg;
// these values are from examining a reference SVG in inkscape. The reference svg is at:
// color_field.svg, renamed from https://upload.wikimedia.org/wikipedia/commons/0/0e/CIECAM02_inputs.svg :
float color_background_shape_diameter_multiplier = 0.807374333861443;
float color_background_shape_diameter;
color background_shape_color = color(191,191,191);
//float color_stimulus_shape_diameter_multiplier = 0.107158288924096;
//OR if we want to imitate inset_square_with_same_area_as_frame.svg; where the length of the outer square is 1930.872px and the innner 1368.333;
//in that case comment out the previous line and uncomment the next:
float color_stimulus_shape_diameter_multiplier = 0.708660646588692;
float color_stimulus_diameter;
color stimulus_shape_color = color(204,255,51);

color[] palette = { #CA4587, #62555E, #FDFD96, #7FFFD4, #32127A };

// if we want all possible different orders of a set of things (not just to know how many things),
// we're talking about permutations. re: https://medium.com/i-math/combinations-permutations-fa7ac680f0ac
Combination combinations = new Combination( palette.length, 3 );
Permutation permutation = new Permutation( palette.length );
// END GLOBAL VARIABLES

void setup() {
  //original reference svg size: 381.865 x 381.865:
  size(800, 800);
  shapeMode(CENTER);
  rectMode(CENTER);
  strokeWeight(0);
  //frameRate(1);
  noLoop();
}


void draw() {
  background(40);
  if ( permutation.hasMore() )
  {
    thread("permute_and_render");    // function called in new thread and has delay; because this block starts with an "if," that delay will be effective
  fill(background_shape_color);
  //rect(height/2, width/2, width * color_stimulus_shape_diameter_multiplier, height * color_stimulus_shape_diameter_multiplier, height/2*0.085);
  rect(50, 50, 50, 50);
  fill(stimulus_shape_color);
  rect(100, 100, 50, 50);
  } else {
    print("Permutation work done.\n");
    exit();
  }
}


void permute_and_render() {
  noLoop();
  int[] p = permutation.next();
  print(p + " " + p.length + "\n");
  background_shape_color = palette[p[0]];
  stimulus_shape_color = palette[p[1]];
  delay(5);
  loop();
}
