show_instructions() {
    echo "Task3Script.sh (C)"
    echo "Usage: $0 [-h] [-g <group>]"
    echo "  -h: Show this help message"
    echo "  -g <group>: Display users from a specific group"
    exit 1
}
while getopts ":hg:" option; do
    case $option in
    h)
        show_instructions
        ;;
    g)
        group_name="$OPTARG"
        ;;
    \?)
        echo "Error: Unknown option: -$OPTARG" >&2
        show_instructions
        ;;
    :)
        echo "Error: Option -$OPTARG requires an argument." >&2
        show_instructions
        ;;
    esac
done
if [ "$((OPTIND - 1))" -lt "$#" ]; then
    echo "Error: Too many arguments." >&2
    show_instructions
fi
is_user_in_group() {
    user_name="$1"
    desired_group="$2"
    user_groups_list=""
    user_groups_list=$(grep "^$user_name:" /public/samples/passwd.2020 | awk -F ":" '{print $4}')
    [[ "$user_groups_list" =~ (^|,)$desired_group($|,) ]]
}
user_list=$(last -f /public/samples/wtmp.2020 | awk '{print $1}' | sort -nr | uniq -c | sort -nr | awk '{ print $2 }')
for user_name in $user_list; do
    if [ -n "$user_name" ]; then
        if [[ ! "$user_name" =~ (\*|NP) ]]; then
            if [ -n "$group_name" ]; then
                if is_user_in_group "$user_name" "$group_name"; then
                    echo "'$user_name $group_name'"
                fi
            else
                echo "'$user_name'"
            fi
        fi
    fi
done
