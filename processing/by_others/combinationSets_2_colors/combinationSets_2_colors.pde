// modified by RAH from https://github.com/fjenett/combinatorics/blob/master/examples/combinationSets_2/combinationSets_2.pde
// paste any comma-separated list of hex color codes over the array OR comma-separated list like this:
// color( 255, 0, 0 ),
// color( 200, 100, 0 ),
// color( 125, 200, 50 ),
// and run this script to see all possible color combinations from the list.
// run time at 30 frames per second: way too long to be worth watching. getting to 4-combos takes half an hour?

/**
 *    Testing combinations of colors (think flags)
 *
 *    fjenett 20090306
 */

import de.bezier.math.combinatorics.*;

color farben[];
CombinationSet combinations;

void setup ()
{
    size( 1280, 720 );
    
    farben = new color[] {
    #CA4587, #F45674, #F86060, #D96A6E,
    #B34958, #8F4772, #934393, #AF62A2,
    #72727D, #745D5F, #877072, #9B685D,
    #C97B8E, #E497A4, #FA9394, #F98973,
    #FD9863, #FEC29F, #F9C0BC, #F5D3DD,
    #F0CCC4, #E0BFB5, #F8D9BE, #EEE2C7, #F2D8A4, #FADFA7,
    #F7D580, #FFC874, #FDFD96, #F5FFA1, #F0FFF0, #E0FFFF, #F1E5E9,
    #C7C6CD, #97C1DA, #95B6BA, #A2B1A2, #B7A1AF,
    #AC9EB8, #9B98A2, #B19491, #7B91A2, 
    #74B3E3, #00B3DB, #4CC8D9, #93EDF7, #00FFEF, #7FFFD4,
    #88D8C0, #93CD87, #82B079, #00A86B, #0BBDC4,
    #4F8584, #59746E, #367793, #405F89, #435BA3, 
    #3344BB, #003153, #32127A, #574C70,
    #524547, #79443B, #4E1609, #73ED91, #00FA9A
    };
    
    combinations = new CombinationSet( farben.length, 1, farben.length );
    
    noStroke();
    frameRate( 30 );
}

void draw ()
{
    if ( !combinations.hasMore() )
    {
        //combinations.rewind();
        exit();
    }
    
    int[] c = combinations.next();
    float w = width/float(c.length);
    for ( int i = 0; i < c.length; i++ )
    {
        fill( farben[ c[i] ] );
        rect( i*w, 0, w, height );
    }
}
