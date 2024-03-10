
display_usage() {
	echo "Utility to Find Longest Line in Files"
	echo
	echo "Syntax: $0 [-h] [file ...]"
	echo "      -h: shows this help text"
	echo "      file ...: one or more files to check, reads from stdin if none specified"
	echo
	exit 0
}
max_length=0
max_line_info=()
while getopts ":h" opt; do
	case $opt in
	h)
		display_usage
		;;
	*)
		echo "Error: Unknown option '-$OPTARG'." >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
	inputs="/dev/stdin"
else
	inputs=("$@")
fi
for input in "${inputs[@]}"; do
	if [ ! -f "$input" ] && [ "$input" != "/dev/stdin" ]; then
		echo "Error: '$input' does not exist as a file." >&2
		continue
	fi
	if [ ! -r "$input" ]; then
		echo "Error: '$input' cannot be read." >&2
		continue
	fi
	if [ "$input" != "/dev/stdin" ]; then
		file_info=$(file -0 "$input" | cut -d $'\0' -f2)
	else
		file_info="text"
	fi
	if [[ "$file_info" == *"empty"* ]]; then
		echo "Error: '$input' is empty." >&2
		continue
	fi
	if [[ "$file_info" != *"text"* ]]; then
		echo "Error: '$input' is not a text file." >&2
		continue
	fi
	num_lines=0
	while IFS= read -r line; do
		((num_lines++))
		length_of_line=${#line}
		if [ "$length_of_line" -gt "$max_length" ]; then
			max_length=$length_of_line
			max_line_info=("$input" "$num_lines" "$line")
		elif [ "$length_of_line" -eq "$max_length" ]; then
			max_line_info+=("$input" "$num_lines" "$line")
		fi
	done <"$input"
done
if [ "${#max_line_info[@]}" -eq 0 ]; then
	echo "Error: No valid input detected." >&2
	exit 1
else
	for ((idx = 0; idx < ${#max_line_info[@]}; idx += 3)); do
		if [ "${max_line_info[idx]}" == "/dev/stdin" ]; then max_line_info[idx]="stdin input"; fi
		echo "Longest: '${max_line_info[idx]}: Line ${max_line_info[idx + 1]} Length ${#max_line_info[idx + 2]}: ${max_line_info[idx + 2]}'"
	done
fi
