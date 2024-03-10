
user_data_file="/public/data/passwd.2021"
login_activity_file="/public/data/wtmp.2021"

# Check if the necessary files exist
if [ ! -e "$user_data_file" ] || [ ! -e "$login_activity_file" ]; then
    echo "Error: Required files are not found." >&2
    exit 1
fi

group_filter=""

# Function to display help
display_help() {
    echo "Usage script (C)"
    echo ""
    echo "Syntax: script [-h] [-g <group_filter>]"
    echo "Options:"
    echo "  -h                Display this help message."
    echo "  -g <group_filter> Show users belonging to a specific group."
    exit 1
}

# Parse command-line options
while getopts ":g:h" opt; do
    case ${opt} in
        h)
            display_help
            ;;
        g)
            group_filter="${OPTARG}"
            ;;
        ?)
            echo "Error: Unknown option -${OPTARG}." >&2
            display_help
            ;;
        :)
            echo "Error: Option -${OPTARG} requires an argument." >&2
            display_help
            ;;
    esac
done

# Check for excessive arguments
if [ "$#" -gt 2 ]; then
    echo "Error: Too many arguments provided." >&2
    display_help
fi

# Extract user and group information, excluding users with nologin shells
user_group_data=$(awk -F: '($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin") {print $1, $4}' "$user_data_file")

# Filter by group if specified
if [ ! -z "$group_filter" ]; then
    user_group_data=$(echo "$user_group_data" | awk -v grp="$group_filter" '$2 == grp')
fi

# Get unique login names from login records
unique_logins=$(last -w -f "$login_activity_file" | awk '{print $1}' | sort | uniq)

# Find users in passwd but not in login records
absent_users=$(comm -23 <(echo "$user_group_data" | awk '{print $1}' | sort) <(echo "$unique_logins" | sort))

# Display missing users and their group IDs
for user in $absent_users; do
    user_name=$(echo "$user" | cut -d' ' -f1)
    group_id=$(echo "$user_group_data" | awk -v usr="$user_name" '$1 == usr {print $2}')
    echo "Result: '$user_name $group_id'"
done
