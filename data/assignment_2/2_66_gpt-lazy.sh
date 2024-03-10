longest=0
info=()
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        echo "Usage: $0 [-h] [path ...]"
        echo "	    -h: help"
        echo "	    path: specific files or empty, which means the script will read lines from stdin"
        exit 0
        ;;
    -*)
        echo "Error: Unknown option $1" >&2
        exit 1
        ;;
    *)
        files_list+=("$1")
        ;;
    esac
    shift
done
if [ ${#files_list[@]} -gt 0 ]; then
    for file_path in "${files_list[@]}"; do
        if [ -f "$file_path" ] && [ -r "$file_path" ]; then
            counter=0
            while IFS= read -r line_content; do
                ((counter++))
                line_length=${#line_content}
                if ((line_length > longest)); then
                    longest=$line_length
                    info=("$file_path: $counter $line_length $line_content")
                elif ((line_length == longest)); then
                    info+=("$file_path: $counter $line_length $line_content")
                fi
            done <"$file_path"
        else
            echo "Error: $file_path: File does not exist or cannot be read." >&2
        fi
    done
    readarray -td '' sorted_info < <(printf '%s\0' "${info[@]}" | sort -z)
else
    counter=0
    while IFS= read -r line_content; do
        ((counter++))
        line_length=${#line_content}
        if ((line_length > longest)); then
            longest=$line_length
            sorted_info=("-: $counter $line_length $line_content")
        elif ((line_length == longest)); then
            sorted_info+=("-: $counter $line_length $line_content")
        fi
    done
fi
for ((idx = 0; idx < "${#sorted_info[@]}"; idx += 1)); do
    echo "${sorted_info[idx]}"
done
