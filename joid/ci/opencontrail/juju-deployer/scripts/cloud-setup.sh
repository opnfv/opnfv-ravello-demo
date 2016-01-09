#!/bin/sh -e

. ~/admin-openrc

# adjust tiny image
nova flavor-delete m1.tiny
nova flavor-create m1.tiny 1 512 8 1

# configure external network
neutron net-create --router:external=True public-net
neutron subnet-create --name public-subnet --no-gateway --allocation-pool start=10.0.10.2,end=10.0.10.254 --disable-dhcp public-net 10.0.10.0/24

# create vm network
neutron net-create ubuntu-net
neutron subnet-create --name ubuntu-subnet --gateway 10.0.5.1 ubuntu-net 10.0.5.0/24

# create pool of floating ips
i=0
while [ $i -ne 10 ]; do
	neutron floatingip-create public-net
	i=$((i + 1))
done

# configure security groups
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 default
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 --remote-ip-prefix 0.0.0.0/0 default

# import key pair
nova keypair-add --pub-key id_rsa.pub ubuntu-keypair
