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

    [ -f "$LOGFILE" ] || return 1

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
OUT=$(run --prefix= --suffix= --log= --send= --receive=)
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
LOGFILE='all-in-one.log'
run --log="$LOGFILE" --prefix='./transmitter.sh ' $NAMES
check log_got_each_message_once "$LOGFILE" $NAMES

echo -n 'error status is passed through: '
run 'echo ok before' '/bin/bash -c "exit 123"' 'echo ok after' >& /dev/null
check test 123 = $?

# report status for this platform in README
VERSIONS="$(expect -version) on $(uname -sr)"
[ 0 = "$RESULT" ] && HOW=pass || HOW=fail
README=../README.md
if grep -q "^Tests [a-z]* with $VERSIONS$" "$README"
then
    sed -i~ -e \
        "s/^Tests [a-z]* with $VERSIONS$/Tests $HOW with $VERSIONS/" \
        "$README"
else
    echo "Tests $HOW with $VERSIONS" >> "$README"
fi

exit $RESULT
