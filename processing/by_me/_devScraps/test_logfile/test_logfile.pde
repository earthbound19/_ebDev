// ganked and tweaked from: https://stackoverflow.com/a/17013103/1397555
// DEMONSTRATES appending a random new string to a file every time you click the mouse.

import java.io.BufferedWriter;
import java.io.FileWriter;

String outFilename = "out.txt";

// creates file if it doesn't exist, appending data only:
void appendTextToFile(String filename, String text){
  // I tried omitting the dataPath() call--it crashes! SO, you
  // must accept that everything ends up in a data subdir!
  File f = new File(sketchPath(filename));
  if(!f.exists()){
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }catch (IOException e){
      e.printStackTrace();
  }
}

// creates a new file including all subfolders:
void createFile(File f){
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
} 

// generates and returns random string:
String getRandomString(int length) {
  // https://programming.guide/java/generate-random-character.html
  String felf = "";
  String rnd_string_components = "abcdeghijklmnopqruvwyzABCDEGHIJKLMNOPQRUVWYZ23456789";
  for (int i = 0; i < length; i++)
  {
  int rnd_choice = (int) random(0, rnd_string_components.length());
  felf+= rnd_string_components.charAt(rnd_choice);
  }
  return felf;
}

// without this function in place, even though it's "doing nothing," mousePressed() does nothing:
void draw() {
}

void mousePressed() {
  String rnd_string = getRandomString(14);
  print(rnd_string + "\n");
  appendTextToFile(outFilename, rnd_string);
}
