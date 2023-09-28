// DESCRIPTION
// Intended for CLI use. Extracts dominant color and a palette of an arbitrary number of colors from an image, printing to stdout.

// USAGE
// Run from the same directory with the image you wish to obtain a palette, using these parameters:
//    process.argv[2] source image file name, e.g. _EXPORTED_2023-07-19zb_v04.png
//    process.argv[3] integer number of colors to extract for palette
// For example, if you have the file tst1.png in the same directory you run this script from, and you want to extract 4 colors, run:
//    node /full_path/to/color-thief-jimp-palette.js tst1.png 4
// NOTES
// - it will error out if you try to extract only 1 color.
// - it doesn't seem to return the requested number of colors consistently if you request 4 or fewer; you may get 3 or 4 colors on requesting 2, for example.

// CODE
var ColorThief = require('color-thief-jimp');
var Jimp = require('jimp');

Jimp.read('./' + process.argv[2], (err, sourceImage) => {
  if (err) {
    console.error(err);
    return;
  }
    // TO GET dominant color:
    // var dominantColor = ColorThief.getColorHex(sourceImage);
    // console.log('dominant color found is [HEX]:\n' + dominantColor);
  var palette = ColorThief.getPaletteHex(sourceImage, process.argv[3]);
    // console.log('color palette extracted is [HEX]:');
  for (const idx in palette) {
    console.log('#' + palette[idx]);
  }
});

// ALTERNATE LIBRARY OPTION; is binary RGB triplets that I would want to convert to hex:
// const { getPaletteFromURL } = require('color-thief-node');

// (async () => {
    // const dominantColor = await getColorFromURL(process.argv[2]);
// })();

// (async () => {
    // const colorPallete = await getPaletteFromURL(process.argv[2], 6);
	// console.log(colorPallete);
// })();

