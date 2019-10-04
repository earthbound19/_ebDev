//horked from: https://forum.processing.org/two/discussion/23569/center-point-for-trianlge-why-does-triangle-need-all-points-to-move

MyTriangle tri;
 
void setup(){
  size(400,600);
  tri=new MyTriangle(200,300,width/5);
}
 
void draw(){
   background(0);
   //tri.horizontalMotion(5);
   tri.draw();
}
 
class MyTriangle{
  float x,y,hLen;
 
  //Center point and side length
  MyTriangle(float cx, float cy,float length){
    x=cx;
    y=cy;
    hLen=length/2;
  }
 
  void draw(){
    triangle(x - hLen, y - hLen, x + hLen, y - hLen, x, y + hLen);  
  }
 
 void horizontalMotion(float valx){
     x=x+valx;
 }
}
