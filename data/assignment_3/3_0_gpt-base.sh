
lineBreak=$'\n'
userDetailsFile="/public/samples/users.2020"
loginHistoryFile="/public/samples/logins.2020"
groupFilter=-1
applyGroupFilter=0
digitRegex='^[0-9]+$'
if [ ! -f "$userDetailsFile" ] || [ ! -f "$loginHistoryFile" ]; then
	echo "Error: '$0': Required file not found" >&2
	exit 1
fi
instructions="How to use $0:
$0 [-h] [-g groupFilter] ...
    -h: display this help message
    -g groupFilter: show users belonging to a specific group ID"
if [ $# -gt 2 ]; then
	echo "Error: Excessive arguments" >&2
	exit 1
fi
while [ $# -gt 0 ]; do
	case $1 in
		-h)
			echo "$instructions"
			exit 0
			;;
		-g)
			shift
			if [[ $1 =~ $digitRegex ]]; then
				applyGroupFilter=1
				groupFilter=$1
			else
				if [ -z "$1" ]; then
					echo "Error: Missing group ID" >&2
					exit 1
				else
					echo "Error: Group ID should be a number" >&2
					exit 1
				fi
			fi
			;;
		*)
			echo "Error: Unrecognized option '$1'" >&2
			exit 1
			;;
	esac
	shift
done
readarray -t latestLogins < <(last -w -f "$loginHistoryFile" | sort | awk '{print $1}' | uniq)
readarray -t userInfo < <(grep -vE "(nologin|false|true)" "$userDetailsFile")
for userInfoLine in "${userInfo[@]}"; do
	user=$(echo "$userInfoLine" | cut -d ":" -f 1)
	if ! grep -qFx "$user" <<<"${latestLogins[*]}"; then
		userGroup=$(echo "$userInfoLine" | cut -d ":" -f 4)
		if ((applyGroupFilter == 1 && groupFilter == userGroup)) || ((applyGroupFilter == 0)); then
			echo "$user $userGroup"
		fi
	fi
done
