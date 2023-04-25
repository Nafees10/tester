module config;

import sdlang;

/++
For storing config
Stored in this format in sdl file:
```sdlang
name "task name" // defaults to current directory name

lang "cpp" // used for autodetecting compile and exec
// or use the following if language is not supported by tester
compile "someUnsupportedCompiler %NAME% -o exeFile"
exec "./exeFile"

tests_autodetect true // this is default
// if a test tag is detected, implicit autodetect is disabled
test "1" // will look for 1.in and 1.out for inputs and expected outputs
test "2" // will look for 2.in and 2.out
test "bla" // will look for bla.in and bla.out
test "blabla" points=5 // by default points are 10
```
+/
struct Config{
	struct Test{
		string name = null; // name
		int points = 10;
	}

	string name; /// name
	string lang; /// language
	string compile; /// compile command
	string exec; /// exec command
	bool testsAutodetect = true; /// whether to autodetect test cases
	Test[] tests; /// explicitly added tests
}

/// Reads config file.
///
/// Throws: Exception in case of error
///
/// Returns: Config
Config readConfig(string filename){
	Tag root = parseFile(filename);
	Config ret;
	ret.name = root.getTagValue!string("name", "unnamed");
	ret.lang = root.getTagValue!string("lang", null);
	ret.compile = root.getTagValue!string("compile", null);
	ret.exec = root.getTagValue!string("exec", null);

	if (root.tags["test"].length)
		ret.testsAutodetect = false;
	ret.testsAutodetect = root.getTagValue!bool("tests-autodetect",
			ret.testsAutodetect);

	foreach (Tag tag; root.tags["test"]){
		Config.Test test;
		test.name = tag.getTagValue!string("name", null);
		test.points = tag.getTagValue!int("points", test.points);
		ret.tests ~= test;
	}

	return ret;
}
