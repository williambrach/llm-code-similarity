
usage_instructions() {
    echo "Application Name (C)" >&1
    echo "Usage: $0 [-h] [-d <depth>] [path ...]" >&1
    echo "-h: Display help text" >&1
    echo "-d <depth>: Descend at most <depth> levels of directories below the command line arguments." >&1
    echo "path: Paths to search (defaults to current directory if none specified)" >&1
    exit 0
}

search_directory() {
    local path="$1"
    local depth="$2"
    local file_name
    local occurrences
    for entry in "$path"/*; do
        entry=$(echo "$entry" | sed -E 's#/{2,}#/#g; s#/$##')
        if [ -f "$entry" ]; then
            file_name="$(basename "$entry")"
            file_name="${file_name%.*}"
            if grep -q -- "$file_name" "$entry"; then
                occurrences=$(grep -c -- "$file_name" "$entry")
                echo "Found: '$entry $occurrences'" >&1
            fi
        elif [ -d "$entry" ]; then
            if [ "$depth" -ne -1 ] && [ "$depth" -gt 1 ]; then
                search_directory "$entry" "$((depth - 1))"
            else
                search_directory "$entry" -1
            fi
        fi
    done
}

while getopts ":hd:" opt; do
    case "$opt" in
    h)
        usage_instructions
        ;;
    d)
        if [ -z "$OPTARG" ] || [[ $OPTARG == -* ]]; then
            echo "Error: -d requires a numerical argument." >&2
            exit 4
        elif [[ $OPTARG =~ ^[0-9]+$ ]]; then
            depth="$OPTARG"
        else
            echo "Error: Depth must be a number: $OPTARG" >&2
            exit 3
        fi
        ;;
    \?)
        echo "Unknown option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Missing argument for option: -$OPTARG" >&2
        exit 6
        ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "$depth" ]; then
    depth=-1
fi

if [ "$depth" -lt 1 ] && [ "$depth" -ne -1 ]; then
    echo "Error: Depth value is not valid." >&2
    exit 2
fi

if [ "$#" -eq 0 ]; then
    search_directory "." "$depth"
else
    for path in "$@"; do
        if [ ! -e "$path" ]; then
            echo "Warning: Path '$path' does not exist." >&2
        else
            search_directory "$path" "$depth"
        fi
    done
fi
exit 0
