#!/bin/bash

cd $(dirname "$BASH_SOURCE")
rm *.log
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
    RE="transmitter [ABC][a-z]* got 'message from [ABC][a-z]*'"

    for LOG in transmitter.sh*.log
    do
        [ 3 == $(grep -c "$RE" "$LOG") ] &&
        [ 3 == $(uniq "$LOG" | grep -c "$RE") ] ||
            return 1
    done
}

echo -n 'try to pass message from one shell to another: '
run ./sender.sh ./receiver.sh
check grep -q "got 'a message'" receiver.sh.log

echo -n 'try to pass messages forth and back between transmitters: '

run "./transmitter.sh Alice" \
        "./transmitter.sh Bob" \
        "./transmitter.sh Cecilia"
check each_transmitter_got_each_message
