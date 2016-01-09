#!/bin/sh -e
exec ./openstack.sh ./config-precise.sh 2>&1 | tee out.log
