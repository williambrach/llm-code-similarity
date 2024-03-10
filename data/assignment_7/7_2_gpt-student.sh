
display_usage() {
    echo "Usage: $0 [options] [directory...]"
    echo ""
    echo "Options:"
    echo "  -h              Show this help message"
    echo "  -l <depth>      Specify search depth (default is 1)"
    echo "  directory       Directories to search in"
}

search_depth='1'
target_directories=()

while getopts "hl:" opt; do
    case $opt in
        h)
            display_usage
            exit 0
            ;;
        l)
            search_depth="$OPTARG"
            if ! [[ $search_depth =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: Depth must be a positive integer." >&2
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
    target_directories+=("$1")
    shift
done

if [ ${#target_directories[@]} -eq 0 ]; then
    target_directories=(".")
fi

found_files=()

for dir in "${target_directories[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a valid directory." >&2
        exit 1
    fi
    original_IFS=$IFS
    IFS=$'\n'
    while IFS= read -r -d $'\0' file; do
        if file "$file" | grep -qE 'text' && [ -r "$file" ]; then
            found_files+=("$file")
            file_name=$(basename "$file")
            occurrences=$(grep -c "$file_name" "$file")
            if [ $occurrences -gt 0 ]; then
                echo "$(realpath "$file") $occurrences"
            fi
        fi
    done < <(find "$dir" -maxdepth "$search_depth" -type f -print0 2>/dev/null)
    IFS=$original_IFS
done
