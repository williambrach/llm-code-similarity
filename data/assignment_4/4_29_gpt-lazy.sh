show_instructions() {
        echo "TASK 4"
        echo "Usage : $0 [-h] [-d <depth>] [path ...]"
        echo "        -h: Display help message"
        echo "        -d N: Set depth for option -d"
        echo "        <dir1 dir2 ...>: Directories separated by space to search in, if no directory is specified, the script searches the current directory"
}
unset search_depth
unset directories
while (($#)); do
        case "$1" in
        -h) # Display help
                show_instructions
                exit 0
                ;;
        -d) # Depth option
                if [ $# -lt 2 ]; then
                        echo "Error: '-d': Insufficient arguments for option -d!" 1>&2
                        exit 1
                fi
                if ! [[ $2 =~ ^[0-9]+$ ]]; then
                        echo "Error '-d $2': Option -d requires a positive integer!" 1>&2
                        exit 1
                fi
                if [ "$2" -lt 1 ]; then
                        echo "Error '-d $2': Depth for option -d cannot be less than 1!" 1>&2
                        exit 1
                fi
                shift
                search_depth=$1
                ;;
        -*) # Incorrect option
                echo "Error: '$1': Unknown option!" 1>&2
                exit 1
                ;;
        *) # Check if the specified directory exists
                if [[ ! -d "$1" ]]; then
                        echo "Error '$1': Unknown directory!" 1>&2
                        exit 1
                fi
                if [[ ! " ${directories[*]} " =~ ${1} ]]; then
                        directories+=("$1")
                fi
                ;;
        esac
        shift
done
if [ -z "${directories[*]}" ]; then
        directories=("$(pwd)")
fi
find_longest_symlinks() {
        local dir_path=$1
        local symlink_list=()
        local resolved_paths=()
        if [ -z "$search_depth" ]; then
                while IFS= read -r -d '' symlink; do
                        symlink_list+=("$symlink")
                        resolved_paths+=("$(readlink -f "$symlink")")
                done < <(find "$dir_path" -type l -print0)
        else
                while IFS= read -r -d '' symlink; do
                        symlink_list+=("$symlink")
                        resolved_paths+=("$(readlink -f "$symlink")")
                done < <(find "$dir_path" -maxdepth "$search_depth" -type l -print0)
        fi
        longest=0
        for ((i = 0; i < ${#resolved_paths[@]}; i++)); do
                if [ "$(echo "${resolved_paths[$i]}" | grep -o "/" | wc -l)" -gt "$longest" ]; then
                        longest=$(echo "${resolved_paths[$i]}" | grep -o "/" | wc -l)
                fi
        done
        for ((i = 0; i < ${#symlink_list[@]}; i++)); do
                if [ "$(echo "${resolved_paths[$i]}" | grep -o "/" | wc -l)" -eq "$longest" ]; then
                        echo "Result: '${symlink_list[$i]} -> ${resolved_paths[$i]}'"
                fi
        done
}
for dir in "${directories[@]}"; do
        find_longest_symlinks "$dir"
done
exit 0
