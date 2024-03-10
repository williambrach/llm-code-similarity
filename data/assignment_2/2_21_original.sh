
#!/bin/bash

# Instructions for users
usage_guide() {
    echo
    echo "Guide for Finding the Longest Line"
    echo
    echo "Usage: $0 [path_to_file_or_directory1] [path_to_file_or_directory2] ... [path_to_file_or_directoryN]"
    echo "     [path_to_file_or_directory1] - A file or directory path"
    echo "     [path_to_file_or_directory2] - Another file or directory path"
    echo "     ..."
    echo "     [path_to_file_or_directoryN] - Yet another file or directory path"
    echo
    echo "Executes a search across given files or directories for the longest line present."
    echo "Execute by typing: bash $0."
}

# Variables to hold the longest line information
files_with_longest_line=()
line_numbers=()
lengths_of_longest_lines=()
longest_line_content=()
longest_length=0

# Function to identify the longest line within a file
find_longest_line() {
    local path="$1"
    local num=0
    local length=0
    while IFS= read -r line; do
        num=$((num + 1))
        length=${#line}
        if [ "$length" -ge "$longest_length" ]; then
            files_with_longest_line+=("$path")
            line_numbers+=("$num")
            lengths_of_longest_lines+=("$length")
            longest_line_content+=("$line")
            longest_length=$length
        fi
    done <"$path"
}

# Function to handle file or directory paths
process_path() {
    local element="$1"
    if [ -f "$element" ]; then
        find_longest_line "$element"
    elif [ -d "$element" ]; then
        while IFS= read -r discovered_file; do
            process_path "$discovered_file"
        done < <(find "$element" -type f)
    elif [ "$element" == "-" ]; then
        element="/dev/stdin"
        find_longest_line "$element"
    else
        echo "Error: Invalid path '$element'" >&2
        exit 1
    fi
}

# Iterate over all provided arguments
for arg in "${@:-"-"}"; do
    if [ "$arg" == "-h" ]; then
        usage_guide
        exit 0
    else
        process_path "$arg"
    fi
done

# Output the findings
for ((i = 0; i < ${#longest_line_content[@]}; i++)); do
    if [ "${lengths_of_longest_lines[i]}" -eq "$longest_length" ]; then
        echo "Longest Line Found: ${files_with_longest_line[i]}: ${line_numbers[i]} ${lengths_of_longest_lines[i]} ${longest_line_content[i]}"
    fi
done
