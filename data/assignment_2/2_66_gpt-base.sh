
max_line_len=0
line_info=()

process_file() {
    local line_num=0
    local line
    while IFS= read -r line; do
        ((line_num++))
        local len=${#line}
        if ((len > max_line_len)); then
            max_line_len=$len
            line_info=("$1: $line_num $len $line")
        elif ((len == max_line_len)); then
            line_info+=("$1: $line_num $len $line")
        fi
    done
}

parse_args() {
    while [ $# -gt 0 ]; do
        case $1 in
        -h|--help)
            echo "Usage: $0 [-h] [file ...]"
            echo "      -h: Show help"
            echo "      file: Specify file paths or none to read from stdin"
            exit 0
            ;;
        -*)
            echo "Error: Unrecognized option $1" >&2
            exit 1
            ;;
        *)
            input_files+=("$1")
            ;;
        esac
        shift
    done
}

parse_args "$@"

if [ ${#input_files[@]} -eq 0 ]; then
    process_file "-"
else
    for file in "${input_files[@]}"; do
        if [ -f "$file" ] && [ -r "$file" ]; then
            process_file "$file" <"$file"
        else
            echo "Error: File $file is not accessible" >&2
        fi
    done
fi

IFS=$'\0' sorted_info=($(sort -z <<<"${line_info[*]}"))
unset IFS

for info in "${sorted_info[@]}"; do
    echo "$info"
done
