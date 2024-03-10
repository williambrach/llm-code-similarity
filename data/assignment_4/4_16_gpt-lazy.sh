unset searchDepth
unset directories
unset found
while (($#)); do
	case "$1" in
	-d) # Set the search depth
		if [ "$#" -lt 2 ]; then
			echo "Error: '"$1"': insufficient arguments for -d"
			exit 1
		fi
		if [ "$2" -lt 1 ]; then
			echo "Error: '"$1"': depth must be 1 or more"
			exit 1
		fi
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
			echo "Error: '"$1"': depth must be a numeric value"
			exit 1
		fi
		searchDepth="$2"
		shift
		;;
	-h) # Help command information
		echo -e "TASK 4\nUsage: \tscript.sh -d (num), -h, dir1 dir2 ... \n\t-d (num): Specify a positive integer for maximum search depth\n\t-h: Display this help message\n\t<dir1 dir2 ...>: Specify directories to search. Defaults to current directory if none are provided."
		exit 0
		;;
	-*) # Handle unknown flags
		echo >&2 "Error: '"$1"': Unrecognized option"
		exit 1
		;;
	*) # Directory validation
		if [ -d "$1" ]; then
			found=0
			for dir in "${directories[@]}"; do
				if [ "$(realpath "$dir")" == "$(realpath "$1")" ]; then
					found=1
					break
				fi
			done
			[ $found -eq 0 ] && directories+=("$1")
		else
			echo >&2 "Error: '"$1"': No such directory."
			exit 1
		fi
		;;
	esac
	shift
done
if [ -z "$directories" ]; then # Default to current directory if none specified
	directories=("$(pwd)")
fi
for dir in "${directories[@]}"; do # Iterate through specified directories
	echo "Listing symlinks in: $dir"
	unset linkArray
	unset targetArray
	IFS=$'\n'
	if [ -z $searchDepth ]; then
		linkArray=(${linkArray[@]} $(find "$dir" -type l))
		targetArray=(${targetArray[@]} $(find "$dir" -type l -exec readlink {} +))
	else
		linkArray=(${linkArray[@]} $(find "$dir" -maxdepth "$searchDepth" -type l))
		targetArray=(${targetArray[@]} $(find "$dir" -maxdepth "$searchDepth" -type l -exec readlink {} +))
	fi
	unset IFS
	unset maxLength
	maxLength=0
	maxLength=$(printf "%s\n" "${targetArray[@]}" | awk -F/ '{print NF-1}' | sort -n | tail -n 1)
	for ((i = 0; i < ${#linkArray[@]}; i++)); do
		if [ "$(echo "${targetArray[$i]}" | awk -F/ '{print NF-1}')" -eq "$maxLength" ]; then
			echo "${linkArray[$i]} -> ${targetArray[$i]}"
		fi
	done
done
