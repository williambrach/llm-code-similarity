
#!/bin/bash

scriptName=$(basename "$0")
scriptAuthor=""
maxUsers=10

displayHelp() {
    echo "Program: $scriptName by $scriptAuthor"
    echo ""
    echo "Syntax: $scriptName [-h] [-u <users>]"
    echo "  -h: Display this help message"
    echo "  -u <users>: Set a maximum number of active users"
}

processLoginData() {
    last -f /public/samples/wtmp.2020 | awk '{print $1, $3}' | grep -Ev '^(|unknown|reboot|wtmp)$' |
        sort | uniq |
        awk -v max="$maxUsers" '
    {
        if ($2 != "in" && $2 != "console" && $2 != "system" && $2 != "boot") {
            userCount[$1]++;
            userSessions[$1,$2]++;
        }
    }
    END {
        for (user in userCount) {
            sessionCount = 0;
            for (session in userSessions) {
                split(session, sessionDetails, SUBSEP);
                if (sessionDetails[1] == user) {
                    sessionCount++;
                }
            }
            if (sessionCount >= max) {
                print user, sessionCount;
            }
        }
    }'
}

if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        displayHelp
        shift
        ;;
    -u)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            maxUsers=$2
            processLoginData
            shift 2
        else
            echo "Error: '$2' is not a valid number"
            exit 1
        fi
        ;;
    *)
        echo "Error: Unknown option '$1'"
        echo "Try '$scriptName -h' for more information."
        shift
        ;;
    esac
done
