#!/bin/sh
set -e

PYTHON=${PYTHON:-"/usr/bin/env python3"}
BASEDIR=$(cd -P "`dirname "$0"`" && pwd)
SOURCE="${BASEDIR}/src"
OUTPUT="${BASEDIR}/app"

tmpfile=$(mktemp --suffix .zip)

# clear cache
find "$SOURCE" -name '*.pyc' -delete
find "$SOURCE" -name '__pycache__' -delete

# compile files
# check python version
if $PYTHON -c 'import sys; exit (not (sys.version_info[0] >= 3 and sys.version_info[1] >=2) )'; then
    # python >= 3.2 uses __pycache__
    compile_opts="-b"
else
    compile_opts=""
fi

$PYTHON -mcompileall $compile_opts "$SOURCE"

# content (zipped)
(cd "$SOURCE" && zip -r - . -x "*.py") > "$tmpfile"

# header (she bang)
echo "#!$PYTHON" > "$OUTPUT"
cat "$tmpfile" >> "$OUTPUT"

# make it executable
chmod +x "$OUTPUT"
