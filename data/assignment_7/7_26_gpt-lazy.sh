SEARCH_DEPTH=""
FOLDERS=()
display_help() {
    echo "$0 (C)"
    echo "Usage: $0 [-h][-s <search_depth>] [directory ...]"
    echo "   -h: Display help"
    echo "   -s: Specify search depth"
}
explore_topic() {
    local folder="$1"
    local depth="$2"
    if [[ -n "$SEARCH_DEPTH" && "$depth" -gt "$SEARCH_DEPTH" ]]; then
        return
    fi
    for element in "$folder"/*; do
        if [[ -d "$element" ]]; then
            explore_topic "$element" $((depth + 1))
        elif [[ -f "$element" && $(file --mime-type -b "$element") =~ ^text/ ]]; then
            file_name=$(basename "$element")
            if grep -q -- "$file_name" "$element"; then
                occurrences=$(grep -c -- "$file_name" "$element")
                echo "Found: '$element $occurrences'" >&1
            fi
        fi
    done
}
while (($# > 0)); do
    case $1 in
    -h)
        display_help
        exit 0
        ;;
    -s)
        if [[ -z $2 || $2 =~ ^- ]]; then
            echo "Error: 'Argument missing for': $1" >&2
            exit 1
        fi
        SEARCH_DEPTH="$2"
        shift
        ;;
    -*)
        echo "Error: 'Unknown option': $1" >&2
        exit 1
        ;;
    *)
        FOLDERS+=("$1")
        ;;
    esac
    shift
done
if [ -z "${FOLDERS[*]}" ]; then
    FOLDERS=(".")
fi
for folder in "${FOLDERS[@]}"; do
    if [[ -d "$folder" ]]; then
        explore_topic "$folder" 1
    else
        echo "Error: '$folder': No such directory" >&2
    fi
done
exit 0
