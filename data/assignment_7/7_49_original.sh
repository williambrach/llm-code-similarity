
depth_limit=1
target_dirs=()
while getopts ":hd:" opt; do
    case $opt in
    h)
        echo -e "How to Use"$'\n'$'\n'"Syntax: ./script.sh -d [depth_limit] [folder/s]"$'\n'$'\t'"depth_limit: Defines how deep the search should go in the specified folder"$'\n'$'\t'"folder: The folder to search in. Uses current folder by default."
        exit 0
        ;;
    d)
        depth_limit="$OPTARG"
        ;;
    ?)
        echo "Error: Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Missing value for option -$OPTARG" >&2
        exit 1
        ;;
    esac
done
if ! [[ "$depth_limit" =~ ^[0-9]+$ ]]; then
    echo "Error: 'depth_limit $depth_limit is not numeric'" >&2
    exit 1
elif (( "$depth_limit" < 1 )); then
    echo "Error: 'depth_limit must be 1 or more'" >&2
    exit 1
fi
shift $((OPTIND-1))
target_dirs=("$@")
if [ ${#target_dirs[@]} -eq 0 ]; then
    target_dirs=("$PWD/")
fi
echo "Debug: Depth Limit - $depth_limit"$'\n'"Debug: Folders to search: ${target_dirs[*]}"
for folder in "${target_dirs[@]}"; do
    echo "Debug: Checking $folder"
    if [ -n "$(find "$folder" -maxdepth "$depth_limit" -type f 2>/dev/null)" ]; then
        find "$folder" -maxdepth "$depth_limit" -type f -print0 | while IFS= read -r -d '' item; do
            item_name=$(basename "$item" | cut -d"." -f1)
            if [ -n "$item_name" ]; then
                count=$(awk -v name="$item_name" 'BEGIN { total=0 } { total+=gsub(name,"") } END { print total }' "$item")
                if [[ "$count" =~ ^[0-9]+$ && "$count" -gt 0 ]]; then
                    echo "$item $count"
                fi
            fi
        done
    else
        echo "Error: No files found in $folder"
    fi
done
