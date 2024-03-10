
#!/bin/bash

# Setting initial values
maxLength=0
recordLines=()
countLines=0
inputFiles=()

# Help function
showHelp() {
    echo "How to use: $0 [-h] [file ...]"
    echo "Options:"
    echo "  -h  Display help information"
    echo "  file  Define file(s) for analysis. Defaults to stdin if no file is specified."
}

# Handling command line inputs
for option in "$@"; do
    if [ "$option" = "-h" ]; then
        showHelp
        exit 0
    elif echo "$option" | grep -E -q '^-[a-gi-zA-Z]'; then
        echo "Error: Invalid option '$option'" >&2
        exit 1
    elif [ ! -f "$option" ]; then
        echo "Error: Cannot locate file '$option'" >&2
        exit 1
    else
        inputFiles+=("$option")
    fi
done

# If no files are specified, read from stdin
[ ${#inputFiles[@]} -eq 0 ] && inputFiles+=("-")

# Function to print the longest line(s)
printLongestLines() {
    for entry in "${recordLines[@]}"; do
        echo "$currentInput: $entry"
    done
    recordLines=()
    maxLength=0
}

# Analyzing each specified file or stdin
for currentInput in "${inputFiles[@]}"; do
    maxLength=0
    countLines=0
    if [ "$currentInput" = "-" ]; then
        while IFS= read -r line; do
            ((countLines++))
            if [ -z "$line" ]; then
                printLongestLines
                exit 0
            fi
            len=${#line}
            if [ "$len" -gt "$maxLength" ]; then
                recordLines=("$countLines $len $line")
                maxLength=$len
            elif [ "$len" -eq "$maxLength" ]; then
                recordLines+=("$countLines $len $line")
            fi
        done
    else
        while IFS= read -r line; do
            ((countLines++))
            [ -z "$line" ] && continue
            len=${#line}
            if [ "$len" -ge "$maxLength" ]; then
                [ "$len" -gt "$maxLength" ] && recordLines=() && maxLength=$len
                recordLines+=("$countLines $len $line")
            fi
        done <"$currentInput"
    fi
    printLongestLines
done
