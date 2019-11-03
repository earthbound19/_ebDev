// yes, the variable names are horrible and don't help.

int foo;
int bar;
Blorf blor;

class Blorf {
  int foo;
  int bar;
  // constructor:
  Blorf(int fooArg, int barArg) {
    foo = fooArg;
    bar = barArg;
  }
}

void settings() {
  foo = 5;
  bar = foo;
  foo += 1;
  blor = new Blorf(foo,bar);
}

void draw() {
}

void mousePressed() {
  print(foo + ", " + bar + "\n");
  print("blor " + blor.foo + ", " + blor.bar + "\n");
  Blorf glar = blor;
  glar.foo += 1;
  print("because glar is a reference to blor, the values of the ints of one change when we change the values of the other:\n");
  print("now blor " + blor.foo + ", " + blor.bar + "\n");
  print("and glar " + glar.foo + ", " + glar.bar + "\n");
}
