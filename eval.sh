#!/bin/bash

datadir=data
global_goldfile=golds/test
testfile_basename="test.parsed.final"

function usage {
	echo "Evaluation helper (uses SMATCH)"
    echo
	echo "usage: $0 [DATADIR] [--gold FILE] [--test FILE]"
    echo
	echo "--gold FILE   gold AMR file (default: DATADIR/test_gold or golds/test)"
	echo "--test FILE   test AMR file (default: DATADIR/test.parsed.final)"
	echo
	echo "Default data/model directory: $datadir"
	echo
}

for arg in $@; do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
        usage
        exit 0
    fi
done

default_datadir=1

while [ $# -gt 0 ]; do
	if [ "$1" == "--" ]; then
		shift
		break
    elif [ "$1" == "--gold" ]; then
        shift
		if [ ! -f "$1" ]; then
			echo "error: gold file does not exist: $1"
			exit 1
		fi
		goldfile="$1"
        shift
    elif [ "$1" == "--test" ]; then
        shift
		if [ ! -f "$1" ]; then
			echo "error: test file does not exist: $1"
			exit 1
		fi
		testfile="$1"
        shift
	elif [ -d "$1" ] && [ $default_datadir -eq 1 ]; then
		default_datadir=0
		datadir="$1"
		shift
	else
		echo "unknown argument: $1"
		exit 1
	fi
done

if [ "$testfile" == "" ]; then
	testfile="$datadir/$testfile_basename"
fi

if [ "$goldfile" == "" ]; then

	# user not specified gold file explicitly

	# local goldfile
	if [ -f "$datadir/test_gold" ]; then
		goldfile="$datadir/test_gold"
		echo "using local gold file: $goldfile"
	elif [ -f "$global_goldfile" ]; then
		# global goldfile
		goldfile="$default_goldfile"
		echo "using global gold file: $goldfile"
	else
		echo "error: no local or global gold file found"
		exit 1
	fi

elif [ ! -f "$goldfile" ]; then
	# user specified gold file not found
	echo "error: missing gold file: $goldfile"
	exit 1
fi

if [ ! -f "$testfile" ]; then
	echo "error: missing test file: $testfile"
	exit 1
fi

echo "Executing:"
echo "`dirname $0`/smatch.py --pr -f \"$testfile\" \"$goldfile\" $@"
echo
time `dirname $0`/smatch.py --pr -f "$testfile" "$goldfile" $@
