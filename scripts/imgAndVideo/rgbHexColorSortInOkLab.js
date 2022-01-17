// DESCRIPTION
// Takes an input sRGB hex color list (in .hexplt format) and sorts the colors in it by next nearest perceptual distance in the okLab color space. (Tries to group colors by most similar in a list.) Does not write the result to any file; you'll need to redirect to do that (see NOTES under USAGE). NOTE THAT THIS IS BLAZING FAST compared to the rgbHex ~sort.py scripts.

// DEPENDENCIES
// nodejs with the culori library installed.

// USAGE
// See help printout from this command, substituting /path/to/this with the actual path to this script on your system:
//    node /path/to/this/rgbHexColorSortInOkLab.js --help
// --or see the `program` . . . `.requiredOption` and `.option` section in the source code.
// NOTES
// To save the result to a new file, use a redirection operator, e.g.:
//    node /path/to/this/rgbHexColorSortInOkLab.js -i 'all_humanae.hexplt' > humanae.hexplt


// CODE
// TO DO: option to sort on arbitrary first color, but don't add to output print if the color is not in the input file. But keep it if it's in the original input file.
// DEV NOTE: OH HOW BADLY I WANTED TO FIND A PYTHON LIBRARY that works with okLab + does distance calculations (DeltaE) between colors and adapt one of the Python color sorting scripts to do that, because OH MY UNHOLY NACHOS OF WRATH this was so, so, SOOOOO much more difficult to implement in JavaScript. But no such Python library exists, that I could find. okLab is in development for colour-science as of winter 2021..

// DEPENDENCIES (INCLUDES)
// CommonJS export of culori, re: https://culorijs.org/guides/migration/
culori = require('culori/require');
var fs = require('fs');
const { program } = require('commander');

// START OPTIONS PARSING AND CHECKING
program
  // the <fileName> thing here leads to capture of a series of values (file name):
  .requiredOption('-i --inputFile <fileName>', '\n\tInput palette file name (e.g. \'floral_print_00002.hexplt\'), which is a list of sRGB colors in hex format (e.g. #f800fc).\n')
  // .requiredOption('-f, --firstComparisonColor <digits>', '\n\tFirst color to start comparisons with, in sRGB hex format (e.g. 0a000a\n')
program.parse();
const options = program.opts();
// convert input file parameter to the string it's intended to be:
const inputFileString = String(options.inputFile);
// also first comparison color:
// var compareColorSrgbHex = String(options.firstComparisonColor);

// get array of sRGB hex values from input file:
try {
  var inputFileContent = fs.readFileSync(inputFileString).toString();
}
// print error if unable to read specified file:
catch(err) {
  console.log("\n\n!========\nERROR: unable to open specified -i --inputFile ", inputFileString, ". Exit.\n!========\n");
  process.exit(1);
}

// get array of sRGB hex format colors from the file:
const regexp = /#[a-fA-F0-9]{6}/g;
const searchResults = [...inputFileContent.matchAll(regexp)];
// init array of colors from file + regex search result:
var colorsArray = [];
for (const element of searchResults) {
  colorsArray.push(element[0]);
}
// get a color space converter function varaible noun noun noun noun (okLCHconverter):
let okLCHconverter = culori.converter('oklch');

// this returns a function, which function returns (creates) a Euclidiean distance function for okLCH; re: https://culorijs.org/api/#differenceEuclidean :
okLCHdistance = culori.differenceEuclidean(mode = 'oklch', weights = [1, 1, 1]);
// END OPTIONS PARSING AND CHECKING


// MAIN LOGIC
// Using measure of okLCH components (as it should "just work," per design of the perceptually uniform color space, re https://en.wikipedia.org/wiki/Color_difference#Uniform_color_spaces
// Testing this out demonstrates that it works: if sRGB hex #000000 and #ffffff are the first two in the list, their distance is calculated at 0.9999999934735462 (practically 1) and if the first two are both #000000, their distance is calculated at 0:

// init final sort list (as empty):
finalSortedList = [];
// Add first item to final list, as the first item will be the first in the original list; colorsArray[0].sRGBhex and searchResults[0][0] SHOULD both be the first color in the list:
finalSortedList.push(colorsArray[0]);

while (finalSortedList.length < searchResults.length) {
	var sRGB_hex_A = colorsArray[0];
	var sRGB_hex_B;
	var okLCHval_A = okLCHconverter(colorsArray[0]);
	var okLCHval_B;
	var okDist = 58848;								// way beyond any distance that will be found.
	var lowestFoundDistanceForThisPair = 58849;		// "
	var nearestFoundColorHEX;
	// figuring out this i = 1 (not zero) was the final thing that finished this script:
	for (var i = 1; i < colorsArray.length; i++) {
		sRGB_hex_B = colorsArray[i]
		okLCHval_B = okLCHconverter(colorsArray[i]);
		okDist = okLCHdistance(okLCHval_A, okLCHval_B);
		if (okDist < lowestFoundDistanceForThisPair) {
			lowestFoundDistanceForThisPair = okDist;
			nearestFoundColorHEX = colorsArray[i];
		}
	}
	finalSortedList.push(nearestFoundColorHEX);
	// recreate colorsArray with sRGB_hex_A removed and nearestFoundColorHEX moved to start:
	// remove sRGB_hex_A; re this horror: https://stackoverflow.com/a/20690490/1397555 :
	colorsArray = colorsArray.filter(item => item !== sRGB_hex_A);
	// remove nearestFoundColorHEX:
	colorsArray = colorsArray.filter(item => item !== nearestFoundColorHEX);
	// add nearestFoundColorHEX to start:
	colorsArray.unshift(nearestFoundColorHEX);
}

// print final perceptually sorted color list:
for (idx in finalSortedList) {
	console.log(finalSortedList[idx]);
}