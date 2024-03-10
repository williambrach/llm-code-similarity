
display_help() {
    echo "GuideForUsage.sh (C)"
    echo "Usage instructions: $0 [-h] [-g <group_name>]"
    echo "  -h: Show help details"
    echo "  -g <group_name>: Display members of a specific group"
    exit 0
}

interpret_arguments() {
    while getopts ":hg:" opt; do
        case $opt in
        h)
            display_help
            ;;
        g)
            desired_group="$OPTARG"
            ;;
        \?)
            echo "Unknown option: -$OPTARG" >&2
            display_help
            ;;
        :)
            echo "Missing argument for option: -$OPTARG" >&2
            display_help
            ;;
        esac
    done
    if [ "$((OPTIND - 1))" -lt "$#" ]; then
        echo "Excessive arguments provided." >&2
        display_help
    fi
}

check_user_group_membership() {
    local username="$1"
    local group="$2"
    local groups_of_user=""
    groups_of_user=$(grep "^$username:" /public/samples/passwd.2020 | cut -d: -f4)
    [[ $groups_of_user =~ (^|,)$group($|,) ]]
}

enumerate_users() {
    local users=$(last -f /public/samples/wtmp.2020 | awk '{print $1}' | sort | uniq)
    for user in $users; do
        if [[ $user && ! $user =~ (\*|NP) ]]; then
            if [[ $desired_group ]]; then
                if check_user_group_membership "$user" "$desired_group"; then
                    echo "'$user $desired_group'"
                fi
            else
                echo "'$user'"
            fi
        fi
    done
}

desired_group=""
interpret_arguments "$@"
enumerate_users
