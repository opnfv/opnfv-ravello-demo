#!/bin/sh -e
exec ./openstack.sh ./config-trusty.sh 2>&1 | tee out.log
