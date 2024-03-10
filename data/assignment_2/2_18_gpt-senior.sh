
#!/bin/bash

usage_guide() {
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
    usage_guide
    exit 0
fi

max_len=0
declare -a max_lines

process_content() {
    local path="$1"
    local num=1
    local source

    if [ "$path" == "-" ]; then
        source="/dev/stdin"
    else
        source="$path"
    fi

    while IFS= read -r content; do
        local len=${#content}
        if (( len > max_len )); then
            max_len=$len
            max_lines=("$path: $num $len $content")
        elif (( len == max_len )); then
            max_lines+=("$path: $num $len $content")
        fi
        ((num++))
    done <"$source"
}

for arg in "${@:-"-"}"; do
    if [ "$arg" == "-" ]; then
        process_content "-"
    elif [ -f "$arg" ]; then
        process_content "$arg"
    elif [ -d "$arg" ]; then
        while IFS= read -r file; do
            process_content "$file"
        done < <(find "$arg" -type f)
    else
        echo "Error: '$arg' is not a valid file or directory" >&2
    fi
done

for line in "${max_lines[@]}"; do
    echo "Longest: '$line'"
done
