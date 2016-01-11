#!/usr/bin/env bash

sudo apt-get install python-pip -y
sudo pip install -U ravello-sdk

DIR=`pwd`
pushd /
sudo patch -p1 < $DIR/ravello-maas-patch.diff
popd

sudo cp power/ravello-power-cmd.py /etc/maas/templates/power
sudo cp power/ravello.template /etc/maas/templates/power
sudo chmod +x /etc/maas/templates/power/ravello-power-cmd.py

sudo /etc/init.d/apache2 restart
if [[ $? -ne 1 ]]; then
    echo "Failed to restart apache2"
    exit 1
fi

sleep 3

sudo restart maas-clusterd
if [[ $? -ne 1 ]]; then
    echo "Failed to restart apache2"
    exit 1
fi
