#!/bin/bash

set -ex

#use the below commands if you needs to delete the virtual machine
# also along with envuronment destroy.

echo " Cleanup Started ..."
./clean.sh
 
 virsh destroy opnfv-maas || true
 virsh destroy bootstrap || true
 virsh destroy node1-control || true
 virsh destroy node3-control || true
 virsh destroy node4-control || true
 virsh destroy node2-compute || true
 virsh destroy node5-compute || true
 virsh undefine opnfv-maas || true
 virsh undefine bootstrap || true
 virsh undefine node1-control || true
 virsh undefine node3-control || true
 virsh undefine node4-control || true
 virsh undefine node2-compute || true
 virsh undefine node5-compute || true
 sudo rm -rf  /var/lib/libvirt/images/opnfv-maas.img /var/lib/libvirt/images/bootstrap.img /var/lib/libvirt/images/node1-control.img /var/lib/libvirt/images/node3-control.img /var/lib/libvirt/images/node4-control.img /var/lib/libvirt/images/node2-compute.img /var/lib/libvirt/images/node5-compute.img || true
 
echo " Cleanup Finished ..."
