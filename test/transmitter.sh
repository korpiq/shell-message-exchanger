#!/bin/bash

stty -echo # do not show incoming messages

echo "transmitter $* in"
echo "receive transmissions"
echo "send transmissions: message from $*"
while read -t 1 message
do
    echo "transmitter $* got '$message'"
done
echo "transmitter $* out."
