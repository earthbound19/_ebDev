// DESCRIPTION
// Takes an input sRGB hex color list (in .hexplt format) and sorts the colors in it by next nearest perceptual distance in the okLab color space. (Tries to group colors by most similar in a list.) Preserves any comments (anything after one color and before the next). Does not write the result to any file; you'll need to redirect to do that (see NOTES under USAGE). NOTE THAT THIS IS BLAZING FAST compared to the rgbHex ~sort.py scripts. However, depending on the size of the source colors palette, those may be fast enough, and afford use of other color spaces. SEE ALSO `sortSRGBhexColorsColoraide.py`

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
// DEV NOTE: OH HOW BADLY I WANTED TO FIND A PYTHON LIBRARY that works with okLab + does distance calculations (DeltaE) between colors and adapt one of the Python color sorting scripts to do that, because OH MY UNHOLY NACHOS OF WRATH this was so, so, SOOOOO much more difficult to implement in JavaScript. But no such Python library exists, that I could find. okLab is in development for colour-science as of winter 2021.. EDIT, 2025: the Python coloraide library works with oklab (okLCH), and many other color spaces. JavaScript Culori is much faster, or I would have ditched this script because maintaining and updating this JavaScript for wants is harder :)

// DEPENDENCIES (INCLUDES)
// CommonJS export of culori, re: https://culorijs.org/guides/migration/
culori = require('culori/require');
var fs = require('fs');
const { program } = require('commander');

// START OPTIONS PARSING AND CHECKING
program
  // the <fileName> thing here leads to capture of a series of values (file name):
  .requiredOption('-i --inputFile <fileName>', '\n\tInput palette file name (e.g. \'floral_print_00002.hexplt\'), which is a list of sRGB colors in hex format (e.g. #f800fc).\n')
  .option('-s, --startComparisonColor <digits>', '\n\tFirst color to start comparisons with, in sRGB hex format (e.g. 0a000a or #0a000a)\n')
  .option('-k, --keepDuplicateColors', '\n\tDo not remove duplicate colors from list. Without this switch (by default), duplicate colors are removed.\n')
program.parse();
const options = program.opts();

// INPUT FILE
// convert input file parameter to the string it's intended to be:
const inputFileString = String(options.inputFile);
// get array of sRGB hex values from input file:
try {
  var inputFileContent = fs.readFileSync(inputFileString).toString();
}
// print error if unable to read specified file:
catch(err) {
  console.log("\n\n!========\nERROR: unable to open specified -i --inputFile ", inputFileString, ". Exit code 1.\n!========\n");
  process.exit(1);
}
// ARBITRARY FIRST SORT COLOR
var arbitraryStartCompareColor = '';		// set default blank
if(typeof options.startComparisonColor !== 'undefined') {
	// try to grab six hex digits from the parameter, and throw an error if we can't.
	const match = options.startComparisonColor.match(/[0-9a-fA-F]{6}/);
	if (match) {
	arbitraryStartCompareColor = match[0];
	} else {
		console.log("\n\n!========\nERROR: provided value for parameter -s --startComparisonColor is not in sRGB hex format (six hex digits, e.g. 0a000a); value is:\n\t", options.startComparisonColor, "\nExit code 2.\n!========\n");
		process.exit(2);
	}
}

