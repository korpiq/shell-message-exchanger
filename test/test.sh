#!/bin/bash

cd $(dirname "$BASH_SOURCE")

echo -n 'try to pass message from one shell to another: '
./../source/installer.exp sender.sh receiver.sh |
    grep -q "got 'a message'" &&
    echo ok ||
    echo fail

