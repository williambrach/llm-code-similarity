
SEARCH_DEPTH=""
SEARCH_DIRS=()
display_help() {
    echo "Usage: $0 [-h] [-d <search_depth>] [path ...]"
    echo "   -h: Show this message"
    echo "   -d: Specify search depth"
}
explore_directory() {
    local current_path="$1"
    local current_depth="$2"
    if [[ -n "$SEARCH_DEPTH" && "$current_depth" -gt "$SEARCH_DEPTH" ]]; then
        return
    fi
    for entry in "$current_path"/*; do
        if [[ -d "$entry" ]]; then
            explore_directory "$entry" $((current_depth + 1))
        elif [[ -f "$entry" && $(file --mime-type -b "$entry") =~ ^text/ ]]; then
            entry_name=$(basename "$entry")
            if grep -q -- "$entry_name" "$entry"; then
                occurrences=$(grep -c -- "$entry_name" "$entry")
                echo "Match: '$entry $occurrences'" >&1
            fi
        fi
    done
}
while (($#)); do
    case $1 in
    -h)
        display_help
        exit 0
        ;;
    -d)
        if [[ -z $2 || $2 =~ ^- ]]; then
            echo "Error: 'Missing argument for': $1" >&2
            exit 1
        fi
        SEARCH_DEPTH="$2"
        shift
        ;;
    -*)
        echo "Error: 'Invalid option': $1" >&2
        exit 1
        ;;
    *)
        SEARCH_DIRS+=("$1")
        ;;
    esac
    shift
done
if [ ${#SEARCH_DIRS[@]} -eq 0 ]; then
    SEARCH_DIRS=(".")
fi
for search_dir in "${SEARCH_DIRS[@]}"; do
    if [[ -d "$search_dir" ]]; then
        explore_directory "$search_dir" 1
    else
        echo "Error: 'Directory does not exist': $search_dir" >&2
    fi
done
exit 0
