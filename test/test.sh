#!/bin/bash

cd $(dirname "$BASH_SOURCE")

function run
{
    ../source/command-messenger.exp "$@"
}

echo -n 'try to pass message from one shell to another: '
run ./sender.sh ./receiver.sh |
    grep -q "got 'a message'" &&
    echo ok ||
    echo fail

echo -n 'try to pass messages forth and back between transmitters: '
OUT=$(run "./transmitter.sh Alice" "./transmitter.sh Bob" "./transmitter.sh Cecilia")
RE="^transmitter [ABC][a-z]* got 'message from [ABC][a-z]*'"
[ 9 == $(echo "$OUT" | grep -c "$RE") ] &&
[ 9 == $(echo "$OUT" | uniq | grep -c "$RE") ] &&
    echo ok ||
    echo fail

