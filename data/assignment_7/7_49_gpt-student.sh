
search_depth=1
directories=()
while getopts ":hd:" option; do
    case $option in
    h)
        echo "Usage Guide"$'\n'$'\n'"Command: script.sh -d [search_depth] [directory/s]"$'\n'$'\t'"search_depth: Set a limit for depth search in [directory] argument"$'\n'$'\t'"directory: Target directory for search. Defaults to current directory if not specified."
        exit 0
        ;;
    d)
        search_depth="$OPTARG"
        ;;
    ?)
        echo "Error: Unknown option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Option -$OPTARG requires a value" >&2
        exit 1
        ;;
    esac
done
if ! [[ "$search_depth" =~ ^[0-9]+$ ]]; then
    echo "Error: 'search_depth value $search_depth is not a number'" >&2
    exit 1
elif (( "$search_depth" < 1 )); then
    echo "Error: 'search_depth must be at least 1'" >&2
    exit 1
fi
shift $((OPTIND-1))
directories=("$@")
if [ ${#directories[@]} -eq 0 ]; then
    directories=("$PWD/")
fi
echo "Debug: Search Depth - $search_depth"$'\n'"Debug: Directories to search: ${directories[*]}"
for dir in "${directories[@]}"; do
    echo "Debug: Processing $dir"
    if [ -n "$(find "$dir" -maxdepth "$search_depth" -type f 2>/dev/null)" ]; then
        find "$dir" -maxdepth "$search_depth" -type f -print0 | while IFS= read -r -d '' file; do
            file_name=$(basename "$file" | cut -d"." -f1)
            if [ -n "$file_name" ]; then
                occurrences=$(awk -v name="$file_name" 'BEGIN { count=0 } { count+=gsub(name,"") } END { print count }' "$file")
                if [[ "$occurrences" =~ ^[0-9]+$ && "$occurrences" -gt 0 ]]; then
                    echo "$file $occurrences"
                fi
            fi
        done
    else
        echo "Error: No valid files in $dir"
    fi
done
