// DESCRIPTION
// Intended for CLI use. Extracts dominant color and a palette of an arbitrary number of colors from an image, printing to stdout.

// USAGE
// Invoke this script with two parameters:
// process.argv[2] <./path_to_image_to_process.png>
// process.argv[3] <number of colors to extract for palette>.

// TO EXAMINE; other means proffered yon: http://stackoverflow.com/questions/26889358/generate-color-palette-from-image-with-imagemagick
// -- a working test command adapted from yon:
// magick convert ./tsfVt.jpg -format %c -colorspace LAB -colors 9 histogram:info:- | sort > wut.txt

// TO DO
// cross-compile this to an exe targeting any platform? roll all dependencies into one repo I control?


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
  console.log(palette);
});
