
target_directory="."
display_help() {
    echo "Script Usage Instructions"
    echo "Command: \"$0 -d <depth_level> -t <target_directory>\""
    echo " -d <depth_level> specifies the depth of the search"
    echo " -t <target_directory> indicates the directory for the search"
    echo " -h displays this help information"
}
while getopts ":d:t:h" opt; do
    case $opt in
    d)
        depth_limit="$OPTARG"
        ;;
    t)
        target_directory="$OPTARG"
        ;;
    h)
        display_help
        exit 0
        ;;
    *)
        echo "Error: Unrecognized option - $OPTARG" >&2
        display_help
        exit 1
        ;;
    esac
done
if [ ! -d "$target_directory" ]; then
    echo "Error: $target_directory does not exist as a directory" >&2
    exit 1
fi
if [ -z "$depth_limit" ]; then
    links_found=($(find "$target_directory" -type l))
else
    if ((depth_limit < 1)); then
        echo "Error: -d requires a positive integer, got $depth_limit" >&2
        display_help
        exit 1
    fi
    links_found=($(find "$target_directory" -maxdepth "$depth_limit" -type l))
fi
if [ ${#links_found[@]} -eq 0 ]; then
    echo "No symbolic links discovered in $target_directory."
fi
max_length=0
longest_symlinks=()
for symlink in "${links_found[@]}"; do
    target_path=$(readlink -f "$symlink")
    length_of_path=$(echo "$target_path" | awk -F'/' '{print NF-1}')
    if ((length_of_path == max_length)); then
        longest_symlinks+=("$symlink")
    fi
    if ((length_of_path > max_length)); then
        max_length=$length_of_path
        longest_symlinks=("$symlink")
    fi
done
for symlink in "${longest_symlinks[@]}"; do
    echo "$symlink -> $(readlink -f "$symlink")"
done
