#!/usr/bin/env bash

sudo apt-get install python-pip -y
sudo pip install -U ravello-sdk

echo "WARNING: This patch was tested for MAAS version 1.8.3"
echo "Applying this patch on a different version of MAAS might break your environment."
read -p "Continue (y/n)?" choice
if [[ $choice != "y" && $choice != "Y" ]]; then
    echo "Exiting..."
    exit 0
fi

DIR=`pwd`
pushd /
sudo patch -p1 -N < $DIR/ravello-maas-patch.diff
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
    echo "Failed to restart maas-clusterd"
    exit 1
fi
