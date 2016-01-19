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
			sleep 60
		done
	done
}

waitForService()
{
	for service; do
		while [ "$(agentStateUnit "$service" 0)" != started ]; do
			sleep 60
		done
	done
}

if [ $# -ne 0 ]; then
	. "$1"
fi

juju bootstrap
waitForMachine 0

spare_cpus=$(($(grep processor /proc/cpuinfo | wc -l) - 5))
if [ $spare_cpus -gt 0 ]; then
	spare_cpus=$(((spare_cpus * 3) / 4))
else
	spare_cpus=0
fi

extra_cpus=0
[ $spare_cpus -ne 0 ] && extra_cpus=$((1 + (((spare_cpus - 1) * 3) / 4))) && spare_cpus=$((spare_cpus - extra_cpus))
juju add-machine --constraints "cpu-cores=$((1 + extra_cpus)) mem=8G root-disk=20G" --series $DEFAULT_SERIES

juju deploy --constraints mem=1G $CHARM_NEUTRON_GATEWAY_DEPLOY_OPTS "${CHARM_NEUTRON_GATEWAY:-neutron-gateway}" neutron-gateway

juju deploy --constraints "cpu-cores=$((1 + spare_cpus)) mem=4G root-disk=20G" $CHARM_NOVA_COMPUTE_DEPLOY_OPTS "${CHARM_NOVA_COMPUTE:-nova-compute}"

waitForMachine 1
juju scp lxc-network.sh 1:
juju run --machine 1 "sudo ./lxc-network.sh"
juju deploy --to lxc:1 $CHARM_MYSQL_DEPLOY_OPTS "${CHARM_MYSQL:-mysql}"
juju deploy --to lxc:1 $CHARM_RABBITMQ_SERVER_DEPLOY_OPTS "${CHARM_RABBITMQ_SERVER:-rabbitmq-server}"
juju deploy --to lxc:1 $CHARM_KEYSTONE_DEPLOY_OPTS "${CHARM_KEYSTONE:-keystone}"
juju deploy --to lxc:1 $CHARM_NOVA_CLOUD_CONTROLLER_DEPLOY_OPTS "${CHARM_NOVA_CLOUD_CONTROLLER:-nova-cloud-controller}"
juju deploy --to lxc:1 $CHARM_NEUTRON_API_DEPLOY_OPTS "${CHARM_NEUTRON_API:-neutron-api}"
juju deploy --to lxc:1 $CHARM_GLANCE_DEPLOY_OPTS "${CHARM_GLANCE:-glance}"
juju deploy --to lxc:1 $CHARM_OPENSTACK_DASHBOARD_DEPLOY_OPTS "${CHARM_OPENSTACK_DASHBOARD:-openstack-dashboard}"
# onos
juju deploy --to lxc:1 $CHARM_ONOS_CONTROLLER_DEPLOY_OPTS "${CHARM_ONOS_CONTROLLER:-onos-controller}"

# relation must be set first
# no official way of knowing when this relation hook will fire
waitForService mysql keystone
juju add-relation keystone mysql
sleep 60

waitForService rabbitmq-server nova-cloud-controller glance
juju add-relation nova-cloud-controller mysql
juju add-relation nova-cloud-controller rabbitmq-server
juju add-relation nova-cloud-controller glance
juju add-relation nova-cloud-controller keystone
sleep 60

waitForService neutron-api
juju add-relation neutron-api mysql
juju add-relation neutron-api rabbitmq-server
juju add-relation neutron-api keystone
juju add-relation neutron-api nova-cloud-controller
sleep 60

waitForService openstack-dashboard neutron-gateway nova-compute
juju add-relation neutron-gateway mysql
juju add-relation neutron-gateway:amqp rabbitmq-server:amqp
juju add-relation neutron-gateway nova-cloud-controller
juju add-relation neutron-gateway neutron-api
juju add-relation nova-compute:shared-db mysql:shared-db
juju add-relation nova-compute:amqp rabbitmq-server:amqp
juju add-relation nova-compute glance
juju add-relation nova-compute nova-cloud-controller
juju add-relation glance mysql
juju add-relation glance keystone
juju add-relation openstack-dashboard keystone
sleep 60

# onos
waitForService onos-controller
juju add-relation neutron-api onos-controller
juju add-relation neutron-gateway onos-controller
juju add-relation nova-compute onos-controller
sleep 60

# enable kvm on compute
machine=$(unitMachine nova-compute 0)
juju scp compute.sh $machine:
juju run --machine $machine "sudo ./compute.sh"

mkdir -m 0700 -p cloud
controller_address=$(unitAddress keystone 0)
configOpenrc admin admin Admin http://$controller_address:5000/v2.0 RegionOne > cloud/admin-openrc
chmod 0600 cloud/admin-openrc

# keystone need some extra time before it become availble for cloud operations.

sleep 300
machine=$(unitMachine nova-cloud-controller 0)
juju scp cloud-setup.sh cloud/admin-openrc ~/.ssh/id_rsa.pub $machine:
juju run --machine $machine ./cloud-setup.sh

machine=$(unitMachine glance 0)
juju scp glance.sh cloud/admin-openrc $machine:
juju run --machine $machine ./glance.sh
