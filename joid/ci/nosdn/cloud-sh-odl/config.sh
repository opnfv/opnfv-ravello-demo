export JUJU_REPOSITORY=../charms

DEFAULT_SERIES=trusty

CHARM_GLANCE=local:trusty/glance

CHARM_KEYSTONE=local:trusty/keystone
CHARM_KEYSTONE_DEPLOY_OPTS="--config config.yaml"

CHARM_MYSQL=trusty/mysql
CHARM_MYSQL_DEPLOY_OPTS="--config config.yaml"

CHARM_NEUTRON_API=local:trusty/neutron-api
CHARM_NEUTRON_API_DEPLOY_OPTS="--config config.yaml"

CHARM_NEUTRON_GATEWAY=local:trusty/quantum-gateway
CHARM_NEUTRON_GATEWAY_DEPLOY_OPTS="--config config.yaml"

CHARM_NEUTRON_ODL=local:trusty/neutron-odl

CHARM_NOVA_CLOUD_CONTROLLER=local:trusty/nova-cloud-controller
CHARM_NOVA_CLOUD_CONTROLLER_DEPLOY_OPTS="--config config.yaml"

CHARM_NOVA_COMPUTE=local:trusty/nova-compute

CHARM_ODL_CONTROLLER=local:trusty/odl-controller

CHARM_OPENSTACK_DASHBOARD=local:trusty/openstack-dashboard

CHARM_RABBITMQ_SERVER=trusty/rabbitmq-server
