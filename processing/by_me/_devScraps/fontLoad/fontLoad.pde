// IN DEVELOPMENT.
// TO DO:
// - figure out char height and use that for line spacing / number lines.
// - figure out why displays more lines on second click; fix that.

PFont myFont;
char[] blockchars = {
  '▀', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '▉', '▊', '▋', '▌', '▍',
  '▎', '▏', '▐', '░', '▒', '▓', '▔', '▕', '▖', '▗', '▘', '▙', '▚', '▛',
  '▜', '▝', '▞', '▟', '■', '-', '_', '|'
};
float fontPointSize = 83.4;

int blockCharsLength = blockchars.length;
float characterWidth;
color backGroundColor = #383838;
color fillColor = #FD00FD;
float columnWidth;
int columns;
int rows;

String blockCharsDisplayString = "";

void setup() {
  fullScreen();
  //size(600, 400);
  // Uncomment the following two lines to see the available fonts 
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("FiraMono-Bold.otf", fontPointSize);    // on Mac, leads to rendered monospace width of ~49.79
  //print(myFont.textLeading);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  fill(fillColor);
  background(backGroundColor);
  characterWidth = textWidth('█');
  columnWidth = (width / characterWidth);
  columns = int(width / characterWidth);
  textSize(fontPointSize);    // sets vertical leading?
  //rows = int(height / columnWidth);
  rows = 2;
  print("columns: " + columns + " rows: " + rows + "\n");
  renderRNDcharsScreen();
}

void renderRNDcharsScreen () {
  background(backGroundColor);
  print(characterWidth + "\n");
  for (int row = 0; row < rows; row++) {
    for (int column = 0; column < columns; column++) {
      // for dev testing spacing:
      // blockCharsDisplayString += "_";
      blockCharsDisplayString += blockchars[int(random(0, blockCharsLength))];
    }
    blockCharsDisplayString += "\n";
  }
  //text("█_-█\n-=░_", width/2, height/2);
  text(blockCharsDisplayString, width/2, height/2);
}

void draw () {
  // to change display on every draw loop:
  // renderRNDcharsScreen();
}

void mousePressed() {
  renderRNDcharsScreen();
}
