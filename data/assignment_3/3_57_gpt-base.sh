
# Paths to essential data files
userFilePath="/public/data/passwd.2021"
logFilePath="/public/data/wtmp.2021"

# Check for the existence of necessary files
if [ ! -f "$userFilePath" ] || [ ! -f "$logFilePath" ]; then
    echo "Error: Missing essential files." >&2
    exit 1
fi

filterGroup=""

# Function to display usage information
displayUsage() {
    echo "Script Usage (C)"
    echo ""
    echo "Syntax: script [-h] [-g <filterGroup>]"
    echo "Options:"
    echo "  -h                Show help information."
    echo "  -g <filterGroup>  Specify a group to filter by."
    exit 1
}

# Parsing command-line options
while getopts ":g:h" opt; do
    case $opt in
        h)
            displayUsage
            ;;
        g)
            filterGroup="${OPTARG}"
            ;;
        ?)
            echo "Error: Invalid option -${OPTARG}." >&2
            displayUsage
            ;;
        :)
            echo "Error: Option -${OPTARG} needs a value." >&2
            displayUsage
            ;;
    esac
done

# Check for too many arguments
if [ "$#" -gt 2 ]; then
    echo "Error: Too many inputs." >&2
    displayUsage
fi

# Filtering user and group information, ignoring users with nologin shells
userGroupData=$(awk -F: '($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin") {print $1, $4}' "$userFilePath")

# If a group filter is specified, apply it
if [ -n "$filterGroup" ]; then
    userGroupData=$(echo "$userGroupData" | awk -v group="$filterGroup" '$2 == group')
fi

# Extracting unique login names
distinctLogins=$(last -w -f "$logFilePath" | awk '{print $1}' | sort | uniq)

# Finding users without login records
absentUsers=$(comm -23 <(echo "$userGroupData" | awk '{print $1}' | sort) <(echo "$distinctLogins" | sort))

# Displaying users and their group IDs not found in login records
for user in $absentUsers; do
    userLogin=$(echo "$user" | cut -d' ' -f1)
    userGroup=$(echo "$userGroupData" | awk -v user="$userLogin" '$1 == user {print $2}')
    echo "Result: '$userLogin $userGroup'"
done
