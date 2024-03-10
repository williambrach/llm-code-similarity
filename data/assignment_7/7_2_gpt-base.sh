
show_help() {
    echo "How to use: $0 [flags] [path...]"
    echo ""
    echo "Flags:"
    echo "  -h              Display help information"
    echo "  -l <level>      Set the search level (default is 1)"
    echo "  path            Paths to look into"
}

level_search='1'
paths_to_search=()

while getopts "hl:" option; do
    case $option in
        h)
            show_help
            exit 0
            ;;
        l)
            level_search="$OPTARG"
            if ! [[ $level_search =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: Level must be a positive number." >&2
                exit 1
            fi
            ;;
        \?)
            echo "Error: Unrecognized flag. Use -h for help." >&2
            exit 1
            ;;
        :)
            echo "Error: Flag -$OPTARG needs a value." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

while [ $# -gt 0 ]; do
    paths_to_search+=("$1")
    shift
done

if [ ${#paths_to_search[@]} -eq 0 ]; then
    paths_to_search=(".")
fi

discovered_files=()

for path in "${paths_to_search[@]}"; do
    if [ ! -d "$path" ]; then
        echo "Error: $path is not a directory." >&2
        exit 1
    fi
    save_IFS=$IFS
    IFS=$'\n'
    while IFS= read -r -d $'\0' item; do
        if file "$item" | grep -qE 'text' && [ -r "$item" ]; then
            discovered_files+=("$item")
            item_name=$(basename "$item")
            count=$(grep -c "$item_name" "$item")
            if [ $count -gt 0 ]; then
                echo "$(realpath "$item") $count"
            fi
        fi
    done < <(find "$path" -maxdepth "$level_search" -type f -print0 2>/dev/null)
    IFS=$save_IFS
done
