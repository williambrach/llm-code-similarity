
#!/bin/bash

# Define variables
nameOfScript=$(basename "$0")
authorName=""
userLimit=10

# Function to display help
showHelp() {
    echo "Usage: $nameOfScript by $authorName"
    echo ""
    echo "Options: $nameOfScript [-h] [-u <users>]"
    echo "  -h: Show help information"
    echo "  -u <users>: Define the maximum number of users allowed"
}

# Function to analyze login data
analyzeLoginActivity() {
    last -f /public/samples/wtmp.2020 | awk '{print $1, $3}' | grep -Ev '^(|unknown|reboot|wtmp)$' |
        sort | uniq |
        awk -v limit="$userLimit" '
    {
        if ($2 != "in" && $2 != "console" && $2 != "system" && $2 != "boot") {
            countOfUsers[$1]++;
            sessionsOfUsers[$1,$2]++;
        }
    }
    END {
        for (user in countOfUsers) {
            numberOfSessions = 0;
            for (session in sessionsOfUsers) {
                split(session, detailsOfSession, SUBSEP);
                if (detailsOfSession[1] == user) {
                    numberOfSessions++;
                }
            }
            if (numberOfSessions >= limit) {
                print user, numberOfSessions;
            }
        }
    }'
}

# Check for no arguments
if [ $# -eq 0 ]; then
    echo "Error: Missing arguments"
    exit 1
fi

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
    -h)
        showHelp
        shift
        ;;
    -u)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            userLimit=$2
            analyzeLoginActivity
            shift 2
        else
            echo "Error: Invalid number '$2'"
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid option '$1'"
        echo "Use '$nameOfScript -h' for help."
        shift
        ;;
    esac
done
