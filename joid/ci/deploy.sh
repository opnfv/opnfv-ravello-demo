#!/bin/bash

set -ex

#need to put mutiple cases here where decide this bundle to deploy by default use the odl bundle.
# Below parameters are the default and we can according the release

opnfvsdn=nosdn
opnfvtype=nonha
openstack=liberty
opnfvlab=default
opnfvrel=b

read_config() {
    opnfvrel=`grep release: deploy.yaml | cut -d ":" -f2`
    openstack=`grep openstack: deploy.yaml | cut -d ":" -f2`
    opnfvtype=`grep type: deploy.yaml | cut -d ":" -f2`
    opnfvlab=`grep lab: deploy.yaml | cut -d ":" -f2`
    opnfvsdn=`grep sdn: deploy.yaml | cut -d ":" -f2`
}

usage() { echo "Usage: $0 [-s <nosdn|odl|opencontrail>]
                         [-t <nonha|ha|tip>] 
                         [-o <juno|liberty>]
                         [-l <default|intelpod5>]
                         [-r <a|b>]" 1>&2 exit 1; } 

while getopts ":s:t:o:l:h:r:" opt; do
    case "${opt}" in
        s)
            opnfvsdn=${OPTARG}
            ;;
        t)
            opnfvtype=${OPTARG}
            ;;
        o)
            openstack=${OPTARG}
            ;;
        l)
            opnfvlab=${OPTARG}
            ;;
        r)
            opnfvrel=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            ;;
    esac
done

deploy_dep() {
    sudo apt-add-repository ppa:juju/stable -y
    sudo apt-get update
    sudo apt-get install juju git juju-deployer -y
    juju init -f
    cp environments.yaml ~/.juju/
}

#by default maas creates two VMs in case of three more VM needed.
createresource() {
    maas_ip=`grep " ip_address" deployment.yaml | cut -d " "  -f 10`
    apikey=`grep maas-oauth: environments.yaml | cut -d "'" -f 2`
    maas login maas http://${maas_ip}/MAAS/api/1.0 ${apikey}

    nodeexist=`maas maas nodes list hostname=node3-control`

    if [ $nodeexist != *node3* ]; then
        sudo virt-install --connect qemu:///system --name node3-control --ram 8192 --vcpus 4 --disk size=120,format=qcow2,bus=virtio,io=native,pool=default --network bridge=virbr0,model=virtio --network bridge=virbr0,model=virtio --boot network,hd,menu=off --noautoconsole --vnc --print-xml | tee node3-control

        sudo virt-install --connect qemu:///system --name node4-control --ram 8192 --vcpus 4 --disk size=120,format=qcow2,bus=virtio,io=native,pool=default --network bridge=virbr0,model=virtio --network bridge=virbr0,model=virtio --boot network,hd,menu=off --noautoconsole --vnc --print-xml | tee node4-control

        sudo virt-install --connect qemu:///system --name node5-compute --ram 8192 --vcpus 4 --disk size=120,format=qcow2,bus=virtio,io=native,pool=default --network bridge=virbr0,model=virtio --network bridge=virbr0,model=virtio --boot network,hd,menu=off --noautoconsole --vnc --print-xml | tee node5-compute

        node3controlmac=`grep  "mac address" node3-control | head -1 | cut -d "'" -f 2`
        node4controlmac=`grep  "mac address" node4-control | head -1 | cut -d "'" -f 2`
        node5computemac=`grep  "mac address" node5-compute | head -1 | cut -d "'" -f 2`

        sudo virsh -c qemu:///system define --file node3-control
        sudo virsh -c qemu:///system define --file node4-control
        sudo virsh -c qemu:///system define --file node5-compute

        controlnodeid=`maas maas nodes new autodetect_nodegroup='yes' name='node3-control' tags='control' hostname='node3-control' power_type='virsh' mac_addresses=$node3controlmac power_parameters_power_address='qemu+ssh://'$USER'@192.168.122.1/system' architecture='amd64/generic' power_parameters_power_id='node3-control' | grep system_id | cut -d '"' -f 4 `

        maas maas tag update-nodes control add=$controlnodeid

        controlnodeid=`maas maas nodes new autodetect_nodegroup='yes' name='node4-control' tags='control' hostname='node4-control' power_type='virsh' mac_addresses=$node4controlmac power_parameters_power_address='qemu+ssh://'$USER'@192.168.122.1/system' architecture='amd64/generic' power_parameters_power_id='node4-control' | grep system_id | cut -d '"' -f 4 `

        maas maas tag update-nodes control add=$controlnodeid

        computenodeid=`maas maas nodes new autodetect_nodegroup='yes' name='node5-compute' tags='compute' hostname='node5-compute' power_type='virsh' mac_addresses=$node5computemac power_parameters_power_address='qemu+ssh://'$USER'@192.168.122.1/system' architecture='amd64/generic' power_parameters_power_id='node5-compute' | grep system_id | cut -d '"' -f 4 `

        maas maas tag update-nodes compute add=$computenodeid
    fi
}

#copy the files and create extra resources needed for HA deployment
# in case of default VM labs.
deploy() {
    #copy the script which needs to get deployed as part of ofnfv release
    echo "...... deploying now ......"
    echo "   " >> environments.yaml
    echo "        enable-os-refresh-update: false" >> environments.yaml
    echo "        enable-os-upgrade: false" >> environments.yaml
    echo "        admin-secret: admin" >> environments.yaml
    echo "        default-series: trusty" >> environments.yaml

    cp environments.yaml ~/.juju/

    if [[ "$opnfvtype" = "ha" && "$opnfvlab" = "default" ]]; then
        createresource
    fi

    cp ./$opnfvsdn/01-deploybundle.sh ./01-deploybundle.sh
    ./00-bootstrap.sh

    #case default:
    ./01-deploybundle.sh $opnfvtype $openstack $opnfvlab
}

#check whether charms are still executing the code even juju-deployer says installed.
check_status() {
    retval=0
    timeoutiter=0
    while [ $retval -eq 0 ]; do
       sleep 30
       juju status > status.txt 
       if [ "$(grep -c "executing" status.txt )" -ge 1 ]; then
           echo " still executing the reltionship within charms ..."
           if [ $timeoutiter -ge 60 ]; then
               retval=1
           fi
           timeoutiter=$((timeoutiter+1))
       else
           retval=1
       fi
    done
    echo "...... deployment finishing ......."
}

#create config RC file to consume by various tests.
configOpenrc()
{
    echo  "  " > ./cloud/admin-openrc
    echo  "export OS_USERNAME=$1" >> ./cloud/admin-openrc 
    echo  "export OS_PASSWORD=$2" >> ./cloud/admin-openrc
    echo  "export OS_TENANT_NAME=$3" >> ./cloud/admin-openrc
    echo  "export OS_AUTH_URL=$4" >> ./cloud/admin-openrc
    echo  "export OS_REGION_NAME=$5" >> ./cloud/admin-openrc
 }

#to get the address of a service using juju
unitAddress()
{
    juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}

createopenrc()
{
    mkdir -m 0700 -p cloud

    controller_address=$(unitAddress keystone 0)
    configOpenrc admin openstack admin http://$controller_address:5000/v2.0 Canonical 
    chmod 0600 cloud/admin-openrc
}

if [ "$#" -eq 0 ]; then
  echo "This installtion will use default options" 
  #read_config
fi

echo "...... deployment started ......"
#deploy_dep
deploy
check_status
echo "...... deployment finished  ......."

echo "...... creating OpenRc file for consuming by various user ......."

createopenrc

echo "...... finished  ......."


