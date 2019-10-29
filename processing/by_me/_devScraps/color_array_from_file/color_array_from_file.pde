color[] backgroundColors = {
	#FF0000, #00FF00, #0000FF
};
int backgroundColorsArrayLength = backgroundColors.length;

int RNDbgColorIDX = (int) random(backgroundColorsArrayLength);
color globalBackgroundColor = backgroundColors[RNDbgColorIDX];

// LARNED: attempt to print a color in settings causes null pointer exception, but NOT in draw()!
void settings() {
	size(600,600);
}

void reinitialize_colors_array() {
//WORKS for copy later via tmpColorsArray.clone();  :
//color[] tmpColorsArray = new color[] { #B7A1AF, #AC9EB8, #B1A1C9, #A1A6D0, #9B98A2, #A58E9A, #B19491, #93b0c7, #7ba7cf, #69A2BE, #74B3E3 };

String[] tmp = loadStrings("test.hexplt");
color[] tmpColorsArray = new color[tmp.length];
  int count = 0;
  for (String tmpTwo : tmp) {
  tmpTwo = tmpTwo.substring(1); //strips leading # off string
  color tmpThree = unhex(tmpTwo);
  //float wut = red(tmpThree); print("red val: " + wut + "\n");
  tmpColorsArray[count] = tmpThree;
  count += 1;
  //append(tmpColorsArray, tmpThree);
  }
  
backgroundColors = tmpColorsArray.clone();
backgroundColorsArrayLength = backgroundColors.length;
print("Hopefully CHANGED backgroundColors.length value:" + backgroundColors.length + "\n");

RNDbgColorIDX = (int) random(backgroundColorsArrayLength);
globalBackgroundColor = backgroundColors[RNDbgColorIDX];
}

void setup() {
	ellipseMode(CENTER);
  print("backgroundColors.length value:" + backgroundColors.length + "\n");
}

void draw() {
  background(globalBackgroundColor);
	//color florf = color(255, 0, 255);
 // float tmp = red(florf);
 // print(tmp + "\n");
}

void mousePressed() {
  reinitialize_colors_array();
}
