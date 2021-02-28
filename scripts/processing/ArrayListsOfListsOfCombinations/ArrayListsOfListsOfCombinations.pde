// DESCRIPTION
// Function that creates an ArrayList of ArrayLists of all possible combinations of something (this example uses ints, but you can use anything that a one-dimensional ArrayList can contain).

// USAGE
// Copy and paste and adapt the code for your purposes. See more detailed documentation after the CODE comment.

// CODE
// This is a a recursive function (it calls itself). Prototype of it at: https://gist.github.com/earthbound19/74fc6e2588a948f7cb608db266f7d6bb (adapted in turn from elsewhere).
// Function parameters and the object it modifies are:
// - ArrayList<Integer> e: ArrayList of ints to get all possible combinations for.
//     Example contents of such a list: 0,1,2,3,4
// - int k: size of each combination. Should be any number less than `e` and greater than 1.
//     Example: all possible combinations of size k=3 from the above example ArrayList<Integer> are:
//     0,1,2 0,1,3 0,1,4 0,2,3 0,2,4 0,3,4 1,2,3 1,2,4 1,3,4 2,3,4
// - ArrayList<Integer> accumulationArrayINTsList_param: an empty list of integers, which the function manipulates to modify/create:
// - ArrayList<ArrayList<Integer>> allCombinations: an ArrayList of ArrayLists of ints. Each list of ints in the list is one of all possible combinations derived from ArrayList<Integer> e. In simpler english, allCombinations is a list of all possible combinations of ints. NOTE that the function directly modifies this list of lists which exists outside the function. In practical use you may wish to make the list of lists a member of a class, and the combination function a class function that modifies the member list of lists.
static ArrayList<ArrayList<Integer>> allCombinations = new ArrayList<ArrayList<Integer>>();
public static void combination(ArrayList<Integer> e, int k, ArrayList<Integer> accumulationArrayINTsList_param) {
	if (e.size() < k)			// 1. stop if/when there's no point running this function.
		return;
	if (k == 1) {		// 2. add each element in e to accumulated
		for (int s:e) {
			// ArrayList THINGS; equivalents of the above string operations but with an ArrayList:
			ArrayList<Integer> tmpIntArrayList = new ArrayList<Integer>(accumulationArrayINTsList_param);
			tmpIntArrayList.add(s);
			allCombinations.add(tmpIntArrayList);
    }
	}
	else if (e.size() == k) {		// 3. add all elements in e to accumulated
		ArrayList<Integer> tmpIntArrayList = new ArrayList<Integer>(accumulationArrayINTsList_param);
		for (int s:e) {
			tmpIntArrayList.add(s);
		}
		allCombinations.add(tmpIntArrayList);
	}
	else if (e.size() > k) {		// 4. for each element, call combination
		for (int i = 0 ; i < e.size() ; i++) {
    // hacking note: because I get a *view* of a list, but not an ArrayList, via subList, convert it; re: https://stackoverflow.com/a/16644841 -- I create a temp ArrayList here by converting the return of subList:
    ArrayList<Integer> tmpArrayList = new ArrayList<Integer>( e.subList( i+1, e.size() ) );
		ArrayList<Integer> tmpArrayList2 = new ArrayList<Integer>(accumulationArrayINTsList_param);
		tmpArrayList2.add(e.get(i));
		combination(tmpArrayList, k - 1, tmpArrayList2);
  	}
	}
}

// Example code within the draw() function call of Processing because it won't work in Processing otherwise:
void draw() {
	// Preparation for example function call:
	ArrayList<Integer> testArrayList = new ArrayList<Integer>();
	for (int i = 0; i < 5; i++) {
		testArrayList.add(i);
	}
	String accumulationSTR = "";
ArrayList<Integer> accumulationArrayINTsList = new ArrayList<Integer>();
	// Function call
	combination(testArrayList, 3, accumulationArrayINTsList);
	// Test print of variables modified by function call:
	print("\nTest result list print from ArrayList<Integer> allCombinations:\n");
	for (ArrayList<Integer> t:allCombinations) {
		for (int u:t) { print(u + ","); } print(" ");
	}
	print("\n");
	// exit after only one loop of draw() :
	exit();
}