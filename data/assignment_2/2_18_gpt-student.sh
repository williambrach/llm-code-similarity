
#!/bin/bash

show_help() {
    echo "Usage: $0 [OPTION]..."
    echo
    echo "Options:"
    echo "  -h          Display this help and exit"
    echo "  Arguments can be paths to files or directories for searching the longest line."
    echo "  If no arguments are provided, reads from standard input."
    echo
    echo "Note: Use bash to execute this script, not sh."
}

if [ "$1" == "-h" ]; then
    show_help
    exit 0
fi

longest_length=0
declare -a longest_lines

analyze_input() {
    local input_path="$1"
    local line_number=1
    local input_source

    if [ "$input_path" == "-" ]; then
        input_source="/dev/stdin"
    else
        input_source="$input_path"
    fi

    while IFS= read -r line; do
        local line_length=${#line}
        if (( line_length > longest_length )); then
            longest_length=$line_length
            longest_lines=("$input_path: $line_number $line_length $line")
        elif (( line_length == longest_length )); then
            longest_lines+=("$input_path: $line_number $line_length $line")
        fi
        ((line_number++))
    done <"$input_source"
}

for argument in "${@:-"-"}"; do
    if [ "$argument" == "-" ]; then
        analyze_input "-"
    elif [ -f "$argument" ]; then
        analyze_input "$argument"
    elif [ -d "$argument" ]; then
        while IFS= read -r found_file; do
            analyze_input "$found_file"
        done < <(find "$argument" -type f)
    else
        echo "Error: '$argument' is not a valid file or directory" >&2
    fi
done

for longest_line in "${longest_lines[@]}"; do
    echo "Longest: '$longest_line'"
done
