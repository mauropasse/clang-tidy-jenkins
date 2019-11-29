#!/usr/bin/env bash
# set -e


# This scripts serves to identify files changed in this PR and run
# clang-tidy on them.

# Check if parallel is installed
command -v parallel >/dev/null 2>&1 || {
    echo "Parallel not installed. Aborting.";
    exit 1;
}

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Create an empty array that will contain all the filepaths of files modified.
declare -a MODIFIED_FILEPATHS

# Find the merge BASE compared to master
BASE=$(git merge-base refs/remotes/origin/master HEAD)

# Iterate through modified files in this PR
while read line
do
  # Get the absolute path of each file.
  ABSOLUTE_FILEPATH=$(realpath "$line")

  # Append the absolute filepath.
  MODIFIED_FILEPATHS+=("$ABSOLUTE_FILEPATH")

# `git diff-tree` outputs all the files that differ between the different commits.
# By specifying `--diff-filter=d`, it doesn't report deleted files.
done < <(git diff-tree --no-commit-id --diff-filter=d --name-only -r "$BASE" HEAD)

# Path to compilation database (compile_commands.json)
ARCH="x86_64"
BUILD_DIR=$THIS_DIR/../_build/$ARCH

# Set clang-tidy checks and header-filters
CHECKS="-checks=-*,bugprone-*,-bugprone-narrowing-conversions,-bugprone-branch-clone"
HEADER_FILTER="-header-filter=*,-*/externals/*"
CLANG="clang-tidy-7 $CHECKS $HEADER_FILTER -p $BUILD_DIR"

# Output file
CLANG_OUTPUT_FILE="$BUILD_DIR/clang-tidy-output"
JUNIT_OUTPUT_FILE="junit.xml"

# Enable parallel builds
# `:::`   Arguments are listed after this separator
# `{}`    Specifies where `parallel` adds the command-line arguments
# `| tee` Specifies that we would like the output of clang-tidy to go to `stdout`
# and also to capture it in `$BUILD_DIR/clang-tidy-output` for later processing.
# `N` Processors count
N=$(nproc)

if [ ${#MODIFIED_FILEPATHS[@]} -eq 0 ]; then
    echo "No files changed!"
    echo "" > $CLANG_OUTPUT_FILE
else
    echo "Parallelizing clang-tidy"
    parallel -j$N $CLANG {} ::: "${MODIFIED_FILEPATHS[@]}" | tee $CLANG_OUTPUT_FILE
fi

# Translate raw compiler warning output to JUunit XML file
cat "$CLANG_OUTPUT_FILE" | python3 scripts/clang-tidy-to-junit.py . > $JUNIT_OUTPUT_FILE

# DEBUG
# echo "Modified files: "
# echo "${MODIFIED_FILEPATHS[@]}"
# echo "Clang-tidy output:"
# echo $CLANG_OUTPUT_FILE
# echo "JUnit output:"
# echo $JUNIT_OUTPUT_FILE

