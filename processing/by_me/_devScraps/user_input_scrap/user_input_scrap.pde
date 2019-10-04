//source: http://coding-club.weebly.com/processing.html

int            variable;                                                //creates an integer variable named "variable"
PFont      font;        
        
void setup()
{
  size(500,500);
  background(255);
  variable = 0;                                                        //sets an initial value for the variable of zero
  font=createFont("Arial",16,true);
  textFont(font,20);
  fill(0);
  text("Enter an integer value",10, 50);             //displays text in initial window
}

void draw(){                                                          //this loop is needed to refresh display window
}

void keyPressed()
  {
    if( key >= '0' && key <= '9' )                            //enters a keyboard digit between 0 and 9
      {
        variable*=10;                                               //allows for more than a 1 digit number
        variable+=key - 48;                                     //converts ASCII numbers into regular numbers
      }
    if( key == BACKSPACE || key == DELETE )  //allows you to backup if you made a mistake
      {
        variable/=10;
      }
    if( key == ENTER || key == RETURN )          //sets the value of the variable
      {
      }
    background(255);
    fill(0);
    text("Enter an integer value", 10, 50);
    text(variable, 10, 120);
    text("The value is", 10, 190);
    text(variable, 125, 190);
}
