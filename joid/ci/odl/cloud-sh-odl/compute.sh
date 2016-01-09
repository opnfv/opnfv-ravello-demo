#!/bin/sh -e

modprobe kvm_intel
printf "\n%s\n" kvm_intel >> /etc/modules
service libvirt-bin restart

sed -e 's/KSM_ENABLED=1/KSM_ENABLED=0/' -i /etc/default/qemu-kvm
service qemu-kvm restart
