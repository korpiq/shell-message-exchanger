#!/bin/bash

cd $(dirname "$BASH_SOURCE")
rm -f *.log
RESULT=0

run ()
{
    ../source/command-messenger.exp "$@"
}

check ()
{
    if "$@"
    then
        echo ok
    else
        RESULT=$?
        echo fail
    fi
}

each_transmitter_got_each_message ()
{
    for RECEIVER in "$@"
    do
        for SENDER in "$@"
        do
            grep -q "transmitter $RECEIVER got 'message from $SENDER'" \
                $RECEIVER.log ||
                return 1
        done
    done
}

echo -n 'fail on bad option: '
OUT=$(run --badmojo=here)
echo "$OUT" | check grep -q "^Invalid option 'badmojo'"

echo -n 'accept all good options: '
OUT=$(run --prefix= --suffix= --log= --once= --ask= --tell=)
check test "$OUT" = ""

echo -n 'try to pass message from one shell to another: '
OUT=$(run ./sender.sh ./receiver.sh)
echo "$OUT" | check grep -q "got 'a message'"

echo -n 'try to pass messages forth and back between transmitters: '
NAMES="Alice Bob Cecilia"
run --log='{}' --prefix='./transmitter.sh ' $NAMES
check each_transmitter_got_each_message $NAMES

exit $RESULT
