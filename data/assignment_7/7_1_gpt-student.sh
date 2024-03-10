
MAX_DEPTH=1000000
TARGET_DIRS=()

show_help() {
    echo "Usage: $0 [-h] [-m <max_depth>] [directory ...]"
    echo "Options:"
    echo "  -h: Show help and exit"
    echo "  -m: Set maximum search depth"
    echo "  directory: Directories to search"
    exit 0
}

exit_on_error() {
    echo "Error: '$1' caused by $2" >&2
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        show_help
        ;;
    -m)
        shift
        MAX_DEPTH="$1"
        if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
            exit_on_error "$MAX_DEPTH" "Maximum depth must be a numeric value."
        fi
        shift
        ;;
    -*)
        exit_on_error "$1" "Invalid option."
        ;;
    *)
        TARGET_DIRS+=("$1")
        shift
        ;;
    esac
done

if [ ${#TARGET_DIRS[@]} -eq 0 ]; then
    TARGET_DIRS=(".")
fi

explore_directories() {
    local current_dir="$1"
    local current_depth="$2"
    if [ "$current_depth" -le 0 ]; then
        return
    fi
    if [ ! -d "$current_dir" ]; then
        exit_on_error "$current_dir" "Directory not found."
    fi
    for item in "$current_dir"/*; do
        if [ -d "$item" ]; then
            explore_directories "$item" $((current_depth - 1))
        elif [ -f "$item" ]; then
            mime_type=$(file --brief --mime-type "$item")
            if [[ $mime_type == text/* ]]; then
                file_name=$(basename "$item")
                match_count=$(grep -cF -- "$file_name" "$item")
                if [ "$match_count" -gt 0 ]; then
                    echo "Found: '$item $match_count'"
                fi
            fi
        fi
    done
}

for target_dir in "${TARGET_DIRS[@]}"; do
    explore_directories "$target_dir" "$MAX_DEPTH"
done
exit 0
