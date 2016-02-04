# opnfv-ravello-demo

## Introduction
These are my rough notes from the implementation of the OPNFV Academy framework on Ravello Systems hosted cloud environment.

There are 5 blueprints we are working on:

1. Pre-built MaaS with empty nodes - ready to build OPNFV with your SDN choice - done - take an hour or two to deploy this blueprint, configure maas then four hours later you can have a working OPNFV setup you can customize. Not self-contained - needs ssh keys, github, edit files. For more advanced developer.
2. Deployed OPNFV with OpenStack Juno and Juniper Contrail SDN OpenStack Juno - done - spin up an app from this blueprint and in 20 minutes you will have a working OpenStack environment. Beginner level.
3. Deployed OPNFV with ODL SDN OpenStack Liberty - blueprint draft published in January
4. Deployed OPNFV with ONOS SDN OpenStack Liberty - pending
5. Deployed OPNFV with no SDN OpenStack Tip/Master - pending

![alt text](https://github.com/opnfv/opnfv-ravello-demo/raw/master/pics/OPNFV-Ravello-4node4net.png "OPNFV Academy Drawing")

#Purpose
We are building out an OPNFV environment in Ravello. This environment will be shared publicly as a Ravello Blueprint. A blog post and training program will be created around this blog post. Different team members can use this setup to learn about OPNFV or to expand on it for use as a Sales Demo tool or for customer facing POCs or even QA/DevTest functional testing scenarios.
- Topology is based off the simple: https://wiki.opnfv.org/copper/academy 
- Using: https://www.ravellosystems.com/
- Built with: https://wiki.opnfv.org/joid/get_started
- See needed files shared here: https://github.com/opnfv/opnfv-ravello-demo
- Minimal scripting. Using web interface for most actions. 
- Simple getting started environment intended for opnfv experimentation. 
- Rapid low cost iteration with minimal upfront investment in time or hardware. 
- Expert mode available for command line experts with REST API experience. 

# Decision Process
This section is an attempt to explain why we are using Ravello and will guide our strategy for the build out.

There are three ways to consume OPNFV:

1. Automated setup using static machines driven by jenkins jobs reading gerrit running on a daily and weekly build process. jenkins jobs handle the installation, configuration, and testing of the OPNFV platform. Required LFID and Authorization to make any changes as well as dedicated hardware.
1. Assisted Install: Use a pre-built jump server setup to download latest code from a public github repo and pxe-boot some machines. More flexible and “open” while following a similar process to the “real” OPNFV labs. Uses Canonical MaaS and Juju to follow along with capabilities from the JOID project. This option takes a few hours.
1. Static OPNFV trial system already built out and ready to use with openstack and sdn network controller preconfigured. Rapid setup time but quickly falls out of date as upstream projects change. We will update these blueprints once a month or so.

#Getting Started
You will need the following setup before hand to get going:

1. An account on the Ravello cloud. They provide 2880 CPU Hours for free - enough to run 1 machine for 14 days. Make it a big one!
1. Review the notes on the wiki for the OPNFV Academy - it was done using bare metal NUCs from Intel. We will make some adjustments to get it working with the virtual machines provided by Ravello.
1. The files used for this demo (like ssh keys) are available on the following GitHub repo. Setup the github client on your computer.
1. If you don’t have a working git client see this page with steps for Mac, Windows, and Linux: https://help.github.com/articles/set-up-git/ 
1. Clone the repo to your local workstation:  https://github.com/opnfv/opnfv-ravello-demo
1. You can access and manage Ravello using any computer with a web browser. You may want to upload some ISO files or other Virtual Machine image files. Do do this will require installing software on a Linux, Windows, or Mac OS computer. Why not use a linux machine hosted on line?  You can make one on Ravello, Amazon AWS, Microsoft Azure, or google?
  * https://azure.microsoft.com/en-us/pricing/free-trial/
  * https://cloud.google.com/free-trial/
  * https://aws.amazon.com/free/
  * http://www.nephoscale.com
  * many others
1. OPTIONAL: Create a Linux Foundation account (LFID) so you can access the OPNFV tools: https://www.opnfv.org/developers/tools 
1. Sign on to IRC chat.freenode.net and join the #opnfv channel to get help

#OPNFV Demonstration - User Story

1. Create free account on Ravello
1. Setup SSH Key Pair - there are three options here:
  1. add your own to Ravello Library with Import feature (may need to run: ssh-keygen -i -f opnfv-ravello.pub > opnfv-ravello1.pub)
  1. create a new key pair using the Ravello Web UI
  1. import the key from github (https://github.com/opnfv/opnfv-ravello-demo/blob/master/opnfv-ravello.pub)
  ```
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5REVxIbyGbaKZL1hT8zjvW/EoafNbdFx1H7+nnlvutb7PFlOKXHswrcX4bWZttTHnKzt2NWjeRgaX0c4RRMl/0+NLqb82nyBj5AP4V4O/s+5MP+kbmQAVUo1aKfu6Z8jw9VUTc6ztmMGFfLq/+8d79avmvfCKsv1RuPojLRHU8Np0GgUaHFbkIzaFRMMvgSAdsz8etBC/sD5v/PAsnEB6Vdv1QLIdmb7leJaaNDbf9JiTInR5yay3XYZ1y5CDpD4KuODn9nbgfzLh8NMqeQ2O2Noyg1c4yrxXLEXWQwDFRuCmXLPAta1kDOSsYUWGQzSCoQHZeAhp1E/t/ULjMPfV imported-openssh-key
  ```
1. Deploy blueprint as an active application
1. Assign your ssh key to the maas machine in your application
1. Publish the application
1. Identify the ip address for the MaaS server in your application
  ![alt text](https://github.com/opnfv/opnfv-ravello-demo/raw/master/pics/ravello-ip-address.png "Show Ravello IP Address")
1. verify MAAS functionality via web ui - ubuntu/ubuntu
 ![alt text](https://github.com/opnfv/opnfv-ravello-demo/raw/master/pics/opnfv-joid-maas.png "MaaS Web UI")
1. verify MAAS functionality via SSH EXAMPLE: ssh -i path-to-ssh-key.pem ubuntu@maas-opnfvbp3app-gxowv3sb.srv.ravcloud.com
 ![alt text](https://github.com/opnfv/opnfv-ravello-demo/raw/master/pics/ravello-ip-address.png "Show Ravello IP Address")
1. Check that images are imported - http://maas-opnfvbp3app-gxowv3sb.srv.ravcloud.com/MAAS/images/
1. login to OpenStack Horizon Dashboard Web UI  - admin/openstack
 ![alt text](https://github.com/opnfv/opnfv-ravello-demo/raw/master/pics/opnfv-joid-openstack.png "Show OpenStack Horizon Dashboard Web UI")
 
#Environment Preparation
High level overview of steps to follow for building out OPNFV on Ravello.
In this first pass the environment will be built out manually. Additional iterations will bring automation to these steps.  Please help with improving this process. It is intended to be a team effort.

1. Create the virtual machine containers
1. Configure the machines and networking
1. Deploy MaaS and Empty VMs
1. Enter credentials for MaaS Power Driver for Ravello
1. Use MaaS to create Juju bootstrap machine - verify YAML config are correct
  - cd ~/opnfv-ravello-demo/joid/ci
  - ./deploy.sh -o juno -s opencontrail -t nonha -l ravellodemopod
1. Use Juju to perform a deployment of operating systems, openstack, and network controller.
1. Verify the services are operating properly 
  - ssh path-to-key.pem ubuntu@dns-or-ip-address-of-maas-server
  - juju status --format tabular
1. Check that charms are up and running and at the bottom, you have the machines and each one has a number.
1. juju ssh <machine_number>" to ssh into a machine owned by juju
  - "juju ssh 1" -> you can ssh into controller
  - "juju ssh 2" -> you can ssh into compute
1. Run some tests - use the environment
1. Tear it down and repeat - improve through iteration

This github repo contains the files used in the OPNFV demo setup on Ravello Systems hosted cloud infrastructure

See the raw draft of the google notes here: https://docs.google.com/document/d/1ZyMg6yyGAZm-vC29yeKp0_y3EQNaIuEY9JUeJ4dzmGw/edit?usp=sharing
