
search_dir="."
show_usage() {
    echo "Usage Guide for Script"
    echo "Usage: \"$0 -m <search_depth> -s <search_directory>\""
    echo " -m <search_depth> defines how deep the search should go"
    echo " -s <search_directory> sets the directory to be searched"
    echo " -h shows this help message"
}
while getopts ":m:s:h" option; do
    case $option in
    m)
        max_depth="$OPTARG"
        ;;
    s)
        search_dir="$OPTARG"
        ;;
    h)
        show_usage
        exit 0
        ;;
    \?)
        echo "Error: Invalid option - $OPTARG" >&2
        show_usage
        exit 1
        ;;
    esac
done
if [ ! -d "$search_dir" ]; then
    echo "Error: $search_dir is not a valid directory" >&2
    exit 1
fi
if [ -z "$max_depth" ]; then
    symlink_list=($(find "$search_dir" -type l))
else
    if ((max_depth < 1)); then
        echo "Error: -m must be a positive integer, received $max_depth" >&2
        show_usage
        exit 1
    fi
    symlink_list=($(find "$search_dir" -maxdepth "$max_depth" -type l))
fi
if [ ${#symlink_list[@]} -eq 0 ]; then
    echo "No symbolic links found in $search_dir."
fi
longest_length=0
longest_links=()
for link in "${symlink_list[@]}"; do
    resolved_path=$(readlink -f "$link")
    path_length=$(echo "$resolved_path" | grep -o '/' | wc -l)
    if ((path_length == longest_length)); then
        longest_links+=("$link")
    fi
    if ((path_length > longest_length)); then
        longest_length=$path_length
        longest_links=("$link")
    fi
done
for link in "${longest_links[@]}"; do
    echo "$link -> $(readlink -f "$link")"
done
