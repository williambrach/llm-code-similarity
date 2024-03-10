
credFile=/public/data/credentials.2020
loginsFile=/public/data/login_records.2020

# Check if necessary files are present
for file in "$credFile" "$loginsFile"; do
	if [ ! -e "$file" ]; then
		echo "Error: Missing file '$file'" >&2
		exit 1
	fi
done

# Help function to explain script usage
displayHelp() {
	cat <<-END
		Usage: $0 options
		  options:
		  -h  Show help
		  -g <group_id>  Show users from specific group ID
	END
	exit 0
}

# Setting up the group ID filter
filterGroupID=""

# Processing command-line arguments
while getopts ":hg:" opt; do
	case ${opt} in
		g )
			if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
				filterGroupID=$OPTARG
			else
				echo "Error: Group ID '$OPTARG' is not valid" >&2
				exit 1
			fi
			;;
		h )
			displayHelp
			;;
		\? )
			echo "Error: Invalid option '-$OPTARG'" >&2
			exit 1
			;;
	esac
done

# Gathering active user information
declare -A loggedInUsers
while IFS=" " read -r user _; do
	[[ -z "$user" || "$user" == "loginsFile" ]] && continue
	loggedInUsers["$user"]=1
done < <(last -w -f "$loginsFile" | awk '{print $1}' | sort -u)

# Output users based on the specified criteria
awk -F":" -v groupID="$filterGroupID" '{
	if ($1 != "" && ($4 == groupID || groupID == "")) print "User: \047" $1, $4 "\047"
}' "$credFile" | while read -r userInfo; do
	user=$(echo "$userInfo" | cut -d' ' -f2)
	if [[ ${loggedInUsers["$user"]} ]]; then
		echo "$userInfo"
	fi
done
