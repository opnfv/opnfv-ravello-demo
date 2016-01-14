#!/bin/bash

set -ex

if [ -d $HOME/.juju/environments ]; then
    echo " " > status.txt
    juju status  &>>status.txt || true
    if [ "$(grep -c "environment is not bootstrapped" status.txt )" -ge 1 ]; then
        echo " environment is not bootstrapped ..."
    else
        echo " environment is bootstrapped ..."
        juju destroy-environment demo-maas  -y
        rm -rf $HOME/.juju/j*
        rm -rf $HOME/.juju/.deployer-store-cache
    fi
    rm -rf $HOME/.juju/environments
    rm -rf $HOME/.juju/ssh
fi

