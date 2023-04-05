#!/bin/sh
SRCDIR=$(pwd)/src
DB=$(pwd)/java-sqli-$(cd $SRCDIR && git rev-parse --short HEAD)-4

echo $DB
test -d "$DB" && rm -fR "$DB"
mkdir -p "$DB"

javac com/github/Utils.java 
jar cf utils.jar com/github/Utils.class
codeql database create --language=java -s "$SRCDIR" -j 8 -v $DB --command='../build.sh'
