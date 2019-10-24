// randomly fills the canvas from an array of color. Seizure inducing and evil. But possibly beautiful.
//- RAH

// Global variables:
// Prismacolor marker colors array:
color[] Prismacolors = {
  #F4DCD7, #F5DCD5, #F8D9BE, #EDD6BF, #F0D9DC, #524547, #5B4446,
  #CBADB1, #BFA9A8, #EEE2C7, #E54D93, #EA5287, #EEE4DC, #F1E5E9,
  #F6C6D0, #F5D3DD, #7F7986, #72727D, #B34958, #AA4662, #F98973,
  #FA855B, #CA4587, #D8308F, #E5E4E9, #F0CCC4, #E0BFB5, #D1BCBD,
  #F7D580, #F5D969, #E497A4, #F895AC, #F9C0BC, #8D6E64, #9B685D,
  #EE8A74, #91BACB, #95B6BA, #E14E6D, #E65F9F, #FA9394, #DEBBB3,
  #4CC8D9, #7AD2E2, #C7C6CD, #C9CBE0, #B19491, #AA8E79, #C87F73,
  #BD6E6B, #0BBDC4, #75755C, #687B57, #B7A1AF, #CA5A62, #C14F6E,
  #A58E9A, #405F89, #435BA3, #B1A1C9, #A1A6D0, #009D79, #009E90,
  #72646C, #877072, #33549B, #9B98A2, #AC9EB8, #D96A6E, #C0A9BE,
  #987D80, #EF7FAD, #FD9863, #D13352, #8E4C5C, #8F4772, #615F6B,
  #36B191, #FEC29F, #62555E, #618979, #59746E, #F45674, #F2D8A4,
  #FFC874, #008D94, #69A2BE, #7B91A2, #EBB28B, #F86060, #00B3DB,
  #74B3E3, #66C7B0, #93CD87, #82B079, #ECA6B9, #C97B8E, #745D5F,
  #A2B1A2, #367793, #6389AB, #C6DD8E, #0090C7, #4F8584, #AF62A2,
  #BEB27B, #574C70, #8D6CA9, #1E7C72, #934393, #97C1DA
};
int PrismacolorArrayLength = Prismacolors.length; 

 //Shimmery cyans color array:
color[] cyans = {
  #26ffff, #06ffff, #00ffff, #4cffff, #54f1f1, #29f1fc, #75ebff, #97ffff
};
int cyanColorsArrayLength = cyans.length;

color[] cyansWithDirtyOcean = {
  #00ffff, #06ffff, #26ffff, #4cffff, #5bfcfc, #64fcfc, #75fcfc,
  #6cf7fc, #75f4fc, #60f4fc, #5cf4fc, #64f1fc, #54eefc, #5cecfc,
  #75ebff, #64e4fc, #58e4fc, #4ce5fc, #54dcf2, #59dcfc, #29f1fc,
  #54f1f1, #50e9dc, #83eed1, #9cf0bc, #97ffff
};
int cyansWithDirtyOceanArrayLength = cyansWithDirtyOcean.length;


void setup() {
  fullScreen();
  //noLoop();
}


void draw() {
  int RND_color_index = (int) random(0, cyansWithDirtyOceanArrayLength);
  background(cyansWithDirtyOcean[RND_color_index]);
  delay(150);    // 6.66 fps ;)
  //saveFrame("#######.png");
  //frameCounter += 1;
  //if (frameCounter == nFrames) {
  //  exit();
  //}
}
