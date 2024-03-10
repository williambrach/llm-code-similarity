
SEARCH_LIMIT=1000000
DIRECTORIES=()

display_usage() {
    echo "Usage: $0 [-h] [-d <depth_limit>] [path ...]"
    echo "Options:"
    echo "  -h: Display this help and exit"
    echo "  -d: Specify search depth limit"
    echo "  path: Directories to scan"
    exit 0
}

halt_on_failure() {
    echo "Failure: '$1' due to $2" >&2
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        display_usage
        ;;
    -d)
        shift
        SEARCH_LIMIT="$1"
        if ! [[ "$SEARCH_LIMIT" =~ ^[0-9]+$ ]]; then
            halt_on_failure "$SEARCH_LIMIT" "Depth limit must be a numeric value."
        fi
        shift
        ;;
    -*)
        halt_on_failure "$1" "Option not recognized."
        ;;
    *)
        DIRECTORIES+=("$1")
        shift
        ;;
    esac
done

if [ ${#DIRECTORIES[@]} -eq 0 ]; then
    DIRECTORIES=(".")
fi

scan_directories() {
    local path="$1"
    local depth="$2"
    if [ "$depth" -le 0 ]; then
        return
    fi
    if [ ! -d "$path" ]; then
        halt_on_failure "$path" "Directory does not exist."
    fi
    for entry in "$path"/*; do
        if [ -d "$entry" ]; then
            scan_directories "$entry" $((depth - 1))
        elif [ -f "$entry" ]; then
            type=$(file --brief --mime-type "$entry")
            if [[ $type == text/* ]]; then
                name=$(basename "$entry")
                count=$(grep -cF -- "$name" "$entry")
                if [ "$count" -gt 0 ]; then
                    echo "Match: '$entry $count'"
                fi
            fi
        fi
    done
}

for dir in "${DIRECTORIES[@]}"; do
    scan_directories "$dir" "$SEARCH_LIMIT"
done
exit 0
