
userDataPath="/public/data/passwd.2021"
loginDataPath="/public/data/wtmp.2021"

# Verify required files' existence
if [ ! -e "$userDataPath" ] || [ ! -e "$loginDataPath" ]; then
    echo "Error: Required files are not found." >&2
    exit 1
fi

groupCriteria=""

# Help function
showHelp() {
    echo "Usage script (C)"
    echo ""
    echo "Syntax: script [-h] [-g <groupCriteria>]"
    echo "Options:"
    echo "  -h                Display this help message."
    echo "  -g <groupCriteria> Filter users by group."
    exit 1
}

# Option parsing
while getopts ":g:h" option; do
    case ${option} in
        h)
            showHelp
            ;;
        g)
            groupCriteria="${OPTARG}"
            ;;
        ?)
            echo "Error: Unknown option -${OPTARG}." >&2
            showHelp
            ;;
        :)
            echo "Error: Option -${OPTARG} requires an argument." >&2
            showHelp
            ;;
    esac
done

# Excess argument check
if [ "$#" -gt 2 ]; then
    echo "Error: Too many arguments provided." >&2
    showHelp
fi

# Extracting user and group info, excluding nologin shells
filteredUserData=$(awk -F: '($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin") {print $1, $4}' "$userDataPath")

# Apply group filter if set
if [ ! -z "$groupCriteria" ]; then
    filteredUserData=$(echo "$filteredUserData" | awk -v grp="$groupCriteria" '$2 == grp')
fi

# Unique login extraction
uniqueLoginNames=$(last -w -f "$loginDataPath" | awk '{print $1}' | sort | uniq)

# Identifying users not in login records
missingUsers=$(comm -23 <(echo "$filteredUserData" | awk '{print $1}' | sort) <(echo "$uniqueLoginNames" | sort))

# Displaying absent users with their group IDs
for user in $missingUsers; do
    userName=$(echo "$user" | cut -d' ' -f1)
    groupId=$(echo "$filteredUserData" | awk -v usr="$userName" '$1 == usr {print $2}')
    echo "Result: '$userName $groupId'"
done
