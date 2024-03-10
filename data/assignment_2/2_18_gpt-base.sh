
#!/bin/bash

display_usage() {
    echo "How to use: $0 [OPTION]..."
    echo
    echo "Options:"
    echo "  -h          Show help information and exit"
    echo "  Provide file or directory paths to find the longest line."
    echo "  Reads from stdin if no arguments are given."
    echo
    echo "Note: Execute with bash, not sh."
}

if [ "$1" == "-h" ]; then
    display_usage
    exit 0
fi

max_length=0
declare -a max_lines

process_input() {
    local path="$1"
    local num=1
    local source

    if [ "$path" == "-" ]; then
        source="/dev/stdin"
    else
        source="$path"
    fi

    while IFS= read -r line; do
        local length=${#line}
        if (( length > max_length )); then
            max_length=$length
            max_lines=("$path: $num $length $line")
        elif (( length == max_length )); then
            max_lines+=("$path: $num $length $line")
        fi
        ((num++))
    done <"$source"
}

for arg in "${@:-"-"}"; do
    if [ "$arg" == "-" ]; then
        process_input "-"
    elif [ -f "$arg" ]; then
        process_input "$arg"
    elif [ -d "$arg" ]; then
        while IFS= read -r file; do
            process_input "$file"
        done < <(find "$arg" -type f)
    else
        echo "Error: '$arg' is not a valid file or directory" >&2
    fi
done

for line in "${max_lines[@]}"; do
    echo "Max Length: '$line'"
done
