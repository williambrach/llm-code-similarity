
field_separator=$'\n'
user_info_path="/public/samples/users.2020"
access_log_path="/public/samples/logins.2020"
group_filter=-1
apply_group_filter=0
digit_pattern='^[0-9]+$'
if [ ! -e "$user_info_path" ] || [ ! -e "$access_log_path" ]; then
	echo "Error: '$0': Missing file" >&2
	exit 1
fi
help_text="Usage of $0:
$0 [-h] [-g group_filter] ...
    -h: show help
    -g group_filter: filter users by their group ID"
if [ $# -gt 2 ]; then
	echo "Error: Too many parameters" >&2
	exit 1
fi
while [ $# -gt 0 ]; do
	case $1 in
		-h)
			echo "$help_text"
			exit 0
			;;
		-g)
			shift
			if [[ $1 =~ $digit_pattern ]]; then
				apply_group_filter=1
				group_filter=$1
			else
				if [ -z "$1" ]; then
					echo "Error: Group ID not specified" >&2
					exit 1
				else
					echo "Error: Group ID must be numeric" >&2
					exit 1
				fi
			fi
			;;
		*)
			echo "Error: Invalid option '$1'" >&2
			exit 1
			;;
	esac
	shift
done
readarray -t active_users < <(last -w -f "$access_log_path" | sort | awk '{print $1}' | uniq)
readarray -t user_records < <(grep -vE "(nologin|false|true)" "$user_info_path")
for record in "${user_records[@]}"; do
	user_name=$(echo "$record" | cut -d ":" -f 1)
	if ! grep -qFx "$user_name" <<<"${active_users[*]}"; then
		group_id=$(echo "$record" | cut -d ":" -f 4)
		if ((apply_group_filter == 1 && group_filter == group_id)) || ((apply_group_filter == 0)); then
			echo "$user_name $group_id"
		fi
	fi
done
