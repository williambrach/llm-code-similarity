
display_help() {
    echo "Revised Task 2 (C)"
    echo "Usage: <revisedtask2> <arg1> <arg2> ..."
    echo "<filename>: finds the longest line in the file"
    echo "<-h>: displays this help text"
}

if [ $# -eq 0 ]; then
    > temp_file.txt
    while IFS= read -r input_line; do
        if [[ -z $input_line ]]; then
            break
        fi
        echo "$input_line" >> temp_file.txt
    done
    max_length=$(awk 'BEGIN{max=0} max<length{ max=length } END{print max}' temp_file.txt)
    awk -v maxlen="$max_length" -v fname="-" 'maxlen==length { print "Output: \047"fname":",NR,length,$0"\047" }' temp_file.txt
    rm temp_file.txt
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        display_help
        exit 0
        ;;
    *)
        if [ -e "$1" ]; then
            if [ -f "$1" ]; then
                if [ -r "$1" ]; then
                    max_length=$(awk 'BEGIN{max=0} max<length{ max=length } END{print max}' "$1")
                    awk -v maxlen="$max_length" -v fname="$1" 'maxlen==length { print "Output: \047"fname":",NR,length,$0"\047" }' "$1"
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
