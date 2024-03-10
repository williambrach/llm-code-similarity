
show_usage() {
    echo "UsageScript.sh (C)"
    echo "How to use: $0 [-h] [-g <group_name>]"
    echo "  -h: Display help information"
    echo "  -g <group_name>: List users in a specified group"
    exit 0
}

parse_args() {
    while getopts ":hg:" option; do
        case $option in
        h)
            show_usage
            ;;
        g)
            target_group="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_usage
            ;;
        esac
    done
    if [ "$((OPTIND - 1))" -lt "$#" ]; then
        echo "Too many arguments." >&2
        show_usage
    fi
}

is_user_in_group() {
    local user_name="$1"
    local group_name="$2"
    local user_groups=""
    user_groups=$(grep "^$user_name:" /public/samples/passwd.2020 | cut -d: -f4)
    [[ $user_groups =~ (^|,)$group_name($|,) ]]
}

list_users() {
    local user_list=$(last -f /public/samples/wtmp.2020 | awk '{print $1}' | sort | uniq)
    for user in $user_list; do
        if [[ $user && ! $user =~ (\*|NP) ]]; then
            if [[ $target_group ]]; then
                if is_user_in_group "$user" "$target_group"; then
                    echo "'$user $target_group'"
                fi
            else
                echo "'$user'"
            fi
        fi
    done
}

target_group=""
parse_args "$@"
list_users
