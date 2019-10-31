int d = day(); String dS = nf(d, 2);
int m = month(); String mS = nf(m, 2);
int y = year(); String yS = nf(y, 4);
int h = hour(); String hS = nf(h, 2);
int min = minute(); String minS = nf(min, 2);
int s = second(); String sS = nf(s, 2);

String formattedDateTime = yS + "_" + mS + "_" + dS + "__" + hS + "_" + minS + "_" + sS;
print(formattedDateTime);
