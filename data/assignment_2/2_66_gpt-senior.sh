
max_length=0
details=()

process_input() {
    local line_num=0
    local line
    while IFS= read -r line; do
        ((line_num++))
        local len=${#line}
        if ((len > max_length)); then
            max_length=$len
            details=("$1: $line_num $len $line")
        elif ((len == max_length)); then
            details+=("$1: $line_num $len $line")
        fi
    done
}

parse_args() {
    while [ $# -ne 0 ]; do
        case $1 in
        -h|--help)
            echo "Usage: $0 [-h] [path ...]"
            echo "      -h: Display this help message"
            echo "      path: Paths to files or none to read from stdin"
            exit 0
            ;;
        -*)
            echo "Error: Invalid option $1" >&2
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
    process_input "-"
else
    for file in "${input_files[@]}"; do
        if [ -f "$file" ] && [ -r "$file" ]; then
            process_input "$file" <"$file"
        else
            echo "Error: Cannot read $file" >&2
        fi
    done
fi

IFS=$'\0' sorted_details=($(sort -z <<<"${details[*]}"))
unset IFS

for detail in "${sorted_details[@]}"; do
    echo "$detail"
done
