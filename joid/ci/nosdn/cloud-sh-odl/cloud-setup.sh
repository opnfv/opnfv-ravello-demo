#!/bin/sh -e

. ~/admin-openrc

# adjust tiny image
nova flavor-delete m1.tiny
nova flavor-create m1.tiny 1 512 8 1

# import key pair
nova keypair-add --pub-key id_rsa.pub ubuntu-keypair
