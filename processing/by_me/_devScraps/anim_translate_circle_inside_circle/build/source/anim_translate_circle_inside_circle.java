import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class anim_translate_circle_inside_circle extends PApplet {

float largerCircleDiameter;
float smallerCircleDiameter;

float centers_distance;
float target_centers_distance;
float larger_circle_X; float larger_circle_Y;
float larger_circle_diameter;
float smaller_circle_X; float smaller_circle_Y;
float smaller_circle_diameter;

int orange = color(255,255,127);
int cyan = color(0,255,255);

public void settings() {
size(640,640);
}

public void setup() {
  frameRate(1.5f);
  ellipseMode(CENTER);
  larger_circle_X = (width / 50) * random(15, 30);
  larger_circle_Y = (width / 50) * random(15, 30);
  larger_circle_diameter = (width / 20) * random(8, 11);
  smaller_circle_X = (width / 70) * random(10, 60);
  smaller_circle_Y = (width / 70) * random(10, 60);
  smaller_circle_diameter = (width / 40) * random(8, 11);
  //noLoop();
}

public void draw() {
  background(100);
  strokeWeight(4);
  stroke(cyan);
  fill(127);
  ellipse(larger_circle_X, larger_circle_Y, larger_circle_diameter, larger_circle_diameter);
  ellipse(smaller_circle_X, smaller_circle_Y, smaller_circle_diameter, smaller_circle_diameter);

  // I bet that some common math function I don't know does this in fewer steps:
  float circles_center_to_center_dist = dist(larger_circle_X, larger_circle_Y, smaller_circle_X, smaller_circle_Y);
  float target_centers_dist = (larger_circle_diameter / 2) - (smaller_circle_diameter / 2);
  float centers_to_target_dist_mult = target_centers_dist / circles_center_to_center_dist;
  float Xdiff = larger_circle_X - smaller_circle_X;
  float Ydiff = larger_circle_Y - smaller_circle_Y;
  float newX = larger_circle_X - (Xdiff * centers_to_target_dist_mult);   // a + will put it tangent opposite side
  float newY = larger_circle_Y - (Ydiff * centers_to_target_dist_mult);
  stroke(orange);
  ellipse(newX, newY, smaller_circle_diameter, smaller_circle_diameter);
  setup();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "anim_translate_circle_inside_circle" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
