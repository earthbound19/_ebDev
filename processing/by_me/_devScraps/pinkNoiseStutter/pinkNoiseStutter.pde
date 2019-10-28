  

import processing.sound.*;
PinkNoise noise;

void setup() {
  size(640, 360);
  background(255);
    
  // Create the noise generator
  noise = new PinkNoise(this);
}      

boolean delay_started = false;
int delay_ms = 100;
void draw() {
  thread("start_delays");
}

void start_delays() {
  if (delay_started == false) {
    thread("noise_on");
    delay_started = true;
  }
}

void noise_on() {
  delay(delay_ms);
  noise.play();
  thread("noise_off");
}

void noise_off() {
  delay(delay_ms);
  noise.stop();
  thread("noise_on");
}
