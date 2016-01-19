#!/bin/sh -ex

mkdir -p src/charms/trusty src/charms/precise

# openstack
bzr branch lp:~openstack-charmers/charms/trusty/glance/next src/charms/trusty/glance-next
bzr branch lp:~openstack-charmers/charms/trusty/keystone/next src/charms/trusty/keystone-next
bzr branch lp:~openstack-charmers/charms/trusty/neutron-api/next src/charms/trusty/neutron-api-next
bzr branch lp:~openstack-charmers/charms/trusty/nova-cloud-controller/next src/charms/trusty/nova-cloud-controller-next
bzr branch lp:~openstack-charmers/charms/trusty/nova-compute/next src/charms/trusty/nova-compute-next
bzr branch lp:~openstack-charmers/charms/trusty/openstack-dashboard/next src/charms/trusty/openstack-dashboard-next

# contrail
bzr branch lp:~stub/charms/trusty/cassandra/noauthentication src/charms/trusty/cassandra-noauthentication
bzr branch lp:~sdn-charmers/charms/trusty/contrail-analytics/trunk src/charms/trusty/contrail-analytics
bzr branch lp:~sdn-charmers/charms/trusty/contrail-configuration/trunk src/charms/trusty/contrail-configuration
bzr branch lp:~sdn-charmers/charms/trusty/contrail-control/trunk src/charms/trusty/contrail-control
bzr branch lp:~sdn-charmers/charms/trusty/contrail-webui/trunk src/charms/trusty/contrail-webui
bzr branch lp:~sdn-charmers/charms/trusty/neutron-api-contrail/trunk src/charms/trusty/neutron-api-contrail
bzr branch lp:~sdn-charmers/charms/trusty/neutron-contrail/trunk src/charms/trusty/neutron-contrail
bzr branch lp:~charmers/charms/precise/zookeeper/trunk src/charms/precise/zookeeper

mkdir -p charms/trusty charms/precise
(cd charms/trusty; ln -s ../../src/charms/trusty/* .)
# symlink trusty charms to precise
(cd charms/precise; ln -s ../../src/charms/trusty/* .; ln -s ../../src/charms/precise/* .)
