MAX_DEPTH=1000000
FOLDERS=()
show_help() {
    echo "$0 (C)"
    echo ""
    echo "Usage: $0 [-h][-m <max_depth>] [directory ...]"
    echo "   -h: Show this help message"
    echo "   -m: Set search max_depth"
    echo "   directory: Folders to search through"
    exit 0
}
exit_on_error() {
    echo "Error: '$1': $2" >&2
    exit 1
}
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h)
        show_help
        ;;
    -m)
        shift
        MAX_DEPTH="$1"
        if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
            exit_on_error "$MAX_DEPTH" "Invalid max_depth value. Must be a number."
        fi
        shift
        ;;
    -*)
        exit_on_error "$1" "Unrecognized option."
        ;;
    *)
        FOLDERS+=("$1")
        shift
        ;;
    esac
done
if [ ${#FOLDERS[@]} -eq 0 ]; then
    FOLDERS=(".")
fi
find_files() {
    local folder="$1"
    local max_depth="$2"
    if [ "$max_depth" -le 0 ]; then
        return
    fi
    if [ ! -d "$folder" ]; then
        exit_on_error "$folder" "Folder does not exist"
    fi
    for item in "$folder"/*; do
        if [ -d "$item" ]; then
            find_files "$item" $((max_depth - 1))
        elif [ -f "$item" ]; then
            item_type=$(file --brief --mime-type "$item")
            if [[ $item_type == text/* ]]; then
                item_name=$(basename "$item")
                occurrences=$(grep -cF -- "$item_name" "$item")
                if [ "$occurrences" -gt 0 ]; then
                    echo "Found: '$item $occurrences'"
                fi
            fi
        fi
    done
}
for folder in "${FOLDERS[@]}"; do
    find_files "$folder" "$MAX_DEPTH"
done
exit 0