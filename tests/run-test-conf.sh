#!/bin/bash

set -x
if [[ -z "$srcdir" ]] ; then
    srcdir=..
fi
tdir="$srcdir"/tests

pids=()
# run me from the top-level build dir
tests/ssg-test -s 2 bmi+tcp://3344 conf "$tdir"/test.conf > test.0.out 2>&1 &
pids[0]=$!
tests/ssg-test -s 2 bmi+tcp://3345 conf "$tdir"/test.conf > test.1.out 2>&1 &
pids[1]=$!
tests/ssg-test -s 2 bmi+tcp://3346 conf "$tdir"/test.conf > test.2.out 2>&1 &
pids[2]=$!

err=0
for pid in ${pids[@]} ; do
    if [[ $err != 0 ]] ; then
        kill $pid
    else
        wait $pid
        err=$?
        if [[ $err != 0 ]] ; then
            echo "ERROR (code $err), killing remaining"
        fi
    fi
done

if [[ $err == 0 ]] ; then rm test.0.out test.1.out test.2.out ; fi

exit $err
