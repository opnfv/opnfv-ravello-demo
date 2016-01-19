#!/bin/sh -e
exec ./openstack.sh ./config-trusty-juno.sh 2>&1 | tee out.log
