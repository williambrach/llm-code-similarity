
show_help() {
    echo "Task 7 - Name Occurrence Finder (C)"
    echo ""
    echo "Syntax: $0 <-h> <-d depth> <path>"
    echo "<-h>: displays this help message"
    echo "<-d>: sets the search depth, followed by a natural number N"
    echo "<path>: the directory path to start the search"
}

collect_text_files() {
    local search_path="$1"
    if grep -qE "^find: .*" <<<"$search_path"; then
        echo "Find error" 1>&2
        exit 1
    else
        if file "$search_path" | grep -qi "text"; then
            if [[ -r "$search_path" ]]; then
                text_files+=("$search_path")
            fi
        fi
    fi
}

search_depth=""
search_path=""
text_files=()

while (("$#")); do
    case "$1" in
    -h)
        show_help
        exit 0
        ;;
    -d)
        shift
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            search_depth=$1
        else
            echo "Error: 'Invalid depth value -> $1'" 1>&2
            exit 1
        fi
        ;;
    -*)
        echo "Error: 'Invalid option -> $1'" 1>&2
        exit 1
        ;;
    *)
        if [[ -d "$1" ]]; then
            search_path="$1"
        else
            echo "Error: 'Invalid path / Directory does not exist -> $1'" 1>&2
            exit 1
        fi
        ;;
    esac
    shift
done

[[ -z "$search_path" ]] && search_path="."

find_command="find \"$search_path\" -type f"
[[ -n "$search_depth" ]] && find_command+=" -maxdepth $search_depth"
found_files=$($find_command 2>&1)

while IFS= read -r file_path; do
    collect_text_files "$file_path"
done <<< "$found_files"

for file in "${text_files[@]}"; do
    file_name=$(basename "$file")
    occurrences=$(grep -wc "$file_name" "$file")
    if [[ $occurrences -gt 0 ]]; then
        echo "Output: '$file $occurrences'"
    fi
done

exit 0
