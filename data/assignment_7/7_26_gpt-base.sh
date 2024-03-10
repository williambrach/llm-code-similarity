
DEPTH_LIMIT=""
DIRS_TO_SEARCH=()
show_usage() {
    echo "How to use: $0 [-h] [-d <depth_limit>] [directory ...]"
    echo "   -h: Display help"
    echo "   -d: Define depth limit"
}
scan_dir() {
    local path="$1"
    local depth="$2"
    if [[ -n "$DEPTH_LIMIT" && "$depth" -gt "$DEPTH_LIMIT" ]]; then
        return
    fi
    for item in "$path"/*; do
        if [[ -d "$item" ]]; then
            scan_dir "$item" $((depth + 1))
        elif [[ -f "$item" && $(file --mime-type -b "$item") =~ ^text/ ]]; then
            file_name=$(basename "$item")
            if grep -q -- "$file_name" "$item"; then
                match_count=$(grep -c -- "$file_name" "$item")
                echo "Found: '$item $match_count'" >&1
            fi
        fi
    done
}
while (($#)); do
    case $1 in
    -h)
        show_usage
        exit 0
        ;;
    -d)
        if [[ -z $2 || $2 =~ ^- ]]; then
            echo "Error: 'Argument missing for': $1" >&2
            exit 1
        fi
        DEPTH_LIMIT="$2"
        shift
        ;;
    -*)
        echo "Error: 'Option not recognized': $1" >&2
        exit 1
        ;;
    *)
        DIRS_TO_SEARCH+=("$1")
        ;;
    esac
    shift
done
if [ ${#DIRS_TO_SEARCH[@]} -eq 0 ]; then
    DIRS_TO_SEARCH=(".")
fi
for dir in "${DIRS_TO_SEARCH[@]}"; do
    if [[ -d "$dir" ]]; then
        scan_dir "$dir" 1
    else
        echo "Error: 'No such directory': $dir" >&2
    fi
done
exit 0
