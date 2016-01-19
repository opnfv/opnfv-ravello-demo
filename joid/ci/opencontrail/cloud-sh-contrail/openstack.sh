#!/bin/sh -ex

agentState()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"machines\"][\"$1\"][\"agent-state\"]" 2> /dev/null
}

agentStateUnit()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"agent-state\"]" 2> /dev/null
}

configOpenrc()
{
	cat <<-EOF
		export OS_USERNAME=$1
		export OS_PASSWORD=$2
		export OS_TENANT_NAME=$3
		export OS_AUTH_URL=$4
		export OS_REGION_NAME=$5
		EOF
}

unitAddress()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}

unitMachine()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"machine\"]" 2> /dev/null
}

waitForMachine()
{
	for machine; do
		while [ "$(agentState $machine)" != started ]; do
			sleep 5
		done
	done
}

waitForService()
{
	for service; do
		while [ "$(agentStateUnit "$service" 0)" != started ]; do
			sleep 5
		done
	done
}

if [ $# -ne 0 ]; then
	. "$1"
fi

juju bootstrap
waitForMachine 0

spare_cpus=$(($(grep processor /proc/cpuinfo | wc -l) - 4))
if [ $spare_cpus -gt 0 ]; then
	spare_cpus=$(((spare_cpus * 3) / 4))
else
	spare_cpus=0
fi

extra_cpus=0
[ $spare_cpus -ne 0 ] && extra_cpus=$((1 + (((spare_cpus - 1) * 3) / 4))) && spare_cpus=$((spare_cpus - extra_cpus))
juju add-machine --constraints "cpu-cores=$((1 + extra_cpus)) mem=12G root-disk=20G" --series $DEFAULT_SERIES

extra_cpus=0
[ $spare_cpus -ne 0 ] && extra_cpus=$((1 + (((spare_cpus - 1) * 3) / 4))) && spare_cpus=$((spare_cpus - extra_cpus))
juju deploy --constraints "cpu-cores=$((1 + extra_cpus)) mem=4G root-disk=20G" $CHARM_NOVA_COMPUTE_DEPLOY_OPTS "${CHARM_NOVA_COMPUTE:-nova-compute}"

juju add-machine --constraints "cpu-cores=$((1 + spare_cpus)) mem=8G root-disk=20G" --series $DEFAULT_SERIES

waitForMachine 1
juju scp lxc-network.sh 1:
juju run --machine 1 "sudo ./lxc-network.sh"

waitForMachine 3
juju scp lxc-network.sh 3:
juju run --machine 3 "sudo ./lxc-network.sh"

juju deploy --to lxc:1 $CHARM_MYSQL_DEPLOY_OPTS "${CHARM_MYSQL:-mysql}"
juju deploy --to lxc:1 $CHARM_RABBITMQ_SERVER_DEPLOY_OPTS "${CHARM_RABBITMQ_SERVER:-rabbitmq-server}"
juju deploy --to lxc:1 $CHARM_KEYSTONE_DEPLOY_OPTS "${CHARM_KEYSTONE:-keystone}"
juju deploy --to lxc:1 $CHARM_NOVA_CLOUD_CONTROLLER_DEPLOY_OPTS "${CHARM_NOVA_CLOUD_CONTROLLER:-nova-cloud-controller}"
juju deploy --to lxc:1 $CHARM_NEUTRON_API_DEPLOY_OPTS "${CHARM_NEUTRON_API:-neutron-api}"
juju deploy --to lxc:1 $CHARM_GLANCE_DEPLOY_OPTS "${CHARM_GLANCE:-glance}"
juju deploy --to lxc:1 $CHARM_OPENSTACK_DASHBOARD_DEPLOY_OPTS "${CHARM_OPENSTACK_DASHBOARD:-openstack-dashboard}"
# contrail
juju deploy --to lxc:1 $CHARM_ZOOKEEPER_DEPLOY_OPTS "${CHARM_ZOOKEEPER:-zookeeper}"
juju deploy --to lxc:1 $CHARM_CONTRAIL_CONFIGURATION_DEPLOY_OPTS "${CHARM_CONTRAIL_CONFIGURATION:-contrail-configuration}"
juju deploy --to lxc:1 $CHARM_CONTRAIL_CONTROL_DEPLOY_OPTS "${CHARM_CONTRAIL_CONTROL:-contrail-control}"
juju deploy --to lxc:1 $CHARM_CONTRAIL_ANALYTICS_DEPLOY_OPTS "${CHARM_CONTRAIL_ANALYTICS:-contrail-analytics}"
juju deploy --to lxc:1 $CHARM_CONTRAIL_WEBUI_DEPLOY_OPTS "${CHARM_CONTRAIL_WEBUI:-contrail-webui}"
juju deploy --to lxc:3 $CHARM_CASSANDRA_DEPLOY_OPTS "${CHARM_CASSANDRA:-cassandra}"
juju deploy $CHARM_NEUTRON_API_CONTRAIL_DEPLOY_OPTS "${CHARM_NEUTRON_API_CONTRAIL:-neutron-api-contrail}"
juju deploy $CHARM_NEUTRON_CONTRAIL_DEPLOY_OPTS "${CHARM_NEUTRON_CONTRAIL:-neutron-contrail}"

# relation must be set first
# no official way of knowing when this relation hook will fire
waitForService mysql keystone
juju add-relation keystone mysql
sleep 60

waitForService rabbitmq-server nova-cloud-controller glance openstack-dashboard nova-compute
juju add-relation nova-cloud-controller mysql
juju add-relation nova-cloud-controller rabbitmq-server
juju add-relation nova-cloud-controller glance
juju add-relation nova-cloud-controller keystone
juju add-relation nova-compute:shared-db mysql:shared-db
juju add-relation nova-compute:amqp rabbitmq-server:amqp
juju add-relation nova-compute glance
juju add-relation nova-compute nova-cloud-controller
juju add-relation glance mysql
juju add-relation glance keystone
juju add-relation openstack-dashboard keystone
sleep 60

waitForService neutron-api
juju add-relation neutron-api mysql
juju add-relation neutron-api rabbitmq-server
juju add-relation neutron-api nova-cloud-controller
juju add-relation neutron-api keystone
juju add-relation neutron-api neutron-api-contrail
sleep 60

# contrail
waitForService cassandra zookeeper contrail-configuration
juju add-relation contrail-configuration:cassandra cassandra:database
juju add-relation contrail-configuration zookeeper
juju add-relation contrail-configuration rabbitmq-server
juju add-relation contrail-configuration keystone
sleep 60

waitForService contrail-control contrail-analytics
juju add-relation neutron-api-contrail contrail-configuration
juju add-relation neutron-api-contrail keystone
juju add-relation contrail-control:contrail-api contrail-configuration:contrail-api
juju add-relation contrail-control:contrail-discovery contrail-configuration:contrail-discovery
juju add-relation contrail-control:contrail-ifmap contrail-configuration:contrail-ifmap
juju add-relation contrail-control keystone
juju add-relation contrail-analytics:cassandra cassandra:database
juju add-relation contrail-analytics contrail-configuration
juju add-relation nova-compute neutron-contrail
juju add-relation neutron-contrail:contrail-discovery contrail-configuration:contrail-discovery
juju add-relation neutron-contrail:contrail-api contrail-configuration:contrail-api
juju add-relation neutron-contrail keystone
sleep 60

waitForService contrail-webui
juju add-relation contrail-webui keystone
juju add-relation contrail-webui:contrail_api contrail-configuration:contrail-api
juju add-relation contrail-webui:contrail_discovery contrail-configuration:contrail-discovery
juju add-relation contrail-webui:cassandra cassandra:database
sleep 60

# enable kvm on compute
machine=$(unitMachine nova-compute 0)
juju scp compute.sh $machine:
juju run --machine $machine "sudo ./compute.sh"

mkdir -m 0700 -p cloud
controller_address=$(unitAddress keystone 0)
configOpenrc admin password Admin http://$controller_address:5000/v2.0 RegionOne > cloud/admin-openrc
chmod 0600 cloud/admin-openrc

machine=$(unitMachine nova-cloud-controller 0)
juju scp cloud-setup.sh cloud/admin-openrc ~/.ssh/id_rsa.pub $machine:
juju run --machine $machine ./cloud-setup.sh

# setup contrail routing
juju set contrail-configuration "floating-ip-pools=[ { project: admin, network: public-net, pool-name: floatingip_pool, target-projects: [ admin ] } ]"
juju set neutron-contrail "virtual-gateways=[ { project: admin, network: public-net, interface: vgw, subnets: [ 10.0.10.0/24 ], routes: [ 0.0.0.0/0 ] } ]"

machine=$(unitMachine glance 0)
juju scp glance.sh cloud/admin-openrc $machine:
juju run --machine $machine ./glance.sh

# setup host routing
if [ -n "$CONFIGURE_HOST_ROUTING" ]; then
	compute_address=$(unitAddress nova-compute 0)
	sudo ip route replace 10.0.10.0/24 via $compute_address
	sudo iptables -C FORWARD -s 10.0.10.0/24 -j ACCEPT 2> /dev/null || sudo iptables -I FORWARD 1 -s 10.0.10.0/24 -j ACCEPT
	sudo iptables -C FORWARD -d 10.0.10.0/24 -j ACCEPT 2> /dev/null || sudo iptables -I FORWARD 2 -d 10.0.10.0/24 -j ACCEPT
	sudo iptables -t nat -C POSTROUTING -s 10.0.10.0/24 ! -d 10.0.10.0/24 -j MASQUERADE 2> /dev/null || sudo iptables -t nat -A POSTROUTING -s 10.0.10.0/24 ! -d 10.0.10.0/24 -j MASQUERADE
fi
