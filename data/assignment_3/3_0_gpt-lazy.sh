IFS=$'\n'
user_data_file=/public/samples/users.2020
login_records=/public/samples/logins.2020
specified_group=-1
filter_by_group=0
numeric_regex='^[0-9]+$'
if [ ! -f $user_data_file ] || [ ! -f $login_records ]; then
	echo "Error: '$0': File does not exist" 1>&2
	exit 1
fi
usage_info="$0 (C)
Usage: $0 [-h] [-g specified_group] ...
    -h: display this help
    -g specified_group: display only users of a specific group(group is a number)"
if (($# > 2)); then
	echo "Error: '$0': Too many arguments" 1>&2
	exit 1
fi
while (("$#")); do
	case "$1" in
	-h)
		echo "$usage_info"
		exit 0
		;;
	-g)
		shift
		if [[ "$1" =~ $numeric_regex ]]; then
			filter_by_group=1
			specified_group=$1
		else
			if [ "$1" == "" ]; then
				echo "Error: '$0': No group specified" 1>&2
				exit 1
			else
				echo "Error: '$0': Group must be a number" 1>&2
				exit 1
			fi
		fi
		;;
	-*)
		echo "Error: '$0': Unknown option \"$1\"" 1>&2
		exit 1
		;;
	*)
		echo "Error: '$0': Incorrect syntax" 1>&2
		exit 1
		;;
	esac
	shift
done
mapfile -t logged_in_users < <(last -w -f $login_records | sort | awk '{print $1}' | uniq)
mapfile -t all_user_entries < <(grep -vE "(nologin|false|true)" $user_data_file)
for user_entry in "${all_user_entries[@]}"; do
	username=$(cut -d ":" -f 1 <<<"$user_entry")
	if (echo "${logged_in_users[*]}") | grep -qFx "$username"; then
		continue
	else
		user_group_id="$(cut -d ":" -f 4 <<<"$user_entry")"
		if ((filter_by_group == 1)); then
			if ((specified_group == user_group_id)); then
				echo "$username $user_group_id"
			fi
		else
			echo "$username $user_group_id"
		fi
	fi
done
