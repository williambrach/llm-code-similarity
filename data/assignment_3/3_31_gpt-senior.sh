
display_help() {
    echo "UsageScript.sh (C)"
    echo "How to use: $0 [-h] [-g <group_name>]"
    echo "  -h: Display help information"
    echo "  -g <group_name>: Show users belonging to a specified group"
    exit 0
}

process_options() {
    while getopts ":hg:" opt; do
        case $opt in
        h)
            display_help
            ;;
        g)
            specified_group="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
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
    local user="$1"
    local group="$2"
    local groups_of_user=""
    groups_of_user=$(grep "^$user:" /public/samples/passwd.2020 | cut -d: -f4)
    [[ $groups_of_user =~ (^|,)$group($|,) ]]
}

process_users() {
    local users=$(last -f /public/samples/wtmp.2020 | awk '{print $1}' | sort | uniq | sort)
    for user in $users; do
        if [[ $user && ! $user =~ (\*|NP) ]]; then
            if [[ $specified_group ]]; then
                if check_user_group_membership "$user" "$specified_group"; then
                    echo "'$user $specified_group'"
                fi
            else
                echo "'$user'"
            fi
        fi
    done
}

specified_group=""
process_options "$@"
process_users
