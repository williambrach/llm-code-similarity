
usageGuide() {
    echo "Task 7 - Locate Name Occurrences (C)"
    echo ""
    echo "Usage: $0 [-h] [-d depth] [directory]"
    echo "-h: shows this help information"
    echo "-d: specifies the search depth with a positive integer N"
    echo "[directory]: the directory to begin the search in"
}
gatherTextFiles() {
    local path="$1"
    if grep -qE "^find: .*" <<<"$path"; then
        echo "Error in find command" >&2
        exit 1
    else
        if file "$path" | grep -qi "text" && [[ -r "$path" ]]; then
            textFiles+=("$path")
        fi
    fi
}
textFiles=()
depthOption=""
directoryPath=""
for arg in "$@"; do
    case "$arg" in
    -h)
        usageGuide
        exit 0
        ;;
    -d)
        shift
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            depthOption="$1"
        else
            echo "Error: 'Depth value is not valid -> $1'" >&2
            exit 1
        fi
        ;;
    -*)
        echo "Error: 'Unrecognized option -> $arg'" >&2
        exit 1
        ;;
    *)
        if [[ -d "$arg" ]]; then
            directoryPath="$arg"
        else
            echo "Error: 'Invalid directory path -> $arg'" >&2
            exit 1
        fi
        ;;
    esac
    shift
done
[[ -z "$directoryPath" ]] && directoryPath="."
if [[ -n "$depthOption" ]]; then
    filesFound=$(find "$directoryPath" -maxdepth "$depthOption" -type f 2>&1)
else
    filesFound=$(find "$directoryPath" -type f 2>&1)
fi
while IFS= read -r file; do
    gatherTextFiles "$file"
done <<<"$filesFound"
for file in "${textFiles[@]}"; do
    name=$(basename -- "$file")
    count=$(grep -wc "$name" "$file")
    if [[ $count -gt 0 ]]; then
        echo "Result: '$file $count'"
    fi
done
exit 0
