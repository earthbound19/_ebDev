color[] backgroundColors_HC = {
  // colors from _ebArt/blob/master/palettes/fundamental_vivid_hues.hexplt :
  #FF00FF, #FF00E2, #FF007F, #FF0070, #FC2273, #FF0000, #FF1200, #FF5100, #FD730A, #FFA100,
  #FFB700, #FFCD00, #FAE000, #FFFF00, #FAFF54, #AFE300, #75FF00, #00FF00, #25FD73, #52FE79,
  #7FFF7F, #40F37E, #33EB80, #00E77D, #1DCF00, #65D700, #76F1A8, #7FFFFF, #00FFFF, #00E4FF,
  #00CFFF, #00C4FF, #007FFF, #6060FF, #7F40FF, #7202FF, #5F00BE, #4D00A6, #40007F, #3C1CB3,
  #3325D6, #0000FF, #4040FF, #6A6AFF, #7F7FFF, #407FBF, #007F7F, #2B2BAB, #00007F, #54007F,
  #7F007F, #7F0038, #7F0000
};

color[] grayscalePaletteDynamicCopy;

void convertPaletteToGrayscaleAVGmethod() {
  int paletteLength = backgroundColors_HC.length;
  grayscalePaletteDynamicCopy = new color[backgroundColors_HC.length];
  for (int i=0; i < paletteLength; i++) {
    color tmp_color = backgroundColors_HC[i];
    String tmp_str = hex(tmp_color);
    int R = unhex( tmp_str.substring(2,4) );
    int G = unhex( tmp_str.substring(4,6) );
    int B = unhex( tmp_str.substring(6,8) );
    int average = int((R + G + B) / 3);
    //print(R + "," + G + "," + B + "\n");
    //print("average: " + average + "\n");
    //averaged_gray = color(average);
    grayscalePaletteDynamicCopy[i] = color(average);
  }
}

void settings() {
  convertPaletteToGrayscaleAVGmethod();
}

void draw() {
  int rnd_bg_color_idx = int( random(0, grayscalePaletteDynamicCopy.length) );
  background(grayscalePaletteDynamicCopy[rnd_bg_color_idx]);
}
