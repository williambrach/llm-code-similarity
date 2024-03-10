
show_usage() {
    echo "Revised Task 2 (C)"
    echo "Usage: <revisedtask2> <arg1> <arg2> ..."
    echo "<filename>: finds the longest line in the file"
    echo "<-h>: displays this help text"
}

if [ $# -eq 0 ]; then
    temporary_file="temp_file.txt"
    > "$temporary_file"
    while IFS= read -r line; do
        if [[ -z $line ]]; then
            break
        fi
        echo "$line" >> "$temporary_file"
    done
    longest_line_length=$(awk 'BEGIN{max_length=0} max_length<length{ max_length=length } END{print max_length}' "$temporary_file")
    awk -v max_len="$longest_line_length" -v file_name="-" 'max_len==length { print "Output: \047"file_name":",NR,length,$0"\047" }' "$temporary_file"
    rm "$temporary_file"
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        show_usage
        exit 0
        ;;
    *)
        if [ -e "$1" ]; then
            if [ -f "$1" ]; then
                if [ -r "$1" ]; then
                    longest_line_length=$(awk 'BEGIN{max_length=0} max_length<length{ max_length=length } END{print max_length}' "$1")
                    awk -v max_len="$longest_line_length" -v file_name="$1" 'max_len==length { print "Output: \047"file_name":",NR,length,$0"\047" }' "$1"
                else
                    echo "Error: Cannot read file '$1'" >&2
                fi
            else
                echo "Error: '$1' is a directory, not a file" >&2
            fi
        else
            echo "Error: File '$1' does not exist" >&2
        fi
        ;;
    esac
    shift
done
