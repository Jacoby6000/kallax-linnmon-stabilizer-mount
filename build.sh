#!/bin/bash
datetime=$(date +%Y%m%d-%H%M%S)
FILES=src/models/*.scad
NUM_FILES=$(ls $FILES 2> /dev/null | wc -l)

DEPENDENCIES=$(cat dependencies.txt)

if [ ! -d "out" ]; then
  mkdir out
fi

echo "Generating ${NUM_FILES} 3MF files with timestamp $datetime"

SUCCESS_COUNT=0
MESSAGES=()
FAIL_COUNT=0
FAILURE_MESSAGES=()


for dep in $DEPENDENCIES
do
    dep_name=$(basename "$dep" .git)
    if [ -d "libraries/$dep_name" ]; then
        echo "Dependency $dep_name already exists in libraries/, skipping clone."
        continue
    fi

    echo "Cloning $dep into libraries/$dep_name"
    result=$(git clone --depth 1 "$dep" "libraries/$dep_name" 2>&1)
    exitCode=$?
    formatted_result=$(echo "$result" | sed 's/^/    /')
    if [ $exitCode -eq 0 ]; then
        MESSAGES+=("Successfully cloned $dep into libraries/$dep_name:"$'\n'"$formatted_result"$'\n')
    else
        MESSAGES+=("Failed to clone $dep into libraries/$dep_name:"$'\n'"$formatted_result"$'\n')
    fi
done

# If user inputs --preview filename, open openscad to show the preview for that file.
if [ "$1" == "--preview" ] && [ -n "$2" ]; then
    preview_file="$2"
    if [ -f "$preview_file" ]; then
        echo "Opening OpenSCAD to preview $preview_file"
        OPENSCADPATH=libraries openscad "$preview_file"
        exit 0
    else
        echo "File $preview_file does not exist."
        exit 1
    fi
else 
    for f in $FILES
    do
        name=$(basename "$f" .scad)
        fullname="$name-$datetime.3mf"
        echo "Generating out/$fullname from $f"
        result=$(OPENSCADPATH=libraries openscad --hardwarnings -o "out/$fullname" "$f" 2>&1)
        exitCode=$?
        formatted_result=$(echo "$result" | sed 's/^/    /')
        if [ $exitCode -eq 0 ]; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            MESSAGES+=("Successfully generated out/$fullname from $f:"$'\n'"$formatted_result"$'\n')
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
            FAILURE_MESSAGES+=("Failed to generate $fullname from $f:"$'\n'"$formatted_result"$'\n')
        fi
    done

    echo "-------------------------------"
    echo ""
    for msg in "${MESSAGES[@]}"; do
        echo "$msg"
    done

    if [ $FAIL_COUNT -ne 0 ]; then
        for failed in "${FAILURE_MESSAGES[@]}"; do
            echo "$failed"
        done
        echo ""
        echo "Failed to generate ${FAIL_COUNT} of ${NUM_FILES} files."
        exit 1 
    else
        echo ""
        echo "Successfully generated ${SUCCESS_COUNT} files."
        exit 0
    fi
fi
