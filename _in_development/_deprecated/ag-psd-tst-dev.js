// To use this script, you must set up the environment first, via this terminal command:
// npm install -g ag-psd
// -- then from a path you intend to use it from, run this command:
// npm link ag-psd

// or maybe? : https://stackoverflow.com/questions/11794344/imagemagick-multi-layer-tiff

// Working up this test re:  re: https://www.npmjs.com/package/ag-psd
console.log('Code start . . .')

		// THE NEXT LINE IS DEPRECATED and updated to the line after it, re: https://stackoverflow.com/a/39436580
		// import * as fs from 'fs'
const fs = require('fs') 
// CONTINUE CODING HERE:
const agpsd = require('ag-psd')
		// import { writePsd } from 'ag-psd'
// const writePSD = require('ag-psd')

const psd = {
  width: 800,
  height: 800,
  children: [
    {
      name: 'Layer #1',
    }
  ]
}
 
const buffer = agpsd.writePsd(psd)
fs.writeFileSync('test800x800.psd', buffer)

console.log('Code end.')

console.log('Functions available from agpsd:\n')
console.log(Object.getOwnPropertyNames(agpsd.PsdReader))