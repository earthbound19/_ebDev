// Working up this test re:  re: https://www.npmjs.com/package/ag-psd
console.log("wut");

		// THE NEXT LINE IS DEPRECATED and updated to the line after it, re: https://stackoverflow.com/a/39436580
		// import * as fs from 'fs';
const fs = require("fs") ;
		// import { writePsd } from 'ag-psd';
// CONTINUE CODING HERE:
// const writePSD = require("ag-psd");

const psd = {
  width: 300,
  height: 200,
  children: [
    {
      name: 'Layer #1',
    }
  ]
};
 
// const buffer = writePsd(psd);
// fs.writeFileSync('my-file.psd', buffer);