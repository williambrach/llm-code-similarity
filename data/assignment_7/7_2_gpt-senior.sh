
help_message() {
    echo "Usage: $0 [options] [directory...]"
    echo ""
    echo "Options:"
    echo "  -h              Show this help message"
    echo "  -l <level>      Specify search depth (default is 1)"
    echo "  directory       Directories to search in"
}

depth='1'
directories=()

while getopts "hl:" option; do
    case $option in
        h)
            help_message
            exit 0
            ;;
        l)
            depth="$OPTARG"
            if ! [[ $depth =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: Level must be a positive integer." >&2
                exit 1
            fi
            ;;
        \?)
            echo "Error: Invalid option. Use -h for help." >&2
            exit 1
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

while [ $# -gt 0 ]; do
    directories+=("$1")
    shift
done

if [ ${#directories[@]} -eq 0 ]; then
    directories=(".")
fi

declare -a matched_files

for directory in "${directories[@]}"; do
    if [ ! -d "$directory" ]; then
        echo "Error: $directory is not a valid directory." >&2
        exit 1
    fi
    save_IFS=$IFS
    IFS=$'\n'
    while IFS= read -r -d $'\0' item; do
        if file "$item" | grep -qE 'text' && [ -r "$item" ]; then
            matched_files+=("$item")
            item_name=$(basename "$item")
            count=$(grep -c "$item_name" "$item")
            if [ $count -gt 0 ]; then
                echo "$(realpath "$item") $count"
            fi
        fi
    done < <(find "$directory" -maxdepth "$depth" -type f -print0 2>/dev/null)
    IFS=$save_IFS
done
