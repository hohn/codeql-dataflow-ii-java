#!/bin/sh
SRCDIR=$(pwd)
DB=$SRCDIR/java-sqli-$(cd $SRCDIR && git rev-parse --short HEAD)

echo $DB
test -d "$DB" && rm -fR "$DB"
mkdir -p "$DB"

cd $SRCDIR && codeql database create --language=java -s . -j 8 -v $DB --command='./build.sh'
