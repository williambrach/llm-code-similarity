search_depth=1
directories=()
while getopts ":hs:" option; do
        case $option in
        h)
                echo "Homework 7 (C)"$'\n'$'\n'"Usage: homework.sh -s [search_depth] [directory/s]"$'\n'$'\t'"search_depth: Limit search to a specific depth within [directory] argument"$'\n'$'\t'"directory: The directory to search. If not specified, searches in current directory."
                exit 0
                ;;
        s)
                search_depth="$OPTARG"
                ;;
        \?)
                echo "Error: 'Invalid option: -$OPTARG'" >&2
                exit 1
                ;;
        :)
                echo "Error: 'Option -$OPTARG requires an argument'" >&2
                exit 1
                ;;
        esac
done
if ! [[ "$search_depth" =~ ^[0-9]+$ ]]; then
        echo "Error: 'Invalid search_depth value: $search_depth. Must be a valid number'" >&2
        exit 1
else
        if (("$search_depth" < 1)); then
                echo "Error: 'Invalid search_depth value. Must be greater than 0'" >&2
                exit 1
        fi
fi
shift $((OPTIND - 1))
directories=("$@")
if [ -z "${directories[*]}" ]; then
        directories=("$PWD/")
fi
echo "Debug: Search Depth - $search_depth"$'\n'"Debug: Searching in ${directories[*]}"
for directory in "${directories[@]}"; do
        echo "Debug: $directory"
        if [ -n "$(find "$directory" -maxdepth "$search_depth" -type f 2>/dev/null)" ]; then
                find "$directory" -maxdepth "$search_depth" -type f -print0 | while IFS= read -r -d '' item; do
                        itemname=$(basename "$item" | cut -d"." -f1)
                        if [ -n "$itemname" ]; then
                                occurrences=$(awk -v pattern="$itemname" 'BEGIN { occurrences = 0 } { occurrences += gsub(pattern, "") } END { print occurrences }' "$item")
                                if [[ "$occurrences" =~ ^[0-9]+$ && "$occurrences" -gt 0 ]]; then
                                        echo "$item $occurrences"
                                fi
                        fi
                done
        else
                echo "Error: '$directory: no such file or directory'"
        fi
done
