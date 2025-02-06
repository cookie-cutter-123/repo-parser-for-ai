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

### Example input.txt
```shell
Path: /Users/igorloncarevic/workspaces/release-flow
Files:
openapi.yaml
README.md
main.go
pkg/fclient/changelog.go
```