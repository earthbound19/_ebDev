
// DESCRIPTION
// Modified to include JSON-based color retrieval, separate save functionality, and triggered random geometry creation.

// Global variables
boolean RNDcolorMode = true;
color[] Colors;
color[] Prismacolors = {
  #E54D93, #F9E3E0, #D13352, #E14E6D, #F45674, #EA5287, #EF7FAD,
  #F6C6D0, #F895AC, #F4DCD7, #F9C0BC, #F65C6A, #F86060, #FD9863,
  #FA855B, #F7D580, #ECBF7A, #F5D969, #F3C77D, #EEE2C7, #EEE4DC,
  #93CD87, #75755C, #C6DD8E, #687B57, #618979, #009E90, #A2B1A2,
  #008D94, #4F8584, #00B3DB, #0090C7, #33549B, #405F89, #435BA3,
  #574C70, #0BBDC4, #4CC8D9, #97C1DA, #934393, #CA4587, #E65F9F,
  #D8308F, #B1A1C9, #88595C, #8D6E64, #BD6E6B, #EBB28B, #F5DCD5,
  #F7DDCB, #C97B8E, #F0CCC4, #E5E4E9, #F5D3DD, #D46569, #CA5A62,
  #A0716D, #DEBBB3, #C87F73, #EE8A74, #C9877F, #EDD6BF, #5B4446,
  #524547, #F1E5E9, #F0D9DC, #E9C9D1, #C5AAB4, #B7A1AF, #A58E9A,
  #8C7B87, #6A5B67, #62555E, #DDDBE0, #C7C6CD, #C8C7CE, #A4A1A9,
  #9B98A2, #7F7986, #857F8A, #72727D, #615F6B, #FCC0BA, #FFC874,
  #BEB27B, #367793, #6389AB, #8D6CA9, #AF62A2, #FEC29F, #F2D8A4,
  #F8D9BE, #ECA6B9, #7AD2E2, #E497A4, #A7BCBB, #95B6BA, #7B91A2,
  #69A2BE, #C9CBE0, #A1A6D0, #C0A9BE, #AA8E79, #8E4C5C, #AA4662,
  #C14F6E, #D96A6E, #F98973, #F7DFD8, #D1BCBD, #CBADB1, #BFA9A8,
  #B19491, #987D80, #877072, #745D5F, #72646C, #36B191, #66C7B0,
  #8F4772, #B34958, #FA9394, #AC9EB8, #9B685D, #59746E, #1E7C72,
  #009D79, #82B079, #91BACB, #E0BFB5, #74B3E3
};
String apiURL = "https://earthbound.io/data/random_ebPalette/";
PShape currentShape;

// Set up the canvas
void setup() {
  size(800, 800); // Example size, adjust as needed
  setRNDcolors(); // Initialize colors
  generateRandomGeometry(); // Generate initial geometry
}

// Main draw loop
void draw() {
  background(255);
  if (currentShape != null) {
    shape(currentShape, 0, 0);
  }
}

// Key event handler
void keyPressed() {
  if (key == 's') {
    saveCurrentComposition();
  } else if (key == ' ') {
    generateRandomGeometry();
  }
}

// Function to save the current composition as .png and .svg
void saveCurrentComposition() {
  if (currentShape != null) {
    String timestamp = str(year()) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("output_" + timestamp + ".png");
    PShapeSVG svg = (PShapeSVG) currentShape;
    // svg.save("output_" + timestamp + ".svg");
  }
}

// Function to generate random geometry
void generateRandomGeometry() {
  currentShape = createShape();
  currentShape.beginShape();
  int vertexCount = int(random(3, 10)); // Example random geometry
  for (int i = 0; i < vertexCount; i++) {
    float x = random(width);
    float y = random(height);
    currentShape.vertex(x, y);
  }
  currentShape.endShape(CLOSE);

  // Randomly color the shape
  if (Colors != null && Colors.length > 0) {
    currentShape.setFill(Colors[int(random(Colors.length))]);
  }
}

// Function to set colors, retrieving from API or using fallback
void setRNDcolors() {
  print("Attempting to retrieve colors from API..\n");
  if (RNDcolorMode) {
    Thread t = new Thread(new Runnable() {
      public void run() {
        try {
          JSONObject json = loadJSONObject(apiURL);
          JSONArray colorArray = json.getJSONArray("colors");
          print("Extracted colors array: " + colorArray + "\n");
          Colors = new color[colorArray.size()];
          for (int i = 0; i < colorArray.size(); i++) {
            Colors[i] = unhex(colorArray.getString(i).substring(1)); // Convert hex to color
          }
        } catch (Exception e) {
          println("API fetch failed or timed out. Using fallback colors.");
          Colors = Prismacolors;
        }
      }
    });
    t.start();
    try {
      t.join(7000); // Wait up to 7 seconds
    } catch (InterruptedException e) {
      println("Timeout reached. Using fallback colors.");
      Colors = Prismacolors;
    }
  } else {
    Colors = Prismacolors; // Fallback colors if RNDcolorMode is false
  }
  // debug print of result
  print("Elements of Colors array after setup:\n");
  for (int i = 0; i < Colors.length; i++) {
    print(hex(Colors[i]) + "\n");
  }
}
