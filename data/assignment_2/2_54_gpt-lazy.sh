if [ "$#" -eq 0 ]; then
	numLines=()
	content=()
	longest=0
	lineCount=0
	while IFS= read -r lineData; do
		((lineCount++))
		lineSize=$(($(wc -c <<<"$lineData") - 1))
		if [ "$lineSize" -eq 0 ]; then
			break
		fi
		if [ "$lineSize" -gt "$longest" ]; then
			longest="$lineSize"
			numLines=("$lineCount")
			content=("$lineData")
		elif [ "$lineSize" -eq "$longest" ]; then
			numLines+=("$lineCount")
			content+=("$lineData")
		fi
	done

	elementCount=${#content[@]}
	for i in $(seq 0 $((elementCount - 1))); do
		echo >&1 "Result: '-: ${numLines["$i"]} $(($(wc -c <<<"${content["$i"]}") - 1)) ${content["$i"]}'"
	done
	exit 0
fi
if [ "$1" == "-h" ]; then
	echo >&1 "Homework 2 (C)"
	echo >&1 -e "\nUsage:  ${0} [-h] [file_path ...]"
	echo >&1 -e "\t-h: Show this help message."
	echo >&1 -e "\tfile_path: Path(s) to file(s) or directory(ies) to find the longest line(s)."
	exit 0
elif [[ "$1" == -* ]]; then
	echo >&2 "Error: unrecognized option -- '${1#-}'"
	echo >&2 "Try '${0} -h' for more information."
	exit 1
fi
while (("$#")); do
	filePaths=()
	numLines=()
	content=()
	longest=0
	lineCount=0
	if [ -f "$1" ]; then
		while IFS= read -r lineData; do
			((lineCount++))
			lineSize=$(($(wc -c <<<"$lineData") - 1))
			if [ "$lineSize" -gt "$longest" ]; then
				longest="$lineSize"
				filePaths=("$1")
				numLines=("$lineCount")
				content=("$lineData")
			elif [ "$lineSize" -eq "$longest" ]; then
				if [ "$lineSize" -ne 0 ]; then
					filePaths+=("$1")
					numLines+=("$lineCount")
					content+=("$lineData")
				fi
			fi
		done <"$1"
	elif [ -d "$1" ]; then
		mapfile -t fileList < <(find "$1" -type f)
		for file in "${fileList[@]}"; do
			lineCount=0
			while IFS= read -r lineData; do
				((lineCount++))
				lineSize=$(($(wc -c <<<"$lineData") - 1))
				if [ "$lineSize" -gt "$longest" ]; then
					longest="$lineSize"
					filePaths=("$file")
					numLines=("$lineCount")
					content=("$lineData")
				elif [ "$lineSize" -eq "$longest" ]; then
					if [ "$lineSize" -ne 0 ]; then
						filePaths+=("$file")
						numLines+=("$lineCount")
						content+=("$lineData")
					fi
				fi
			done <"$file"
		done
	else
		echo >&2 "Error: '$1': No such file."
		exit 1
	fi
	elementCount=${#content[@]}
	for i in $(seq 0 $((elementCount - 1))); do
		echo >&1 "Result: '${filePaths["$i"]}: ${numLines["$i"]} $(($(wc -c <<<"${content["$i"]}") - 1)) ${content["$i"]}'"
	done
	shift
done
exit 0
