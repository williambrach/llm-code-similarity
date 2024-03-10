
newline_separator=$'\n'
userInfoPath="/public/samples/users.2020"
loginLogPath="/public/samples/logins.2020"
selectedGroup=-1
filterByGroup=0
numericPattern='^[0-9]+$'
if [ ! -e "$userInfoPath" ] || [ ! -e "$loginLogPath" ]; then
	echo "Error: '$0': Missing file" >&2
	exit 1
fi
usage="Usage of $0:
$0 [-h] [-g selectedGroup] ...
    -h: show help
    -g selectedGroup: filter users by their group ID"
if [ $# -gt 2 ]; then
	echo "Error: Too many parameters" >&2
	exit 1
fi
while [ $# -gt 0 ]; do
	case $1 in
		-h)
			echo "$usage"
			exit 0
			;;
		-g)
			shift
			if [[ $1 =~ $numericPattern ]]; then
				filterByGroup=1
				selectedGroup=$1
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
readarray -t recentLogins < <(last -w -f "$loginLogPath" | sort | awk '{print $1}' | uniq)
readarray -t userDetails < <(grep -vE "(nologin|false|true)" "$userInfoPath")
for userRecord in "${userDetails[@]}"; do
	username=$(echo "$userRecord" | cut -d ":" -f 1)
	if ! grep -qFx "$username" <<<"${recentLogins[*]}"; then
		groupID=$(echo "$userRecord" | cut -d ":" -f 4)
		if ((filterByGroup == 1 && selectedGroup == groupID)) || ((filterByGroup == 0)); then
			echo "$username $groupID"
		fi
	fi
done
