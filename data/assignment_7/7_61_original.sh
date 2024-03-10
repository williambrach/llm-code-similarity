
show_help() {
    echo "Usage: $0 [options] [path...]"
    echo "Options:"
    echo "  -h  Show help information"
    echo "  -d <depth>  Set the depth of search (default is 1)"
    echo "  path  Directories to be searched"
}

depth='1'
directories=()

while getopts "hd:" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        d)
            depth="$OPTARG"
            if ! [[ $depth =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: Depth must be a positive number." >&2
                exit 1
            fi
            ;;
        ?)
            echo "Error: Unknown option. Use -h for help." >&2
            exit 1
            ;;
        :)
            echo "Error: Option requires an argument." >&2
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

matched_files=()

for dir in "${directories[@]}"; do
    if ! [ -d "$dir" ]; then
        echo "Error: $dir is not a directory" >&2
        exit 1
    fi
    save_IFS=$IFS
    IFS=$'\n'
    while IFS= read -r -d '' file; do
        if file "$file" | grep -q text && [ -r "$file" ]; then
            matched_files+=("$file")
            name=$(basename "$file")
            count=$(grep -ce "$name" "$file")
            if [ $count -gt 0 ]; then
                echo "$(realpath "$file") $count"
            fi
        fi
    done < <(find "$dir" -maxdepth "$depth" -type f -print0 2>&1)
    IFS=$save_IFS
done
