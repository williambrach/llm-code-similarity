
depth_limit=1
folder_list=()
while getopts ":hd:" opt; do
    case $opt in
    h)
        echo "Usage Guide"$'\n'$'\n'"Command: script.sh -d [depth_limit] [folder/s]"$'\n'$'\t'"depth_limit: Set a limit for depth search in [folder] argument"$'\n'$'\t'"folder: Target folder for search. Defaults to current folder if not specified."
        exit 0
        ;;
    d)
        depth_limit="$OPTARG"
        ;;
    ?)
        echo "Error: Unknown option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Option -$OPTARG needs a value" >&2
        exit 1
        ;;
    esac
done
if ! [[ "$depth_limit" =~ ^[0-9]+$ ]]; then
    echo "Error: 'depth_limit value $depth_limit is not a number'" >&2
    exit 1
elif (( "$depth_limit" < 1 )); then
    echo "Error: 'depth_limit must be at least 1'" >&2
    exit 1
fi
shift $((OPTIND-1))
folder_list=("$@")
if [ ${#folder_list[@]} -eq 0 ]; then
    folder_list=("$PWD/")
fi
echo "Debug: Depth Limit - $depth_limit"$'\n'"Debug: Folders to search: ${folder_list[*]}"
for folder in "${folder_list[@]}"; do
    echo "Debug: Processing $folder"
    if [ -n "$(find "$folder" -maxdepth "$depth_limit" -type f 2>/dev/null)" ]; then
        find "$folder" -maxdepth "$depth_limit" -type f -print0 | while IFS= read -r -d '' file; do
            filename=$(basename "$file" | cut -d"." -f1)
            if [ -n "$filename" ]; then
                count=$(awk -v name="$filename" 'BEGIN { count=0 } { count+=gsub(name,"") } END { print count }' "$file")
                if [[ "$count" =~ ^[0-9]+$ && "$count" -gt 0 ]]; then
                    echo "$file $count"
                fi
            fi
        done
    else
        echo "Error: No valid files in $folder"
    fi
done
