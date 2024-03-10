
#!/bin/bash

# Initialize variables
maxLineLength=0
longestLineRecords=()
lineCount=0
filePaths=()

# Function to display help
displayHelp() {
    echo "Usage: $0 [-h] [file ...]"
    echo "Options:"
    echo "  -h  Show this help message"
    echo "  file  Specify file(s) to process. Reads from stdin if no file is provided."
}

# Parse command line arguments
for arg in "$@"; do
    if [ "$arg" = "-h" ]; then
        displayHelp
        exit 0
    elif echo "$arg" | grep -E -q '^-[a-gi-zA-Z]'; then
        echo "Error: Unknown option '$arg'" >&2
        exit 1
    elif [ ! -f "$arg" ]; then
        echo "Error: File '$arg' not found" >&2
        exit 1
    else
        filePaths+=("$arg")
    fi
done

# Default to stdin if no files are provided
[ ${#filePaths[@]} -eq 0 ] && filePaths+=("-")

# Function to output the longest lines
outputLongestLines() {
    for record in "${longestLineRecords[@]}"; do
        echo "$currentFile: $record"
    done
    longestLineRecords=()
    maxLineLength=0
}

# Process each file or stdin
for currentFile in "${filePaths[@]}"; do
    maxLineLength=0
    lineCount=0
    if [ "$currentFile" = "-" ]; then
        while IFS= read -r line; do
            ((lineCount++))
            if [ -z "$line" ]; then
                outputLongestLines
                exit 0
            fi
            lineLength=${#line}
            if [ "$lineLength" -gt "$maxLineLength" ]; then
                longestLineRecords=("$lineCount $lineLength $line")
                maxLineLength=$lineLength
            elif [ "$lineLength" -eq "$maxLineLength" ]; then
                longestLineRecords+=("$lineCount $lineLength $line")
            fi
        done
    else
        while IFS= read -r line; do
            ((lineCount++))
            [ -z "$line" ] && continue
            lineLength=${#line}
            if [ "$lineLength" -ge "$maxLineLength" ]; then
                [ "$lineLength" -gt "$maxLineLength" ] && longestLineRecords=() && maxLineLength=$lineLength
                longestLineRecords+=("$lineCount $lineLength $line")
            fi
        done <"$currentFile"
    fi
    outputLongestLines
done
