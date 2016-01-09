#!/bin/sh -ex

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

mkdir -m 0700 -p cloud
controller_address=$(unitAddress keystone 0)
configOpenrc admin openstack admin http://$controller_address:5000/v2.0 Canonical > cloud/admin-openrc
chmod 0600 cloud/admin-openrc

machine=$(unitMachine glance 0)
juju scp glance.sh cloud/admin-openrc $machine:
juju run --machine $machine ./glance.sh

machine=$(unitMachine nova-cloud-controller 0)
juju scp cloud-setup.sh cloud/admin-openrc ~/.ssh/id_rsa.pub $machine:
juju run --machine $machine ./cloud-setup.sh

