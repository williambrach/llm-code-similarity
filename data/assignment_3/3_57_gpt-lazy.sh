passwd_path="/public/data/passwd.2021"
login_records="/public/data/wtmp.2021"
if [ ! -f "$passwd_path" ] || [ ! -f "$login_records" ]; then
    echo "Error: Necessary files are missing." >&2
    exit 1
fi
user_group=""
show_usage() {
    echo "task03.sh (C)"
    echo ""
    echo "Usage: task03.sh [-h] [-g <user_group>]"
    echo "  -h:           Show this help message."
    echo "  -g <user_group>:   Display only users from the specified group."
    exit 1
}
while getopts ":g:h" option; do
    case $option in
    h)
        show_usage
        ;;
    g)
        user_group="$OPTARG"
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        show_usage
        ;;
    :)
        echo "Option -$OPTARG needs a value." >&2
        show_usage
        ;;
    esac
done
if [ "$#" -gt 2 ]; then
    echo "Error: Excessive number of arguments." >&2
    show_usage
    exit 1
fi
passwd_info=$(awk -F: '{if ($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin") print $1, $4}' "$passwd_path")
if [ -n "$user_group" ]; then
    passwd_info=$(echo "$passwd_info" | awk -v group="$user_group" '$2 == group')
fi
recent_usernames=$(last -w -f "$login_records" | awk '{print $1}' | sort -u)
missing_users=$(comm -23 <(echo "$passwd_info" | awk '{print $1}' | sort) <(echo "$recent_usernames" | sort))
for user_info in $missing_users; do
    username=$(echo "$user_info" | cut -d' ' -f1)
    group_id=$(echo "$passwd_info" | awk -v user="$username" '$1 == user {print $2}')
    echo "Result: '$username $group_id'"
done
