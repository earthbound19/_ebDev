PVector norf;

void draw() {

}

void mousePressed() {
  if (norf != null) {
    print("norf.x was: " + norf.x + ", norf.y was: " + norf.y + "\n");
    norf.x = mouseX; norf.y = mouseY;
    print("norf.x is: " + norf.x + ", norf.y is: " + norf.y + "\n");
  } else {
    print("Is null! will do nothing!\n");
  }
  norf = new PVector(mouseX, mouseY);
}
