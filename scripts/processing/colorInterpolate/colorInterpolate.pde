// DESCRIPTION
// Prints interpolation values from color 'from' to color 'to'. For hacking/finding color gradients. I'd like to modify it to render the gradients also, and at customizable intervals (right now the intervals are hard-coded).

// USAGE
// Open this file in the Processing IDE (or anything else that can run a Processing file), edit the assignments to the "from" and "to" variables to colors of your choosing, and run it with the triangle "Play" button.


// CODE
// TO DO: the things in DESCRIPTION.

stroke(255);
background(51);
color from = color(#B2DEFF);
color to = color(#FF00FF);
color interA = lerpColor(from, to, .14);
color interB = lerpColor(from, to, .28);
color interC = lerpColor(from, to, .42);
color interD = lerpColor(from, to, .57);
color interE = lerpColor(from, to, .71);
color interF = lerpColor(from, to, .85);
println(hex(interA));
println(hex(interB));
println(hex(interC));
println(hex(interD));
println(hex(interE));
println(hex(interF));
