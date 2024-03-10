
credentialsPath=/public/data/credentials.2020
loginRecordsPath=/public/data/login_records.2020

# Verify files existence
for filePath in "$credentialsPath" "$loginRecordsPath"; do
	if [ ! -f "$filePath" ]; then
		echo "Error: File '$filePath' not found" >&2
		exit 1
	fi
done

# Function to display script usage
showUsage() {
	cat <<-EOF
		Usage: $0 [-h] [-g <group_id>]
		  -h: Display this help message
		  -g <group_id>: Filter users by group ID
	EOF
	exit 0
}

# Initialize group filter
groupIDFilter=""

# Parse command-line options
while [ $# -gt 0 ]; do
	case "$1" in
		-g)
			shift
			if [[ "$1" =~ ^[0-9]+$ ]]; then
				groupIDFilter=$1
			else
				echo "Error: Invalid group ID '$1'" >&2
				exit 1
			fi
			;;
		-h)
			showUsage
			;;
		*)
			echo "Error: Unrecognized option '$1'" >&2
			exit 1
			;;
	esac
	shift
done

# Collect logged users
declare -A activeUsers
while IFS=" " read -r username _; do
	[[ -z "$username" || "$username" == "loginRecordsPath" ]] && continue
	activeUsers["$username"]=1
done < <(last -w -f "$loginRecordsPath" | awk '{print $1}' | sort -u)

# Filter and display users based on criteria
grep -Ev "nologin$|false$" "$credentialsPath" | while IFS=":" read -r username _ _ userGroup _; do
	[[ -z "$username" ]] && continue
	if [[ ! ${activeUsers["$username"]} && ("$groupIDFilter" == "" || "$userGroup" == "$groupIDFilter") ]]; then
		echo "User: '$username $userGroup'"
	fi
done
