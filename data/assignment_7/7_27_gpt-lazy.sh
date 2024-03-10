display_help() {
    echo "Application Name (C)" >&1
    echo "How to use: $0 [-h] [-d <level>] [directory ...]" >&1
    echo "-h: Show this help information" >&1
    echo "-d <level>: Only go into directories to the given level deep" >&1
    echo "directory: Directories to look into (defaults to the current directory if none provided)" >&1
    exit 0
}
explore_directory() {
    local directory="$1"
    local level="$2"
    local filename
    local line_count
    for item in "$directory"/*; do
        item=$(echo "$item" | sed -E 's#/{2,}#/#g; s#/$##')
        if [ -f "$item" ]; then
            filename="$(basename "$item")"
            filename="${filename%.*}"
            if grep -q -- "$filename" "$item"; then
                line_count=$(grep -c -- "$filename" "$item")
                echo "Result: '$item $line_count'" >&1
            fi
        elif [ -d "$item" ]; then
            if [ "$level" -ne -1 ] && [ "$level" -gt 1 ]; then
                explore_directory "$item" "$((level - 1))"
            else
                explore_directory "$item" -1
            fi
        fi
    done
}
while getopts ":hd:" option; do
    case "$option" in
    h)
        display_help
        ;;
    d)
        if [ -z "$OPTARG" ] || [[ $OPTARG == -* ]]; then
            echo "Error: Missing level argument for -d" >&2
            exit 4
        elif [[ $OPTARG =~ ^[0-9]+$ ]]; then
            level="$OPTARG"
        else
            echo "Error: Invalid level value: $OPTARG" >&2
            exit 3
        fi
        ;;
    \?)
        echo "Invalid command: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Command -$OPTARG needs a value." >&2
        exit 6
        ;;
    esac
done
shift $((OPTIND - 1))
if [ -z "$level" ]; then
    level=-1
fi
if [ "$level" -lt 1 ] && [ "$level" -ne -1 ]; then
    echo "Error: Incorrect level." >&2
    exit 2
fi
if [ "$#" -eq 0 ]; then
    explore_directory "." "$level"
else
    for directory in "$@"; do
        if [ ! -e "$directory" ]; then
            echo "Warning: The given directory '$directory' is not found." >&2
        else
            explore_directory "$directory" "$level"
        fi
    done
fi
exit 0
