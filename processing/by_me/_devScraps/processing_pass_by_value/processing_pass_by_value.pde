// yes, the variable names are horrible and don't help.

int foo;
int bar;
Blorf blorf_obj_one;

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
  blorf_obj_one = new Blorf(foo,bar);
  print("Click the mouse to see info printout.\n");
}

void draw() {
}

void mousePressed() {
  print(foo + ", " + bar + "\n");
  print("blorf_obj_one " + blorf_obj_one.foo + ", " + blorf_obj_one.bar + "\n");
  Blorf blorf_obj_two = blorf_obj_one;
  blorf_obj_two.foo += 1;
  print("because blorf_obj_two is a reference to blorf_obj_one, the values of the ints of one change when we change the values of the other:\n");
  print("now blorf_obj_one " + blorf_obj_one.foo + ", " + blorf_obj_one.bar + "\n");
  print("and blorf_obj_two " + blorf_obj_two.foo + ", " + blorf_obj_two.bar + "\n");
}
