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

transmitter_log_contains_message_from_each ()
{
    RECEIVER="$1"
    LOGFILE="$2"
    shift 2

    for SENDER in "$@"
    do
        MSG="transmitter $RECEIVER got 'message from $SENDER'"
        [ 1 == $(grep -c "$MSG" "$LOGFILE") ] || return 1
    done
}

each_transmitter_log_got_each_message_once ()
{
    for RECEIVER in "$@"
    do
        transmitter_log_contains_message_from_each \
            "$RECEIVER" "$RECEIVER.log" "$@" ||
                return 1
    done
}

log_got_each_message_once ()
{
    LOGFILE="$1"
    shift
    for RECEIVER in "$@"
    do
        transmitter_log_contains_message_from_each \
            "$RECEIVER" "$LOGFILE" "$@" ||
                return 1
    done
}

echo -n 'fail on bad option: '
OUT=$(run --badmojo=here)
echo "$OUT" | check grep -q "^Invalid option 'badmojo'"

echo -n 'accept all good options: '
OUT=$(run --prefix= --suffix= --log= --once= --send= --receive=)
check test "$OUT" = ""

echo -n 'try to pass message from one shell to another: '
OUT=$(run ./sender.sh ./receiver.sh)
echo "$OUT" | check grep -q "got 'a message'"

echo -n 'try to pass messages forth and back between transmitters: '
NAMES="Alice Bob Cecilia"
run --log='{}' --prefix='./transmitter.sh ' $NAMES
check each_transmitter_log_got_each_message_once $NAMES

echo -n 'several clients can log into same file: '
NAMES="Alice Bob Cecilia"
LOGFILE='AllInOne.log'
run --log="$LOGFILE" --prefix='./transmitter.sh ' $NAMES
check log_got_each_message_once "$LOGFILE" $NAMES

exit $RESULT
