
#!/bin/bash

# Display usage instructions
show_help() {
    echo
    echo "Longest Line Finder - Usage Guide"
    echo
    echo "Syntax: $0 <path1> <path2> ... <pathN>"
    echo "     <path1> - Path to a file or directory"
    echo "     <path2> - Another path to a file or directory"
    echo "     ..."
    echo "     <pathN> - Additional path to a file or directory"
    echo
    echo "This script searches through the specified files and directories to locate the longest line."
    echo "To run, type: bash $0."
}

# Initialize arrays to store the longest line details
file_names=()
line_nums=()
line_lengths=()
lines_content=()
longest_length=0

# Function to find the longest line in a file
find_longest_line() {
    local path="$1"
    local num=0
    local length=0
    while IFS= read -r line; do
        num=$((num + 1))
        length=${#line}
        if [ "$length" -ge "$longest_length" ]; then
            file_names+=("$path")
            line_nums+=("$num")
            line_lengths+=("$length")
            lines_content+=("$line")
            longest_length=$length
        fi
    done <"$path"
}

# Process files and directories
process_path() {
    local element="$1"
    if [ -f "$element" ]; then
        find_longest_line "$element"
    elif [ -d "$element" ]; then
        while IFS= read -r file; do
            process_path "$file"
        done < <(find "$element" -type f)
    elif [ "$element" == "-" ]; then
        element="/dev/stdin"
        find_longest_line "$element"
    else
        echo "Error: '$element' is not a valid path" >&2
        exit 1
    fi
}

# Main loop to process all arguments
for arg in "${@:-"-"}"; do
    if [ "$arg" == "-h" ]; then
        show_help
        exit 0
    else
        process_path "$arg"
    fi
done

# Display results
for ((i = 0; i < ${#lines_content[@]}; i++)); do
    if [ "${line_lengths[i]}" -eq "$longest_length" ]; then
        echo "Longest Line: ${file_names[i]}: ${line_nums[i]} ${line_lengths[i]} ${lines_content[i]}"
    fi
done
