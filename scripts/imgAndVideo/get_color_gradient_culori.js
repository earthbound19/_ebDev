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

// START OPTIONS PARSING AND CHECKING
const { program } = require('commander');
var remove_start_color = false;
var remove_end_color = false;
program
  .requiredOption('-s, --start [RGB hex color code]', '\n\tStart color for gradient. Expected format is RGB hex, but any other format which the culori.interpolate function can accept may work.\n')
  .requiredOption('-e, --end [RGB hex color code]', '\n\tEnd color for gradient. Expected format is RGB hex, but any other format which the culori.interpolate function can accept may work.\n')
  .requiredOption('-n, --number [natural number > 2]', '\n\tNumber of colors in gradient.\n')
  .option('-f, --startColorRemove [natural number > 0]', '\n\tRemoves the N (f)irst) colors from gradient before print.\n')
  .option('-l, --endColorRemove [natural number > 0]', '\n\tRemove the N (l)ast) colors from gradient before print.\n')
  .option('-r, --reverse', '\n\tReverse order of samples before print.\n')
  .option('-c, --chromaOverrideOnEndColor [number between 0, 0.322≈]', '\n\tOverrides chroma on -e (--end) color with float value provided with this switch. For example, if you pass \'-c 0\' (or zero), end color will have no chroma (it will be gray for that color). This would make gradient from the -s (--start) color to a perfect desaturation (gray) for the -e (--end) color. If the -s and -e colors are the same and you use -c 0, you will get a gradient of shades of the color to gray (and the gradient may be a better gradient than if you just use gray for the end color; the colors in the gradient may have more lightness and chroma on their way to gray).\n')
  .option('-b, --lightnessOverrideOnEndColor [number between 0 and 1]', '\n\tOverrides lightness on -e (--end) color with float value provided with this switch. For example, if you pass \'-b 0\' (or zero), end color will have no lightness (it will be black). This would cause a gradient from the -s (--start) color to a perfect shade (black) for the -e (--end) color. If the -s and -e colors are the same and you use -b 0, you will get a gradient of shades of the color to black (and the gradient may be a better gradient than if you just use black for the end color; the colors in the gradient may have more lightness and chroma on their way to black.\n')
program.parse();
const options = program.opts();
// if n < 3, abort with error as there's no point.
if (options.number < 3) { console.log("ERROR: -n < 2; no point in running script. Pass a number greater than 2. Will exit."); process.exit(1); }
// if --startColorRemove switch provided but won't work, throw error and exit:
if (
    (options.startColorRemove && isNaN(parseFloat(options.startColorRemove)))
    || options.startColorRemove < 1
  ) {console.log("ERROR: value for -f [--startColorRemove] not provided, or out of range. Should be provided and have a value between 1 and -n -1 (number of colors in gradient minus one). Script will exit.N"); process.exit(1);}
// if --endColorRemove switch provided but won't work, throw error and exit:
if (
    (options.endColorRemove && isNaN(parseFloat(options.endColorRemove)))
    || options.endColorRemove < 1
  ) {console.log("ERROR: value for -f [--endColorRemove] not provided, or out of range. Should be provided and have a value between 1 and -n -1 (number of colors in gradient minus one). Script will exit.N"); process.exit(1);}
// if --chromaOverrideOnEndColor switch provided but won't work, throw error and exit:
if (
    (options.chromaOverrideOnEndColor && isNaN(parseFloat(options.chromaOverrideOnEndColor)))
    || options.chromaOverrideOnEndColor < 0   // a user would have to work hard to pass this though.
  ) {console.log("ERROR: value for -c [--chromaOverrideOnEndColor] not provided, or can't be used as a float, or out of range. Should be provided and have a value between 0 and 0.322≈. Script will exit.N"); process.exit(1);}
// if --lightnessOverrideOnEndColor switch provided but won't work, throw error and exit:
if (
    (options.lightnessOverrideOnEndColor && isNaN(parseFloat(options.lightnessOverrideOnEndColor)))
    || options.lightnessOverrideOnEndColor > 1
    || options.lightnessOverrideOnEndColor < 0
  ) {console.log("ERROR: value for -b [--lightnessOverrideOnEndColor] not provided, or can't be used as a float, or out of range. Should be provided and have a value between 0 and 0.322≈. Script will exit.N"); process.exit(1);}
// END OPTIONS PARSING AND CHECKING

var start_color = options.start;
var end_color = options.end;
var number = options.number;

// alter chroma of end color if a switch so commands:
if (options.chromaOverrideOnEndColor) {
  let end_color_chroma_override = culori.oklch(options.end);
  end_color_chroma_override.c = options.chromaOverrideOnEndColor;
  end_color = end_color_chroma_override;
}

// alter lightness of end color if a switch so commands:
if (options.lightnessOverrideOnEndColor) {
  let end_color_lightness_override = culori.oklch(options.end);
  end_color_lightness_override.l = options.lightnessOverrideOnEndColor;
  end_color = end_color_lightness_override;
}

// create color interpolation array:
my_interpolator = culori.interpolate([start_color, end_color], 'oklab');
samples = culori.samples(number).map(my_interpolator).map(culori.formatHex);

// remove start and/or end colors if switches so command:
if (options.startColorRemove) {
  var i; for (i = 0; i < options.startColorRemove; i++) { samples.shift(); }
}
if (options.endColorRemove) {
  var j; for (j = 0; j < options.endColorRemove; j++) { samples.pop(); }
}
// reverse order of colors if switch so commands:
if (options.reverse) { samples.reverse(); }

// print inerpolated colors, on per line:
idx = 0;
while (idx < samples.length) {
  console.log(samples[idx]);
  idx += 1;
}


// DEV NOTES:
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

// - The only way that I could get an interactive Nodejs terminal to include a globally installed package was:
// culori = require('C:/Users/<username>/AppData/Roaming/npm/node_modules/culori');