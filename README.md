## Repo collector

It takes the files listed in input.txt from a single repository and combines them into output.txt.  
Additionally, it appends a repo's structure to the output,
ensuring all necessary information is consolidated into one file for the AI.

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