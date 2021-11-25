// DESCRIPTION
// Prints sRGB hex color values with altered Lightness, and/or Chroma, and/or Hue of every color from a .hexplt file -i (input), by parameters -l, -c and/or -h (as transforms from OKLAB color space). Tweaks are by float values between 0 and 1 for l (L), 0 to 0.322 for c, and 0 to 360 for h. Values may be negative or positive. Requires an input .hexplt file, which is a list of sRGB colors expressed in hexadecimal. At this writing, Oklab does perceptual color modeling and changes better than any other color space I am aware of (including CIECAM02). Re: https://bottosson.github.io/posts/oklab/ -- https://raphlinus.github.io/color/2021/01/18/oklab-critique.html#update-2021-01-29

// DEPENDENCIES
// nodejs, with `culori@0.20.1`
// NOTES
// - Anything past that version breaks this and will require a rewrite of this script!) and `command` packages installed.
// - You may have to install culori locally (in the same directory as this script) via `npm install <package_name>`, or globally, via `npm install -g <package_name>`.

// USAGE
// See help printout from this command:
//    node print_altered_hexplt_OKLAB.js --help
// --or see the `program` . . . `.requiredOption` and `.option` section in the source code.
// To save the result to a new file, use a redirection operator, e.g.:
//    node /path/to/script/print_altered_hexplt_OKLAB.js -i 'floral_print_00002.hexplt' -c 0.018 -l 0.068 -h 12 > floral_print_00002_more_lively_more_orange.hexplt


// CODE
// main dependency:
culori = require('culori');
var fs = require("fs")

// START OPTIONS PARSING AND CHECKING
const { program } = require('commander');
program
  // the <fileName> thing here leads to capture of a series of values (file name):
  .requiredOption('-i --inputFile <fileName>', '\n\tInput palette file name (e.g. \'floral_print_00002.hexplt\'), which is a list of sRGB colors in hex format (e.g. #f800fc).\n')
  .option('-l, --lightness <digits>', '\n\tAmount to change lightness, from 0 to 1 (percent expressed as decimal). May be negative or positive.\n')
  .option('-c, --chroma <digits>', '\n\tAmount to change chroma, from 0 to 0.322. (Yes, the scale is wonky.) May be negative or positive.\n')
  .option('-h, --hue <digits>', '\n\tAmount to change hue, from 0 to 360. May be negative or positive.\n')
program.parse();
const options = program.opts();

// convert input file parameter to the string it's intended to be:
inputFileString = String(options.inputFile);
// console.log(inputFileString)

// get array of sRGB hex values from input file;
// print error if unable to read specified file:
try {
  var inputFileContent = fs.readFileSync(inputFileString).toString();
}
catch(err) {
  console.log("\n\n!========\nERROR: unable to open specified -i --inputFile ", inputFileString, ". Exit.\n!========\n");
}

const regexp = /#[a-f0-9]{6}/g;
// const str = '#f2aece floarif #002139 bepfj #4a2e3f';
const searchResults = [...inputFileContent.matchAll(regexp)];
// resulting structure is: searchResults[arrayIndex][hexStringIWant]
var RGBhexColors = [];
for (const element of searchResults) {
  RGBhexColors.push(element[0]);
  // console.log(element[0]);
}

let okLCHconverter = culori.converter('oklch');
let sRGBconverter = culori.converter('rgb');

// alter lightness of each color if a switch so commands:
if (options.lightness) {
  var modRGBhexColors = [];
  for (const color of RGBhexColors) {
    let okLCHcolor = okLCHconverter(color);
    okLCHcolor.l += parseFloat(options.lightness);
	  // force back in range if out of range:
	  if (okLCHcolor.l < 0) {okLCHcolor.l = 0;}
	  if (okLCHcolor.l > 1) {okLCHcolor.l = 1;}
    let newRGBcolor = sRGBconverter(okLCHcolor)
    modRGBhexColors.push(culori.formatHex(newRGBcolor))
  }
  // overwrite RGBhexColors[] with modified ones:
  RGBhexColors = modRGBhexColors;
}

// alter chroma of each color if a switch so commands:
if (options.chroma) {
  var modRGBhexColors = [];
  for (const color of RGBhexColors) {
    let okLCHcolor = okLCHconverter(color);
    okLCHcolor.c += parseFloat(options.chroma);
	  // force back in range if out of range:
	  if (okLCHcolor.c < 0) {okLCHcolor.c = 0;}
	  if (okLCHcolor.c > 0.322) {okLCHcolor.c = 0.322;}
    let newRGBcolor = sRGBconverter(okLCHcolor)
    modRGBhexColors.push(culori.formatHex(newRGBcolor))
  }
  // overwrite RGBhexColors[] with modified ones:
  RGBhexColors = modRGBhexColors;
}

// alter hue of each color if a switch so commands:
if (options.hue) {
  var modRGBhexColors = [];
  for (const color of RGBhexColors) {
    let okLCHcolor = okLCHconverter(color);
    okLCHcolor.h += parseFloat(options.hue);
      if (okLCHcolor.h > 360) {
        // remainder after division by 360 is value to wrap it at (above zero):
        okLCHcolor.h = (okLCHcolor.h % 360);		// % is modulo (remainder) operator
      } else if (okLCHcolor.h < 0) {
        // remainder after division by 360 is value to wrap it around (below zero):
        okLCHcolor.h = 360 + (okLCHcolor.h % 360)
      }
    let newRGBcolor = sRGBconverter(okLCHcolor)
    modRGBhexColors.push(culori.formatHex(newRGBcolor))
  }
  // overwrite RGBhexColors[] with modified ones:
  RGBhexColors = modRGBhexColors;
}

for (const color of RGBhexColors) {
  console.log(color);
}


// DEV NOTES:
// Oklab channels and ranges available in this library, re: https://culorijs.org/color-spaces/
// oklch: the Oklab color space in cylindrical form.
// Channel, Range, Description
// l, [0,1], Lightness
// c,	[0, 0.322]≈, Chroma
// h, [0, 360), Hue