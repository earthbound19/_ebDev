
color magenta_local = color(255,0,255);
noStroke();
fill(magenta_local);
size(50, 50);
rect(0, 0, 50, 50);

//to get the red, green or blue value of a color object, use functions that returns floats respectively named red(), green(), and blue(). re: https://processing.org/reference/red_.html
float r = red(magenta_local);
float g = green(magenta_local);
float b = blue(magenta_local);
print(r + ", " + g + ", " + b);

//blarg += 50;    // color objects can't be added to this way. this always results in red--even after many repeats of that operation--from some error I assume.
//fill(blarg);
//delay(440);
//rect(0, 0, 50, 50);

//blarg += 50;
//fill(blarg);
//delay(440);
//rect(0, 0, 50, 50);

//blarg += 50;
//fill(blarg);
//delay(440);
//rect(0, 0, 50, 50);

//blarg += 50;
//fill(blarg);
//delay(440);
//rect(0, 0, 50, 50);

//blarg += 50;
//fill(blarg);
//delay(440);
//rect(0, 0, 50, 50);
