
display_usage() {
    echo "App Title (C)" >&1
    echo "How to use: $0 [-h] [-d <level>] [directory ...]" >&1
    echo "-h: Show this help message" >&1
    echo "-d <level>: Only go <level> levels deep into directories from the arguments." >&1
    echo "directory: Directories to look into (uses current directory by default if none are given)" >&1
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
                echo "Match: '$entry $occurrences'" >&1
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
        display_usage
        ;;
    d)
        if [ -z "$OPTARG" ] || [[ $OPTARG == -* ]]; then
            echo "Error: -d needs a numeric value." >&2
            exit 4
        elif [[ $OPTARG =~ ^[0-9]+$ ]]; then
            depth_level="$OPTARG"
        else
            echo "Error: Depth should be numeric: $OPTARG" >&2
            exit 3
        fi
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 6
        ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "$depth_level" ]; then
    depth_level=-1
fi

if [ "$depth_level" -lt 1 ] && [ "$depth_level" -ne -1 ]; then
    echo "Error: Invalid depth value." >&2
    exit 2
fi

if [ "$#" -eq 0 ]; then
    search_directory "." "$depth_level"
else
    for dir in "$@"; do
        if [ ! -e "$dir" ]; then
            echo "Warning: Directory '$dir' is not found." >&2
        else
            search_directory "$dir" "$depth_level"
        fi
    done
fi
exit 0
