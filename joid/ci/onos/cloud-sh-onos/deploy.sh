#!/bin/sh -e
exec ./openstack.sh ./config.sh 2>&1 | tee out.log
