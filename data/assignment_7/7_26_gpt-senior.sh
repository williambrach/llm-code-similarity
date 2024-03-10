
MAX_DEPTH=""
DIRS=()
show_usage() {
    echo "Usage: $0 [-h] [-d <max_depth>] [path ...]"
    echo "   -h: Show this message"
    echo "   -d: Set maximum search depth"
}
dig_deeper() {
    local path="$1"
    local level="$2"
    if [[ -n "$MAX_DEPTH" && "$level" -gt "$MAX_DEPTH" ]]; then
        return
    fi
    for item in "$path"/*; do
        if [[ -d "$item" ]]; then
            dig_deeper "$item" $((level + 1))
        elif [[ -f "$item" && $(file --mime-type -b "$item") =~ ^text/ ]]; then
            file_title=$(basename "$item")
            if grep -q -- "$file_title" "$item"; then
                count=$(grep -c -- "$file_title" "$item")
                echo "Match: '$item $count'" >&1
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
            echo "Error: 'Missing argument for': $1" >&2
            exit 1
        fi
        MAX_DEPTH="$2"
        shift
        ;;
    -*)
        echo "Error: 'Invalid option': $1" >&2
        exit 1
        ;;
    *)
        DIRS+=("$1")
        ;;
    esac
    shift
done
if [ ${#DIRS[@]} -eq 0 ]; then
    DIRS=(".")
fi
for dir in "${DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        dig_deeper "$dir" 1
    else
        echo "Error: 'Directory does not exist': $dir" >&2
    fi
done
exit 0
