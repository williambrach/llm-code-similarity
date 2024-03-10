
showHelp() {
	echo "Task 7 - Name Occurrence Finder (C)"
	echo ""
	echo "Syntax: $0 <-h> <-d (depth)> <path>"
	echo "<-h>: displays this help message"
	echo "<-d>: sets the search depth, followed by a natural number N"
	echo "<path>: the directory path to start the search"
}
textFiles=()
collectTextFiles() {
	local target="$1"
	if grep -qE "^find: .*" <<<"$target"; then
		echo "Find command error" 1>&2
		exit 1
	else
		if file "$target" | grep -qi "text"; then
			if [[ -r "$target" ]]; then
				textFiles+=("$target")
			fi
		fi
	fi
}
searchDepth=""
searchPath=""
while (("$#")); do
	case "$1" in
	-h)
		showHelp
		exit 0
		;;
	-d)
		shift
		numericPattern="^[0-9]+$"
		if [[ "$1" =~ $numericPattern ]]; then
			searchDepth=$1
		else
			invalidDepth=$1
			printf "Error: \'Invalid depth value -> %s\'\n" "$invalidDepth" 1>&2
			exit 1
		fi
		;;
	-*)
		printf "Error: \'Invalid option -> %s\'\n" "$1" 1>&2
		exit 1
		;;
	*)
		if test -d "$1"; then
			searchPath="$1"
		else
			invalidPath="$1"
			printf "Error: \'Invalid path / Directory does not exist -> %s\'\n" "$invalidPath" 1>&2
			exit 1
		fi
		;;
	esac
	shift
done
if [[ -z "$searchPath" ]]; then
	searchPath="."
fi
if [ -z "$searchDepth" ]; then
	foundFiles=$(find "$searchPath" -type f 2>&1)
	while read -r file; do
		collectTextFiles "$file"
	done <<<"$foundFiles"
else
	foundFiles=$(find "$searchPath" -maxdepth "$searchDepth" -type f 2>&1)
	while read -r file; do
		collectTextFiles "$file"
	done <<<"$foundFiles"
fi
for file in "${textFiles[@]}"; do
	fileName=$(basename "$file")
	occurrences=$(grep -wc "$fileName" "$file")
	if [[ $occurrences -gt 0 ]]; then
		printf "Output: \'%s %s\'\n" "$file" "$occurrences"
	fi
done
exit 0
