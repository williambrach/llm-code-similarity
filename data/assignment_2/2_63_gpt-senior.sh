
#!/bin/bash

# Initialize variables
max_len=0
longest_lines=()
num_lines=0
paths=()

# Function to display help
show_usage() {
    echo "Usage: $0 [-h] [file ...]"
    echo "Options:"
    echo "  -h  Show this help message"
    echo "  file  Specify file(s) to process. Reads from stdin if no file is provided."
}

# Parse command line arguments
for arg in "$@"; do
    if [ "$arg" = "-h" ]; then
        show_usage
        exit 0
    elif echo "$arg" | grep -E -q '^-[a-gi-zA-Z]'; then
        echo "Error: Unknown option '$arg'" >&2
        exit 1
    elif [ ! -f "$arg" ]; then
        echo "Error: File '$arg' not found" >&2
        exit 1
    else
        paths+=("$arg")
    fi
done

# Default to stdin if no files are provided
[ ${#paths[@]} -eq 0 ] && paths+=("-")

# Function to output the longest lines
print_longest_lines() {
    for line in "${longest_lines[@]}"; do
        echo "$current_path: $line"
    done
    longest_lines=()
    max_len=0
}

# Process each file or stdin
for current_path in "${paths[@]}"; do
    max_len=0
    num_lines=0
    if [ "$current_path" = "-" ]; then
        while IFS= read -r line; do
            ((num_lines++))
            if [ -z "$line" ]; then
                print_longest_lines
                exit 0
            fi
            line_len=${#line}
            if [ "$line_len" -gt "$max_len" ]; then
                longest_lines=("$num_lines $line_len $line")
                max_len=$line_len
            elif [ "$line_len" -eq "$max_len" ]; then
                longest_lines+=("$num_lines $line_len $line")
            fi
        done
    else
        while IFS= read -r line; do
            ((num_lines++))
            [ -z "$line" ] && continue
            line_len=${#line}
            if [ "$line_len" -ge "$max_len" ]; then
                [ "$line_len" -gt "$max_len" ] && longest_lines=() && max_len=$line_len
                longest_lines+=("$num_lines $line_len $line")
            fi
        done <"$current_path"
    fi
    print_longest_lines
done
