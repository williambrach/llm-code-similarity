exec 2>error_output.log

default_reports=10

if [ -e helper_file ]; then
    input_file=$(cat helper_file)
else
    input_file="/public/samples/wtmp.2021"
fi

param_count="$#"
param_pos=1
while [ $param_pos -le $param_count ]; do
    if [ "${!param_pos}" = "-n" ] && [ $((param_pos + 1)) -le $param_count ]; then
        if [[ "${!((param_pos + 1))}" =~ ^-?[0-9]+$ ]]; then
            ((param_count--))
        fi
    fi
    ((param_pos++))
done

if [ $param_count -gt 2 ]; then
    echo "Error: Too many parameters provided." >&2
    exit 1
fi

while [ $# -gt 0 ]; do
    case $1 in
    -n)
        shift
        if [[ $1 =~ ^[0-9]+$ ]]; then
            default_reports=$1
        else
            echo "Error: Numeric value needed after -n." >&2
            exit 1
        fi
        ;;
    -h)
        echo "Copyright (C) Jakub Horvath"
        echo
        usage="Usage: $0 $*"
        if [ "$default_reports" ]; then
            usage="${usage/-n [0-9]*/-n}"
        fi
        echo "$usage"
        for ((i = 1; i <= $#; i++)); do
            case "${!i}" in
            -n)
                echo "-n: set the report count"
                ((i++))
                ;;
            -h)
                echo "-h: show help and exit"
                ;;
            esac
        done
        exit 0
        ;;
    *)
        echo "Error: Invalid option '$1'." >&2
        exit 1
        ;;
    esac
    shift
done

awk -v rpt="$default_reports" '{
    if ($3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
        counts[$1]++;
    }
}
END {
    for (usr in counts) {
        if (counts[usr] > rpt) {
            printf "User: '\''%s %d'\''\n", usr, counts[usr];
        }
    }
}' "$input_file" 2>&1
