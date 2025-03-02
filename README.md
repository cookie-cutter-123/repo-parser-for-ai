## Repo collector

A simple Bash script designed to read a list of files from an input file, locate them in a specified path, and then concatenate their contents into a single output file.
This is useful if you want to provide multiple files (e.g., source code, configuration files) to an AI model or any other tool that benefits from having all content in one place.

### Features
- Reads a path and a list of files from an input file. 
- Checks if the path is a Git repository and includes the tracked file listing for context. 
- Concatenates file contents into a single output file. 
- Provides basic error handling for missing paths, non-existent files, and usage mistakes.

### Usage
```shell
./collect_files.sh input.txt output.txt 
```

### Tip!
You can run the script for the first time to get the paths and then use them for the input.

### Example input.txt
```shell
Path: /Users/igorloncarevic/workspaces/mailerlite-tests/
Files:
src/test/java/net/loncarevic/utils/Constants.java
src/test/java/net/loncarevic/utils/LocatorUtils.java
src/test/java/net/loncarevic/utils/PopUpUtils.java
src/test/java/net/loncarevic/TestCase0001.java
```