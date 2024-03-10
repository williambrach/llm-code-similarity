
default_dir="."
display_help() {
    echo "Assignment 4 Guide"
    echo "Command format: \"$0 -d <max_depth> -p <target_directory>\""
    echo " -d <max_depth> sets the limit for directory depth search"
    echo " -p <target_directory> specifies the directory for searching"
    echo " -h displays this help message"
}
while getopts ":d:p:h" opt; do
    case $opt in
    d)
        depth="$OPTARG"
        ;;
    p)
        default_dir="$OPTARG"
        ;;
    h)
        display_help
        exit 0
        ;;
    *)
        echo "Error: Unknown option - $OPTARG" >&2
        display_help
        exit 1
        ;;
    esac
done
if [ ! -d "$default_dir" ]; then
    echo "Error: $default_dir is not a valid directory" >&2
    exit 1
fi
if [ -z "$depth" ]; then
    found_links=($(find "$default_dir" -type l))
else
    if ((depth < 1)); then
        echo "Error: -d must be a positive number, got $depth" >&2
        display_help
        exit 1
    fi
    found_links=($(find "$default_dir" -maxdepth "$depth" -type l))
fi
if [ ${#found_links[@]} -eq 0 ]; then
    echo "No symbolic links found in $default_dir."
fi
max_length=0
longest_symlinks=()
for symlink in "${found_links[@]}"; do
    target_path=$(readlink -f "$symlink")
    length=$(echo "$target_path" | grep -o '/' | wc -l)
    if ((length == max_length)); then
        longest_symlinks+=("$symlink")
    fi
    if ((length > max_length)); then
        max_length=$length
        longest_symlinks=("$symlink")
    fi
done
for symlink in "${longest_symlinks[@]}"; do
    echo "$symlink -> $(readlink -f "$symlink")"
done
