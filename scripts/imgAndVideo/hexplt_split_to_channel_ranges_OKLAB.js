// DESCRIPTION
// Groups colors in a .hexplt palette to nearest match of -n discrete ranges from Hue value 0 to 360, in okLab space. Writes resultant groups to new .hexplt files named after the original file plus additional range match information.

// DEPENDENCIES
// - nodejs, with a version of the `culori` module greater than `culori@0.20.1` (I think?), as this uses the CommonJS export of culori at `'culori/require'`.
// - you may have to install culori locally (in the same directory as this script) via `npm install <package_name>`, or globally, via `npm install -g <package_name>`.

// USAGE
// See help printout from this command:
//    node hexplt_split_to_channel_ranges_OKLAB.js --help
// --or see the `program` . . . `.requiredOption` and `.option` section in the source code.
// NOTES
// Maybe 43 is recommended for -n: to my eyes, at low chroma, that is about where colors as mapped in this space approach a useful "different enough" perceptual measurement. At high chroma, in some areas the distinctions become harder to decipher, and for all I know they may actually not be there.

// CODE
// TO DO:
// - update to do divisions over C or L, not just H, with parameter control of which.

// IMPORT
// main dependency; CommonJS export, re: https://culorijs.org/guides/migration/
culori = require('culori/require');
var fs = require('fs')

// START OPTIONS PARSING AND CHECKING, and globals init from options:
const { program } = require('commander');
program
  .requiredOption('-i --inputFile <fileName>', '\n\tInput palette file name (e.g. \'floral_print_00002.hexplt\'), which is a list of sRGB colors in hex format (e.g. #f800fc).\n')
  .requiredOption('-n, --numberOfHueDivisions [natural number > 2]', '\n\tNumber of hues to align colors from --inputFile to.\n')
program.parse();
const options = program.opts();

// if n < 2, abort with error as there's no point.
if (options.numberOfHueDivisions < 2) { console.log("ERROR: -n < 2; no point in running script. Pass a number greater than 1 for -n --numberOfHueDivisions. (But probably really around 7 or more at minimum?) Will exit."); process.exit(2); }
var numberOfHueDivisions = options.numberOfHueDivisions;

// ALSO get array of sRGB hex values from input file; print error if unable to read specified file:
var inputFileString = String(options.inputFile);
try {
  var inputFileContent = fs.readFileSync(inputFileString).toString();
}
catch(err) {
  console.log("\n\n!========\nERROR: unable to open specified -i --inputFile ", inputFileString, ". Exit.\n!========\n");
  process.exit(1);
}

// get a string which is the input filename minus extension, considering any string combined with dots to be the extension; an earlier version of this was inputFileString.replace(/[.*]*\..*/, ""), but I actually don't know why that works, haha, and the following works by making capture groups and explicitly replacing (keeping) only the 1st group:
var inputFileBasename = inputFileString.replace(/([^.*]*)(\..*)/, "$1");

const regexp = /#[a-fA-F0-9]{6}/g;
const searchResults = [...inputFileContent.matchAll(regexp)];
// init array of colors from file + regex search result:
var sourceColorsArray = [];
for (const element of searchResults) {
  sourceColorsArray.push(element[0]);
}

// string representation of channel to align colors to over intervals:
alignmentChannel = 'H'
// END OPTIONS PARSING AND CHECKING, and globals init from options

var divisor = 360 / numberOfHueDivisions;
var divisorDiv2 = divisor / 2;
var intervalValues = [];
for (var i = 0; i < numberOfHueDivisions; i++) {
	// the divisorDiv2 is to place the H (hue) value at a midpoint between discrete boundaries, meaning: if we divided 10 hues over H values from 0 to 10 (the real scale in this model is 0 to 360, but I'm scaling it down to 0-10 to make the example clearer), the H values that colors would be matched to by +- 0.5 would be:
	// [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5] (instead of [0, 1, 2 ..])
	// -- which results in any color with an H value from 0 to 1 matching the 1st hue division, 1 to 2 matching the 2nd division, 2 to 3 matching the 3rd, and so on.
	// OR, if we divide 360 into 360 hues, matches would be between 0 to 1, 1 to 2 . . . 359 to 360.
	intervalValue = (divisor * i) + divisorDiv2;
	intervalValues.push(intervalValue);
}

// converter that reads hex format as sRGB values, and creates converted data in oklch space:
let oklab = culori.converter('oklch');

// TO DO: value wrap (> 360 | < 0) handling.
let pmCHK = divisor / 2;
// declare array for inner loop adds of color to list:
let intervalAlignedColors = []
for (const interval of intervalValues) {
	// console.log("----- interval: " + interval + " -----")
	for (const sRGBcolor of sourceColorsArray) {
		// console.log("CHECK: " + sRGBcolor)
		let parsed = oklab(sRGBcolor);
		// dev test that will print the resultant converted objects:
		// console.log(parsed);
		// dev test that will print the object components, or channels:
		// console.log(parsed.l + " " + parsed.c + " " + parsed.h);
		// console.log("pmCHK:" + pmCHK + " h:" + parsed.h + " interval:" + interval)
		let pmCHKH = (interval - parsed.h) * -1
		if (pmCHKH >= 0 && pmCHKH <= pmCHK) {
			// console.log("\t (interval - parsed.h) * -1: " + pmCHKH)
			intervalAlignedColors.push(sRGBcolor)
		}
		let pmCHKL = (interval - parsed.h)
		if (pmCHKL >= 0 && pmCHKL <= pmCHK) {
			// console.log("\t (interval - parsed.h)     : " + pmCHKL)
			intervalAlignedColors.push(sRGBcolor)
		}
	}
	if (intervalAlignedColors.length > 0) {
		// reduce interval to three decimal places for file name part:
		var abridgedInterval = String(interval)
		abridgedInterval = abridgedInterval.replace(/([0-9]*\.[0-9]{3})(.*)/, "$1")
		// ridiculous things to get the decimal zero-padded for file name correct ordering:
		abridgedInterval = "000" + abridgedInterval
		startTrimPos = abridgedInterval.length - 7
		abridgedInterval = abridgedInterval.substring(startTrimPos, 10);	// 10 isn't always accurate and can be over but it works because the function takes amounts over, and it's never under :shrug:
		// reduce half of interval to three decimal places for file name part:
		var abridged_pmCHK = String(pmCHK)
		abridged_pmCHK = abridged_pmCHK.replace(/([0-9]*\.[0-9]{3})(.*)/, "$1")
		// construct file name that colors will be written to:
		writeFileName = inputFileBasename + "_oklabLCH_" + alignmentChannel + abridgedInterval + "+-" + abridged_pmCHK + ".hexplt"
		// write intervalAlignedColors to that file name:
		console.log("Writing colors for interval " + alignmentChannel + "~" + abridgedInterval + " to " + writeFileName + ". . .")
		var file = fs.createWriteStream(writeFileName);
		for (const color of intervalAlignedColors) {
			file.write(color + "\n")
		}
	}
	// empty that array for next run of inner loop:
	intervalAlignedColors = []
}