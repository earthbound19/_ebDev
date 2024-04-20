// DESCRIPTION
// Prints interpolated colors from -s (--start) to -e (--end) at -n (--number) even intervals, using the Oklab color space, via the culori npm (JavaScript / Nodejs) package. Additional options; see --help (USAGE).Re: https://bottosson.github.io/posts/oklab/ -- https://raphlinus.github.io/color/2021/01/18/oklab-critique.html#update-2021-01-29.

// SEE ALSO
//    `interpolateTwoSRGBColors_coloraide.sh` (can interpolate through many color spaces)

// DEPENDENCIES
// - nodejs, with a version of the `culori` module greater than `culori@0.20.1` (I think?), as this uses the CommonJS export of culori at `'culori/require'`.
// - You may have to install culori locally (in the same directory as this script) via `npm install <package_name>`, or globally, via `npm install -g <package_name>`.

// USAGE
// See help printout from this command:
//    node get_color_gradient_OKLAB.js --help
// --or see the `program` . . . `.requiredOption` and `.option` section in the source code.


// CODE
// main dependency; CommonJS export, re: https://culorijs.org/guides/migration/
culori = require('culori/require');

// START OPTIONS PARSING AND CHECKING
const { program } = require('commander');
program
  .requiredOption('-s, --start [RGB hex color code]', '\n\tStart color for gradient. Expected format is RGB hex \(without any pound or 0x hex symbols at the start\), but any other format which the culori.interpolate function can accept may work.\n')
  .requiredOption('-e, --end [RGB hex color code]', '\n\tEnd color for gradient. Expected format is RGB hex \(without any pound or 0x hex symbols at the start\), but any other format which the culori.interpolate function can accept may work.\n')
  .requiredOption('-n, --number [natural number > 2]', '\n\tNumber of colors in gradient. Note that this number includes the first and last color. Asking for 5 colors will give you the start color, three colors between it and the end color, and the end color: start + 3 + end = 5.\n')
  .option('-f, --startColorRemove [natural number > 0]', '\n\tRemoves the N (f)irst) colors from gradient before print.\n')
  .option('-l, --lastColorsRemove [natural number > 0]', '\n\tRemove the N (l)ast) colors from gradient before print.\n')
  .option('-r, --reverse', '\n\tReverse order of samples before print.\n')
  .option('-c, --chromaOverrideOnEndColor [number between 0, 0.322≈]', '\n\tOverrides chroma on -e (--end) color with float value provided with this switch. For example, if you pass \'-c 0\' (or zero), end color will have no chroma (it will be gray for that color). This would make gradient from the -s (--start) color to a perfect desaturation (gray) for the -e (--end) color. If the -s and -e colors are the same and you use -c 0, you will get a gradient of shades of the color to gray (and the gradient may be a better gradient than if you just use gray for the end color; the colors in the gradient may have more lightness and chroma on their way to gray).\n')
  .option('-b, --lightnessOverrideOnEndColor [number between 0 and 1]', '\n\tOverrides lightness on -e (--end) color with float value provided with this switch. For example, if you pass \'-b 0\' (or zero), end color will have no lightness (it will be black). This would cause a gradient from the -s (--start) color to a perfect shade (black) for the -e (--end) color. If the -s and -e colors are the same and you use -b 0, you will get a gradient of shades of the color to black (and the gradient may be a better gradient than if you just use black for the end color; the colors in the gradient may have more lightness and chroma on their way to black.\n')
  .option('-d, --deduplicateAdjacentSamples', '\n\tRemove adjacent duplicate samples before print. In other words, make it so that there are no duplicate colors next to each other. This could probably technically just be "remove duplicate colors," without any adjacency criteria, but was implemented with the adjacency criteria.\n')
program.parse();
const options = program.opts();
// if n < 3, abort with error as there's no point.
if (options.number < 2) { console.log("ERROR: -n < 2; no point in running script. Pass a number greater than 2. Will exit."); process.exit(1); }
// if --startColorRemove switch provided but won't work, throw error and exit:
if (
    (options.startColorRemove && isNaN(parseFloat(options.startColorRemove)))
    || options.startColorRemove < 1
  ) {console.log("ERROR: value for -f [--startColorRemove] not provided, or out of range. Should be provided and have a value between 1 and -n -1 (number of colors in gradient minus one). Script will exit.N"); process.exit(2);}
// if --lastColorsRemove switch provided but won't work, throw error and exit:
if (
    (options.lastColorsRemove && isNaN(parseFloat(options.lastColorsRemove)))
    || options.lastColorsRemove < 1
  ) {console.log("ERROR: value for -f [--lastColorsRemove] not provided, or out of range. Should be provided and have a value between 1 and -n -1 (number of colors in gradient minus one). Script will exit.N"); process.exit(3);}
// if --chromaOverrideOnEndColor switch provided but won't work, throw error and exit:
if (
    (options.chromaOverrideOnEndColor && isNaN(parseFloat(options.chromaOverrideOnEndColor)))
    || options.chromaOverrideOnEndColor < 0   // a user would have to work hard to pass this though.
  ) {console.log("ERROR: value for -c [--chromaOverrideOnEndColor] not provided, or can't be used as a float, or out of range. Should be provided and have a value between 0 and 0.322≈. Script will exit.N"); process.exit(4);}
// if --lightnessOverrideOnEndColor switch provided but won't work, throw error and exit:
if (
    (options.lightnessOverrideOnEndColor && isNaN(parseFloat(options.lightnessOverrideOnEndColor)))
    || options.lightnessOverrideOnEndColor > 1
    || options.lightnessOverrideOnEndColor < 0
  ) {console.log("ERROR: value for -b [--lightnessOverrideOnEndColor] not provided, or can't be used as a float, or out of range. Should be provided and have a value between 0 and 0.322≈. Script will exit.N"); process.exit(5);}
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
  var end_color_lightness_override = culori.oklch(options.end);
  end_color_lightness_override.l = options.lightnessOverrideOnEndColor;
  end_color = end_color_lightness_override;
}

// create color interpolation array;
// re: https://culorijs.org/api/#interpolate
// and re: https://culorijs.org/api/#samples
my_interpolator = culori.interpolate([start_color, end_color], 'oklab');
samples = culori.samples(number).map(my_interpolator).map(culori.formatHex);

// remove start and/or end colors if switches so command:
if (options.startColorRemove) {
  var i; for (i = 0; i < options.startColorRemove; i++) { samples.shift(); }
}
if (options.lastColorsRemove) {
  var j; for (j = 0; j < options.lastColorsRemove; j++) { samples.pop(); }
}
// reverse order of colors if switch so commands:
if (options.reverse) { samples.reverse(); }

// remove duplicate adjacent samples (array elements) if switch so commands:
if (options.deduplicateAdjacentSamples) {
// re: https://stackoverflow.com/a/54603424/1397555
  samples = samples.filter((i,idx) => samples[idx-1] !== i)
}

// print interpolated colors, one per line:
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

// At one point, the only way that I could get an interactive Nodejs terminal to include a globally installed package was:
// culori = require('C:/Users/<username>/AppData/Roaming/npm/node_modules/culori');