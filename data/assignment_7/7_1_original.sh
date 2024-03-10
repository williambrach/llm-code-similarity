
SEARCH_DEPTH_LIMIT=1000000
SEARCH_PATHS=()

display_usage() {
    echo "How to use: $0 [-h] [-d <depth_limit>] [path ...]"
    echo "Flags:"
    echo "  -h: Display this message and exit"
    echo "  -d: Specify search depth limit"
    echo "  path: Paths to include in search"
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
        SEARCH_DEPTH_LIMIT="$1"
        if ! [[ "$SEARCH_DEPTH_LIMIT" =~ ^[0-9]+$ ]]; then
            halt_on_failure "$SEARCH_DEPTH_LIMIT" "Depth limit must be an integer."
        fi
        shift
        ;;
    -*)
        halt_on_failure "$1" "Unrecognized flag."
        ;;
    *)
        SEARCH_PATHS+=("$1")
        shift
        ;;
    esac
done

if [ ${#SEARCH_PATHS[@]} -eq 0 ]; then
    SEARCH_PATHS=(".")
fi

search_folders() {
    local dir="$1"
    local depth="$2"
    if [ "$depth" -le 0 ]; then
        return
    fi
    if [ ! -d "$dir" ]; then
        halt_on_failure "$dir" "Path does not exist."
    fi
    for entry in "$dir"/*; do
        if [ -d "$entry" ]; then
            search_folders "$entry" $((depth - 1))
        elif [ -f "$entry" ]; then
            type=$(file --brief --mime-type "$entry")
            if [[ $type == text/* ]]; then
                entry_name=$(basename "$entry")
                occurrences=$(grep -cF -- "$entry_name" "$entry")
                if [ "$occurrences" -gt 0 ]; then
                    echo "Match: '$entry $occurrences'"
                fi
            fi
        fi
    done
}

for path in "${SEARCH_PATHS[@]}"; do
    search_folders "$path" "$SEARCH_DEPTH_LIMIT"
done
exit 0
