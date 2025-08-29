#!/bin/bash
datetime=$(date +%Y%m%d-%H%M%S)
FILES=src/models/*.scad
NUM_FILES=$(ls $FILES 2> /dev/null | wc -l)

if [ ! -d "out" ]; then
  mkdir out
fi

echo "Generating ${NUM_FILES} 3MF files with timestamp $datetime"

SUCCESS_COUNT=0
FAIL_COUNT=0
FAILURE_MESSAGES=()

for f in $FILES
do
    name=$(basename "$f" .scad)
    fullname="$name-$datetime.3mf"
    echo "Generating out/$fullname from $f"
    result=$(openscad -q -o "out/$fullname" "$f" 2>&1)
    if [ $? -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        # Indent error message for better readability
        formatted_result=$(echo "$result" | sed 's/^/    /')
        FAILURE_MESSAGES+=("Failed to generate $fullname from $f:"$'\n'"$formatted_result"$'\n')
    fi
done

echo "-------------------------------"
echo ""

if [ $FAIL_COUNT -ne 0 ]; then
    echo "Failed to generate ${FAIL_COUNT} of ${NUM_FILES} files."
    echo ""
    for failed in "${FAILURE_MESSAGES[@]}"; do
        echo "$failed"
    done
else
    echo "Successfully generated ${SUCCESS_COUNT} files."
    exit 0
fi
