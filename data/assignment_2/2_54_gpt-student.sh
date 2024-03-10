
#!/bin/bash

# Function to find longest lines
find_longest_lines() {
    local current_line line_size
    local -n ref_longest_lines=longest_lines ref_longest_size=longest_size ref_line_indices=line_indices
    longest_size=0
    local index=0
    while IFS= read -r current_line || [ -n "$current_line" ]; do
        ((index++))
        line_size=${#current_line}
        if (( line_size > longest_size )); then
            longest_size=$line_size
            ref_longest_lines=("$current_line")
            ref_line_indices=("$index")
        elif (( line_size == longest_size )); then
            ref_longest_lines+=("$current_line")
            ref_line_indices+=("$index")
        fi
    done
}

# Function to output longest lines and their details
output_longest_lines() {
    local -n lines=longest_lines indices=line_indices prefixes=file_prefixes
    for i in "${!lines[@]}"; do
        echo "Longest: '${prefixes[$i]}: ${indices[$i]} ${#lines[$i]} ${lines[$i]}'"
    done
}

# Main script logic
if [ "$#" -eq 0 ]; then
    read_from_stdin=true
elif [ "$1" = "-h" ]; then
    echo "Usage: $0 [-h] [file_path ...]"
    echo -e "\t-h: Show help."
    echo -e "\tfile_path: Path to file(s) or directory(ies)."
    exit 0
else
    read_from_stdin=false
fi

if $read_from_stdin; then
    longest_lines=()
    longest_size=0
    line_indices=()
    find_longest_lines longest_lines longest_size line_indices
    output_longest_lines longest_lines line_indices longest_lines
else
    while [ "$#" -gt 0 ]; do
        if [ -f "$1" ]; then
            longest_lines=()
            longest_size=0
            line_indices=()
            while IFS= read -r line; do
                find_longest_lines longest_lines longest_size line_indices
            done < "$1"
            file_prefixes=("$1")
            output_longest_lines longest_lines line_indices file_prefixes
        elif [ -d "$1" ]; then
            readarray -t files < <(find "$1" -type f)
            for file in "${files[@]}"; do
                longest_lines=()
                longest_size=0
                line_indices=()
                while IFS= read -r line; do
                    find_longest_lines longest_lines longest_size line_indices
                done < "$file"
                file_prefixes=("$file")
                output_longest_lines longest_lines line_indices file_prefixes
            done
        else
            echo "Error: '$1' is not valid." >&2
            exit 1
        fi
        shift
    done
fi
