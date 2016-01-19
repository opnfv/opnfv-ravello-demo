export JUJU_REPOSITORY=../charms

DEFAULT_SERIES=trusty

CHARM_CASSANDRA=local:trusty/cassandra
CHARM_CASSANDRA_DEPLOY_OPTS="--config config-trusty.yaml"

CHARM_CONTRAIL_ANALYTICS=local:trusty/contrail-analytics

CHARM_CONTRAIL_CONFIGURATION=local:trusty/contrail-configuration

CHARM_CONTRAIL_CONTROL=local:trusty/contrail-control

CHARM_CONTRAIL_WEBUI=local:trusty/contrail-webui

CHARM_GLANCE=local:trusty/glance

CHARM_KEYSTONE=local:trusty/keystone
CHARM_KEYSTONE_DEPLOY_OPTS="--config config-trusty.yaml"

CHARM_MYSQL=trusty/mysql
CHARM_MYSQL_DEPLOY_OPTS="--config config-trusty.yaml"

CHARM_NEUTRON_API=local:trusty/neutron-api
CHARM_NEUTRON_API_DEPLOY_OPTS="--config config-trusty.yaml"

CHARM_NEUTRON_API_CONTRAIL=local:trusty/neutron-api-contrail

CHARM_NEUTRON_CONTRAIL=local:trusty/neutron-contrail

CHARM_NOVA_CLOUD_CONTROLLER=local:trusty/nova-cloud-controller
CHARM_NOVA_CLOUD_CONTROLLER_DEPLOY_OPTS="--config config-trusty.yaml"

CHARM_NOVA_COMPUTE=local:trusty/nova-compute
CHARM_NOVA_COMPUTE_DEPLOY_OPTS="--config config-trusty.yaml"

CHARM_OPENSTACK_DASHBOARD=local:trusty/openstack-dashboard

CHARM_RABBITMQ_SERVER=trusty/rabbitmq-server

CHARM_ZOOKEEPER=local:precise/zookeeper

CONFIGURE_HOST_ROUTING=true
