#!/bin/sh -ex

mkdir -p src/charms/trusty

# openstack
bzr branch lp:~openstack-charmers/charms/trusty/glance/next src/charms/trusty/glance-next
bzr branch lp:~openstack-charmers/charms/trusty/keystone/next src/charms/trusty/keystone-next
bzr branch lp:~sdn-charmers/charms/trusty/neutron-api/odl src/charms/trusty/neutron-api-odl
bzr branch lp:~openstack-charmers/charms/trusty/nova-cloud-controller/next src/charms/trusty/nova-cloud-controller-next
bzr branch lp:~sdn-charmers/charms/trusty/nova-compute/odl src/charms/trusty/nova-compute-odl
bzr branch lp:~openstack-charmers/charms/trusty/openstack-dashboard/next src/charms/trusty/openstack-dashboard-next
bzr branch lp:~sdn-charmers/charms/trusty/quantum-gateway/odl src/charms/trusty/quantum-gateway-odl

# opendaylight
bzr branch lp:~sdn-charmers/charms/trusty/odl-controller/trunk src/charms/trusty/odl-controller
bzr branch lp:~sdn-charmers/charms/trusty/neutron-odl/trunk src/charms/trusty/neutron-odl

mkdir -p charms/trusty
(cd charms/trusty; ln -s ../../src/charms/trusty/* .)
