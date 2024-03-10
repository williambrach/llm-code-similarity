show_instructions() {
    echo "Task 2 Modified (C)"
    echo "How to use: <task2mod> <param1> <param2> ..."
    echo "<file>: identifies the longest line within the file"
    echo "<-h>: shows this message"
}
if [ $# -lt 1 ]; then
    rm input.txt 2>/dev/null
    while IFS=$'\n' read -r line; do
        if [[ -z $line ]]; then
            break
        fi
        echo "$line" >>input.txt
    done
    longest=$(awk 'BEGIN{longest=0} longest<length{ longest=length } END{print longest}' input.txt)
    awk -v x="$longest" -v file="-" 'x==length { print "Result: \047"file":",NR,length,$0"\047" }' input.txt
    rm input.txt
    exit 0
fi
while (($#)); do
    case "$1" in
    -h)
        show_instructions
        exit 0
        ;;
    esac
    if [ -e "$1" ]; then
        if [ -f "$1" ]; then
            if [ -r "$1" ]; then
                longest=$(awk 'BEGIN{longest=0} longest<length{ longest=length } END{print longest}' "$1")
                awk -v x="$longest" -v file="$1" 'x==length { print "Result: \047"file":",NR,length,$0"\047" }' "$1"
            else
                echo "Error: '$1': cannot read file" 1>&2
            fi
        else
            echo "Error: '$1': is a directory, not a file" 1>&2
        fi
    else
        echo "Error: '$1': no such file" 1>&2
    fi
    shift
done