// get array of sRGB hex values and comments from input file:
const regexp = /(#?[a-fA-F0-9]{6})([^\n]*)/g;
const searchResults = [...inputFileContent.matchAll(regexp)];
// init array of colors and comments from file + regex search result:
var comparisonColorsArray = [];
for (const element of searchResults) {
  comparisonColorsArray.push({ color: element[1], comment: element[2] });
}

// If there is not a -k switch instructing to keep duplicate colors, remove duplicates from original list, but maintain order (keep all unique in the same order), re: https://stackoverflow.com/a/15868720/1397555
if(typeof options.keepDuplicateColors == 'undefined') {
  const uniqueColors = new Set();
  comparisonColorsArray = comparisonColorsArray.filter(item => {
    if (uniqueColors.has(item.color)) {
      return false;
    } else {
      uniqueColors.add(item.color);
      return true;
    }
  });
}

// if the value of arbitraryStartCompareColor was changed from default empty string (''), because a valid sRGB hex color value for the -s option was passed to the script, add it to the start of the list; colors will therefore be sorted by first comparing to it; will remove it afterward:
if (arbitraryStartCompareColor != '') {
  comparisonColorsArray.unshift({ color: arbitraryStartCompareColor, comment: '' });
}

const comparisonColorsArrayLength = comparisonColorsArray.length

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
// Add first item to final list, as the first item will be the first in the original list; comparisonColorsArray[0].color and searchResults[0][0] SHOULD both be the first color in the list (although arbitraryStartCompareColor can mess with that, but the result we intend will be the same):
finalSortedList.push(comparisonColorsArray[0]);

while (finalSortedList.length < comparisonColorsArrayLength) {
  var sRGB_hex_A = comparisonColorsArray[0].color;
  var sRGB_hex_B;
  var okLCHval_A = okLCHconverter(sRGB_hex_A);
  var okLCHval_B;
  var okDist = 58848;								// way beyond any distance that will be found.
  var lowestFoundDistanceForThisPair = 58849;		// "
  var nearestFoundColor;
  // figuring out this i = 1 (not zero) was the final thing that finished this script:
  for (var i = 1; i < comparisonColorsArray.length; i++) {
    sRGB_hex_B = comparisonColorsArray[i].color;
    okLCHval_B = okLCHconverter(sRGB_hex_B);
    okDist = okLCHdistance(okLCHval_A, okLCHval_B);
    if (okDist < lowestFoundDistanceForThisPair) {
      lowestFoundDistanceForThisPair = okDist;
      nearestFoundColor = comparisonColorsArray[i];
    }
  }
  finalSortedList.push(nearestFoundColor);
  // recreate comparisonColorsArray with sRGB_hex_A removed and nearestFoundColor moved to start:
  // remove sRGB_hex_A; re this horror: https://stackoverflow.com/a/20690490/1397555 :
  comparisonColorsArray = comparisonColorsArray.filter(item => item.color !== sRGB_hex_A);
  // remove nearestFoundColor:
  comparisonColorsArray = comparisonColorsArray.filter(item => item.color !== nearestFoundColor.color);
  // add nearestFoundColor to start:
  comparisonColorsArray.unshift(nearestFoundColor);
}

// if the value of arbitraryStartCompareColor was changed from default empty string (''), because a valid sRGB hex color value for the -s option was passed to the script, we earlier added arbitraryStartCompareColor to the list; in that case remove it now from the final list (it will be the first item in the list):
if (arbitraryStartCompareColor != '') {
  finalSortedList.shift();
}

// If the -k switch is used, ensure duplicates are preserved in the final sorted list
if (typeof options.keepDuplicateColors !== 'undefined') {
  const originalColorsArray = [...inputFileContent.matchAll(regexp)].map(match => ({ color: match[1], comment: match[2] }));
  const finalSortedListWithDuplicates = [];
  const colorCountMap = {};

  // Create a map to count occurrences of each color in the original list
  originalColorsArray.forEach(item => {
    if (colorCountMap[item.color]) {
      colorCountMap[item.color].push(item.comment);
    } else {
      colorCountMap[item.color] = [item.comment];
    }
  });

  // Add colors to the final list with duplicates preserved
  finalSortedList.forEach(item => {
    const comments = colorCountMap[item.color];
    if (comments) {
      comments.forEach(comment => {
        finalSortedListWithDuplicates.push({ color: item.color, comment: comment });
      });
      delete colorCountMap[item.color]; // Remove the color from the map once processed
    }
  });

  finalSortedListWithDuplicates.forEach(item => console.log(item.color + item.comment));
} else {
  finalSortedList.forEach(item => console.log(item.color + item.comment));
}