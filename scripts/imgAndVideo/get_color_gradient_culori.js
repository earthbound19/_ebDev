// DESCRIPTION
// Prints interpolated colors from -s (--start) to -e (--end) at -n (--number) even intervals, using the Oklab color space, via the culori npm (JavaScript / Nodejs) package. At this writing, Oklab does perceptual color modeling and changes better than any other color space I am aware of (including CIECAM02). Re: https://bottosson.github.io/posts/oklab/ -- https://raphlinus.github.io/color/2021/01/18/oklab-critique.html#update-2021-01-29

// DEPENDENCIES
// nodejs, with `culori` and `command` packages installed in the same directory as this script (via `npm install <package_name>`.

// USAGE
// See help printout from this command:
//    node get_color_gradient_culori.js --help
// --or see the `program` . . . `.requiredOption` and `.option` section in the source code.


// CODE
// main dependency
culori = require('culori');

// program options provenance and parsing
const { program } = require('commander');
var remove_start_color = false;
var remove_end_color = false;

program
  .requiredOption('-s, --start [RGB hex color code]', 'Start color for gradient. Expected format is RGB hex, but any other format which the culori.interpolate function can accept may work.')
  .requiredOption('-e, --end [RGB hex color code]', 'End color for gradient. Expected format is RGB hex, but any other format which the culori.interpolate function can accept may work.')
  .requiredOption('-n, --number [natural number > 2]', 'Number of colors in gradient.')
  .option('-f, --startColorRemove', 'Remove start (f)irst) color from gradient before print.')
  .option('-l, --endColorRemove', 'Remove end (l)ast) color from gradient before print.')
  .option('-r, --reverse', 'Reverse order of samples before print (effectively swaps the values of -s and -e).')
  .option('-d, --desaturateGradient', 'Overrides -e with a desaturated (gray, or no chroma) copy of -s, thereby producing a gradient from -s to the gray version of -s.');

program.parse();
const options = program.opts();

// COLOR SPACE DEFINITIONS AND RANGE NOTES
// Oklab channels and ranges available in this library, re: https://culorijs.org/color-spaces/
// oklab: the Oklab color space in Cartesian form.
// Channel, Range, Description
// l, [0, 1], Lightness
// a, [-0.233, 0.276]≈, Green–red component
// b, [-0.311, 0.198]≈, Blue–yellow component
//
// oklch: the Oklab color space in cylindrical form.
// Channel, Range, Description
// l, [0,1], Lightness
// c,	[0, 0.322]≈, Chroma
// h, [0, 360), Hue
//
// converter example (it knows that hex format here is RGB):
// let oklab = culori.converter('oklab');
// let parsed = oklab('#f800fc');
// console.log(parsed.l);
// TO DO: NOTE for other possible development? Color Difference and Nearest color(s) at: https://culorijs.org/api/

var start_color = options.start;
var end_color = options.end;
var number = options.number;

// alter end color to desaturated version of start color if a switch so commands:
var start_color_desaturated = {};
if (options.desaturateGradient) {
  start_color_desaturated = culori.oklch('f800fc');
  start_color_desaturated.c = 0;    // this is what changes that to gray; chroma = 0
  end_color = start_color_desaturated;
}

my_interpolator = culori.interpolate([start_color, end_color], 'oklab');
samples = culori.samples(number).map(my_interpolator).map(culori.formatHex);

if (options.startColorRemove) { samples.shift(); }
if (options.endColorRemove) { samples.pop(); }
if (options.reverse) { samples.reverse(); }

idx = 0;
while (idx < samples.length) {
  console.log(samples[idx]);
  idx += 1;
}


// DEV NOTE: The only way that I could get an interactive Nodejs terminal to include a globally installed package was:
// culori = require('C:/Users/<username>/AppData/Roaming/npm/node_modules/culori');