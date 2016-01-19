export JUJU_REPOSITORY=../charms

DEFAULT_SERIES=precise

CHARM_CASSANDRA=local:precise/cassandra
CHARM_CASSANDRA_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_CONTRAIL_ANALYTICS=local:precise/contrail-analytics
CHARM_CONTRAIL_ANALYTICS_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_CONTRAIL_CONFIGURATION=local:precise/contrail-configuration
CHARM_CONTRAIL_CONFIGURATION_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_CONTRAIL_CONTROL=local:precise/contrail-control
CHARM_CONTRAIL_CONTROL_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_CONTRAIL_WEBUI=local:trusty/contrail-webui

CHARM_GLANCE=local:precise/glance
CHARM_GLANCE_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_KEYSTONE=local:precise/keystone
CHARM_KEYSTONE_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_MYSQL=precise/mysql
CHARM_MYSQL_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_NEUTRON_API=local:precise/neutron-api
CHARM_NEUTRON_API_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_NEUTRON_API_CONTRAIL=local:precise/neutron-api-contrail

CHARM_NEUTRON_CONTRAIL=local:precise/neutron-contrail

CHARM_NOVA_CLOUD_CONTROLLER=local:precise/nova-cloud-controller
CHARM_NOVA_CLOUD_CONTROLLER_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_NOVA_COMPUTE=local:precise/nova-compute
CHARM_NOVA_COMPUTE_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_OPENSTACK_DASHBOARD=local:precise/openstack-dashboard
CHARM_OPENSTACK_DASHBOARD_DEPLOY_OPTS="--config config-precise.yaml"

CHARM_RABBITMQ_SERVER=precise/rabbitmq-server

CHARM_ZOOKEEPER=local:precise/zookeeper

CONFIGURE_HOST_ROUTING=true
