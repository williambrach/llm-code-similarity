
display_usage() {
    echo "Utility to Find Name Occurrences in Text Files"
    echo ""
    echo "Usage: $0 [-h] [-d depth] [directory]"
    echo "-h: Show this help information"
    echo "-d: Specify search depth with a positive integer"
    echo "directory: Path to begin the search"
}

gather_text_files() {
    local dir="$1"
    if grep -qE "^find: .*" <<<"$dir"; then
        echo "Error in find command" >&2
        exit 1
    else
        if file "$dir" | grep -qi "text"; then
            if [[ -r "$dir" ]]; then
                found_text_files+=("$dir")
            fi
        fi
    fi
}

depth_option=""
start_dir=""
found_text_files=()

while [ "$#" -gt 0 ]; do
    case "$1" in
    -h)
        display_usage
        exit 0
        ;;
    -d)
        shift
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            depth_option=$1
        else
            echo "Error: 'Depth must be a positive integer -> $1'" >&2
            exit 1
        fi
        ;;
    -*)
        echo "Error: 'Unrecognized option -> $1'" >&2
        exit 1
        ;;
    *)
        if [[ -d "$1" ]]; then
            start_dir="$1"
        else
            echo "Error: 'Invalid directory path -> $1'" >&2
            exit 1
        fi
        ;;
    esac
    shift
done

[[ -z "$start_dir" ]] && start_dir="."

search_cmd="find \"$start_dir\" -type f"
[[ -n "$depth_option" ]] && search_cmd+=" -maxdepth $depth_option"
located_files=$($search_cmd 2>&1)

while IFS= read -r file; do
    gather_text_files "$file"
done <<< "$located_files"

for text_file in "${found_text_files[@]}"; do
    name_of_file=$(basename "$text_file")
    count=$(grep -wc "$name_of_file" "$text_file")
    if [[ $count -gt 0 ]]; then
        echo "Found: '$text_file $count'"
    fi
done

exit 0
