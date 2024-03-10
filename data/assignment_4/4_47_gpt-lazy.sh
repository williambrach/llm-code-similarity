search_path="."
help_info() {
        echo "Homework 4"
        echo "Usage: \"homework 4\" $0 -d <depth_limit> -c <search_path>"
        echo " -d <depth_limit> define the maximum search depth"
        echo " -c <search_path> define the directory to search in"
        echo " -h for help message"
}
while getopts ":d:c:h" option; do
        case $option in
        d)
                depth_limit="$OPTARG"
                ;;
        c)
                search_path="$OPTARG"
                ;;
        h)
                help_info
                exit 0
                ;;
        \?)
                echo "Invalid option: -$OPTARG" >&2
                help_info
                exit 1
                ;;
        esac
done
if [ ! -d "$search_path" ]; then
        echo "Error: directory $search_path does not exist" >&2
        exit 1
fi
if [[ -z "${depth_limit}" ]]; then
        links_found=($(find "$search_path" -type l))
else
        if ((depth_limit < 1)); then
                echo "Error: parameter -d must be greater than 0, received $depth_limit" >&2
                help_info
                exit 1
        fi
        links_found=($(find "$search_path" -maxdepth "$depth_limit" -type l))
fi
if [ "${#links_found[@]}" -eq 0 ]; then
        echo "No symbolic links found in $search_path."
fi
longest_length=0
longest_links=()
for link in "${links_found[@]}"; do
        resolved_path=$(readlink -f "$link")
        path_len=$(tr -cd '/' <<<"$resolved_path" | wc -c)
        if ((path_len == longest_length)); then
                longest_links+=("$link")
        fi
        if ((path_len > longest_length)); then
                longest_length=$path_len
                longest_links=("$link")
        fi
done
for link in "${longest_links[@]}"; do
        echo "$link -> $(readlink -f "$link")"
done
