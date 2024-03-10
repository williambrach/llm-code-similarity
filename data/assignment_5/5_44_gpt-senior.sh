
#!/bin/bash

prog_name=$(basename "$0")
author=""
max_connections=10

show_usage() {
    echo "Program: $prog_name by $author"
    echo ""
    echo "Syntax: $prog_name [-h] [-c <count>]"
    echo "  -h: Display this help text"
    echo "  -c <count>: Specify a maximum number of user connections"
}

analyze_logins() {
    last -f /public/samples/wtmp.2020 | awk '{print $1, $3}' | grep -Ev '^(|unknown|reboot|wtmp)$' |
        sort | uniq |
        awk -v max="$max_connections" '
    {
        if ($2 != "in" && $2 != "console" && $2 != "system" && $2 != "boot") {
            users[$1]++;
            connections[$1,$2]++;
        }
    }
    END {
        for (user in users) {
            count = 0;
            for (conn in connections) {
                split(conn, parts, SUBSEP);
                if (parts[1] == user) {
                    count++;
                }
            }
            if (count >= max) {
                print user, count;
            }
        }
    }'
}

if [ $# -eq 0 ]; then
    echo "Error: Missing arguments"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        show_usage
        shift
        ;;
    -c)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            max_connections=$2
            analyze_logins
            shift 2
        else
            echo "Error: Invalid number '$2'"
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid option '$1'"
        echo "Try '$prog_name -h' for more information."
        shift
        ;;
    esac
done
