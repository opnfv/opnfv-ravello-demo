#!/bin/sh -ex

mkdir -p src/charms/trusty
# onos
bzr branch lp:~wuwenbin2/onosfw/onos-controller src/charms/trusty/onos-controller
bzr branch lp:~wuwenbin2/onosfw/neutron-gateway src/charms/trusty/neutron-gateway
bzr branch lp:~wuwenbin2/onosfw/neutron-api-onos src/charms/trusty/neutron-api-onos
bzr branch lp:~wuwenbin2/onosfw/openvswitch-onos src/charms/trusty/openvswitch-onos
# openstack
bzr branch lp:~openstack-charmers/charms/trusty/glance/next src/charms/trusty/glance-next
bzr branch lp:~openstack-charmers/charms/trusty/keystone/next src/charms/trusty/keystone-next
bzr branch lp:~openstack-charmers/charms/trusty/nova-cloud-controller/next src/charms/trusty/nova-cloud-controller-next
bzr branch lp:~openstack-charmers/charms/trusty/openstack-dashboard/next src/charms/trusty/openstack-dashboard-next


mkdir -p charms/trusty
(cd charms/trusty; ln -s ../../src/charms/trusty/* .)
