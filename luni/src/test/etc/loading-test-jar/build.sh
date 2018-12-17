#!/bin/bash -e
#
# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set up prog to be the path of this script, including following
# symlinks, and set up progdir to be the fully-qualified pathname of
# its directory.  Switch the current directory to progdir for the
# remainder of the script.
prog="$0"
while [ -h "${prog}" ]; do
    newProg=`/bin/ls -ld "${prog}"`
    newProg=`expr "${newProg}" : ".* -> \(.*\)$"`
    if expr "x${newProg}" : 'x/' >/dev/null; then
        prog="${newProg}"
    else
        progdir=`dirname "${prog}"`
        prog="${progdir}/${newProg}"
    fi
done
oldwd=`pwd`
progdir=`dirname "${prog}"`
cd "${progdir}"

resourceDir=../../resources/dalvik/system

rm -rf classes
rm -rf classes2
rm -rf classes.dex
rm -rf loading-test.jar

# This library depends on loading-test2, so compile those classes first,
# but keep them separate.
mkdir classes2
javac -d classes2 ../loading-test2-jar/*.java

mkdir classes
javac -classpath classes2 -d classes *.java
find classes -type f | xargs d8 --output . --classpath classes2 # Creates classes.dex
jar cf loading-test.jar classes.dex -C resources .

rm -rf classes
rm -rf classes2
mv classes.dex ${resourceDir}/loading-test.dex
mv loading-test.jar ${resourceDir}
