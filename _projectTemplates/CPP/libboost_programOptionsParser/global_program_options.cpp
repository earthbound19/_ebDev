//Modified from: http://chuckaknight.wordpress.com/2013/03/24/boost-command-line-argument-processing/
//Modifications: replace curly-quotes and em-dashes replaced with " and --, minor typo/typographic preference updates; strip out redundant demo functions. -RAH 05/14/2014 09:29:41 PM

//An earlier version of this (which I couldn't get to compile) is at: http://pastebin.com/eM5djvAU#
//I get this to work quickly in CODE::BLOCKS by installing this particular mingw32 distro: http://nuwen.net/mingw.html
//--which provides gcc-compiled, binary libraries from boost. Add the C:\MinGW\bin directory to your compiler include paths, and C:\MinGW\lib to your linker include paths, and then in link settings add whichever compiled library from the latter directory which your project requires.

// Include the headers relevant to the boost::program_options library
#include <boost/program_options/options_description.hpp>
#include <boost/program_options/parsers.hpp>
#include <boost/program_options/variables_map.hpp>
#include <boost/tokenizer.hpp>
#include <boost/token_functions.hpp>

using namespace boost;
using namespace boost::program_options;

#include <iostream>
#include <fstream>
#include <vector>
#include <string>

// Include std::exception so we can handle any argument errors emitted by the command line parser
#include <exception>

using namespace std;

int global_program_options(int argc , char **argv)
{

	// Add descriptive text for display when help argument is supplied
	options_description desc(
		"\nHey programmer! Type e.g. an example command and/or a description and copyright for your program here.\n\nOptions");

	// Define command line arguments using either format:
	//
	//     ("long-name,short-name", "Description of argument")
	//     for flag values or
	//
	//     ("long-name,short-name", <data-type>,
	//     "Description of argument") for arguments with values.
	//
	// Remember that arguments with values may be multi-values, and must be vectors.
	desc.add_options()
		("help,h", "Produce this help message.")
		("output-file,o", value< vector<string> >(), "Specifies output file.")
		("input-file,i", value< vector<string> >(), "Specifies input file.");

	// Map positional parameters to their tag valued types (e.g. --input-file parameters)
	positional_options_description p;
	p.add("help", -1);      //If a bogus parameter is passed, this here line causes the help to be displayed.

	//If no arguments are passed to the program, display a note and help.
	//Adapted from http://stackoverflow.com/a/5183224
	std::vector<std::string> args(argv, argv+argc);
	int empty_args_check = args.size();
	if (empty_args_check == 1)  {
            cout << "No arguments were passed to the program. See help text below.\n";
            cout << desc;
	}

	// Parse the command line, and catch and display any parser errors.
	variables_map vm;
	try
	{
		store(command_line_parser(
		argc, argv).options(desc).positional(p).run(), vm);
		notify(vm);
	} catch (std::exception &e)
	{
		cout << endl << e.what() << endl;
		cout << desc << endl;
	}

	// Display help text when requested.
	if (vm.count("help"))
	{
		//cout << "--help specified" << endl;
		cout << desc << endl;
	}


	// Display the state of the arguments supplied.
	// In a program, you would e.g. invoke a function call in response to any argument passed to the program, by putting that function in an "if" control block, as shown here.
	if (vm.count("output-file"))
	{
		vector<string> outputFilename = vm["output-file"].as< vector<string> >();
		cout << "--output-file specified with value == " << outputFilename[0] << ".\n";
	}

	if (vm.count("input-file"))
	{
		vector<string> inputFilename = vm["input-file"].as< vector<string> >();
		cout << "--input-file specified with value == " << inputFilename[0] << ".\n";
	}


return 0;

}
