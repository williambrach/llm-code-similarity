
auth_file=/public/data/credentials.2020
access_log=/public/data/login_records.2020
for file in "$auth_file" "$access_log"; do
	if [ ! -f "$file" ]; then
		echo "Error: File '$file' not found" >&2
		exit 1
	fi
done
display_help() {
	cat <<-EOF
		Usage: $0 [-h] [-g <group_id>]
		  -h: Display this help message
		  -g <group_id>: Filter users by group ID
	EOF
	exit 0
}
group_filter=""
while [ $# -gt 0 ]; do
	case "$1" in
		-g)
			shift
			if [[ "$1" =~ ^[0-9]+$ ]]; then
				group_filter=$1
			else
				echo "Error: Invalid group ID '$1'" >&2
				exit 1
			fi
			;;
		-h)
			display_help
			;;
		*)
			echo "Error: Unrecognized option '$1'" >&2
			exit 1
			;;
	esac
	shift
done
declare -A logged_users
while IFS=" " read -r user _; do
	[[ -z "$user" || "$user" == "access_log" ]] && continue
	logged_users["$user"]=1
done < <(last -w -f "$access_log" | awk '{print $1}' | sort -u)
grep -Ev "nologin$|false$" "$auth_file" | while IFS=":" read -r user _ _ group _; do
	[[ -z "$user" ]] && continue
	if [[ ! ${logged_users["$user"]} && ("$group_filter" == "" || "$group" == "$group_filter") ]]; then
		echo "User: '$user $group'"
	fi
done
