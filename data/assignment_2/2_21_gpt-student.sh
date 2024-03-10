
#!/bin/bash

# Display usage instructions
display_usage() {
    echo
    echo "Longest Line Finder - Usage Guide"
    echo
    echo "Syntax: $0 <file_or_dir1> <file_or_dir2> ... <file_or_dirN>"
    echo "     <file_or_dir1> - Path to a file or directory"
    echo "     <file_or_dir2> - Another path to a file or directory"
    echo "     ..."
    echo "     <file_or_dirN> - Additional path to a file or directory"
    echo
    echo "This script searches through the specified files and directories to locate the longest line."
    echo "To run, type: bash $0."
}

# Initialize arrays to store the longest line details
longest_line_files=()
longest_line_numbers=()
longest_line_lengths=()
longest_lines=()
max_length=0

# Function to find the longest line in a file
search_longest_line() {
    local file_path="$1"
    local line_number=0
    local line_length=0
    while IFS= read -r line; do
        line_number=$((line_number + 1))
        line_length=${#line}
        if [ "$line_length" -ge "$max_length" ]; then
            longest_line_files+=("$file_path")
            longest_line_numbers+=("$line_number")
            longest_line_lengths+=("$line_length")
            longest_lines+=("$line")
            max_length=$line_length
        fi
    done <"$file_path"
}

# Process files and directories
handle_path() {
    local target="$1"
    if [ -f "$target" ]; then
        search_longest_line "$target"
    elif [ -d "$target" ]; then
        while IFS= read -r found_file; do
            handle_path "$found_file"
        done < <(find "$target" -type f)
    elif [ "$target" == "-" ]; then
        target="/dev/stdin"
        search_longest_line "$target"
    else
        echo "Error: '$target' is not a valid path" >&2
        exit 1
    fi
}

# Main loop to process all arguments
for input_arg in "${@:-"-"}"; do
    if [ "$input_arg" == "-h" ]; then
        display_usage
        exit 0
    else
        handle_path "$input_arg"
    fi
done

# Display results
for ((idx = 0; idx < ${#longest_lines[@]}; idx++)); do
    if [ "${longest_line_lengths[idx]}" -eq "$max_length" ]; then
        echo "Longest Line: ${longest_line_files[idx]}: ${longest_line_numbers[idx]} ${longest_line_lengths[idx]} ${longest_lines[idx]}"
    fi
done
