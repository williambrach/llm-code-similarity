credentials_file=/public/data/credentials.2020
login_records=/public/data/login_records.2020
for item in "$credentials_file" "$login_records"; do
	if [ ! -e "$item" ]; then
		echo "Error: '$item': file not found" >&2
		exit 1
	fi
done
show_usage() {
	cat <<-EOF
		$0 (C)
		How to use: $0 [-h] [-g <group_id>]
		  -h: shows help
		  -g <group_id>: shows users in specified <group_id>
	EOF
	exit 0
}
specified_group=""
while (("$#")); do
	case "$1" in
	-g)
		shift
		if [[ "$1" =~ ^[0-9]+$ ]]; then
			specified_group=$1
		else
			echo "Error: '$1': invalid group ID" >&2
			exit 1
		fi
		;;
	-h)
		show_usage
		;;
	*)
		echo "Error: '$1': unrecognized option" >&2
		exit 1
		;;
	esac
	shift
done
declare -A active_users
while IFS=" " read -r username _; do
	[[ -z "$username" || "$username" == "login_records" ]] && continue
	active_users["$username"]=1
done < <(last -w -f "$login_records" | awk '{print $1}' | sort -u)
grep -Ev "nologin$|false$" "$credentials_file" | while IFS=":" read -r username _ _ user_group _; do
	[[ -z "$username" ]] && continue
	if [[ ! ${active_users["$username"]} && ("$specified_group" == "" || "$user_group" == "$specified_group") ]]; then
		echo "User: '$username $user_group'"
	fi
done
