//rotate canvas pivoting from center (by translating to center first)
void setup()
{
  size(500, 500);    // use full display size--why these !same as width and height above, I don't know.
}

void draw() {
rectMode(CENTER);
//pushMatrix();
translate(width/2, height/2);
rotate(radians(45));
translate((width/2) * -1, (height/2) * -1);
rect(250, 250, 100, 150);
triangle(100, 100, 50, 150, 150, 150);
ellipse(100, 100, 10, 10);
ellipse(50, 150, 10, 10);
ellipse(150, 150, 10, 10);
//popMatrix();
}
