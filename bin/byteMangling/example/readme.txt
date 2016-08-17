---

This little piece of software was written by Károly Kiripolszky.
You can contact me via karoly.kiripolszky@gmail.com.
ByteMolester is totally free to use and distribute as you like.

---

ByteMolester 0.9

Usage: bm.exe [options] filename

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -x OUTPUT_EXT, --output_ext=OUTPUT_EXT
                        Extension of the output file w/o the dot. Default: fck
  -o OUTPUT_PATH, --output_path=OUTPUT_PATH
                        Path of the output file relative to %prog path, w/o
                        trailing slash. Default: out
  -s SKIP, --skip=SKIP  Number of bytes to skip from the beginning of the file
                        (header protection). Default: 2048
  -t THRESHOLD, --threshold=THRESHOLD
                        Amount of destruction (0-255). Default: 1
  -m MODE, --mode=MODE  Mode of destruction: +, -, +- or n. Default: +
  -r RATE, --rate=RATE  Rate (%) of destruction (0-100). Default: 10
  -a, --randomize       Randomize rate.
  -u TURNS, --turns=TURNS
                        Number of variations. Default: 1
  -v, --verbose         Turn verbosive mode ON.
  
---
Also, added by RAH from reference:
Re: https://www.flickr.com/groups/glitches/discuss/72157625818992800/

..\bm.exe picfile.jpg -x jpg -u 10 -r 4 -t 1 -s 100 -v
@echo Check the "out" folder now!

..\bm.exe - the molester itself

picfile.jpg - the name of the file you want to molest (must be in the same folder as the batch file)

-x - extension which will be used to create the glitched files (ie, jpg, png, gif, etc)

-u - Number of units to produce. 10 will produce 10 glitched images and so on...

-r - Rate of destruction of file.

-t - threshold of destruction. Increasing this number too much may render the output files useless

-s - Skip number of bytes. This is used to prevent the header of the file from being corrupted.

-v - enables verbose.

I think on the file I sent you there should be a batch file called runme inside the example folder.

Place an image file in the example folder and edit the batch file with Notepad. Put the name of the image file after bm.exe and save it.
Create a folder called out on the same folder as the batch file.

Run the runme.bat file then check the results in the out folder.