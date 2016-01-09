#!/usr/bin/env python
"""
MAAS Deployment Tool
"""
import copy
import itertools
import json
import logging
import os
import sys
import time
import yaml

from maas_deployer.vmaas.util import CONF as cfg

from maas_deployer.vmaas import (
    vm,
    util,
    template,
)


# Setup logging before imports
logging.basicConfig(
    filename='maas_deployer.log',
    level=logging.DEBUG,
    format=('%(asctime)s %(levelname)s '
            '(%(funcName)s) %(message)s'))

log = logging.getLogger('vmaas.main')
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
handler.setFormatter(formatter)
log.addHandler(handler)

def main():

    maasipaddress = str(sys.argv); 

    script = """
        sudo apt-get install git -y 
        git clone https://gerrit.opnfv.org/gerrit/joid
        juju init -y
        cp /home/juju/.juju/environments.yaml ~/.juju/
        cd joid/ci/
        ./deploy.sh 
        """ 
    try:
        util.exec_script_remote('ubuntu', maasipaddress[1], script)
    except:
        # Remove console handler to avoid displaying the exception twice
        log.removeHandler(handler)
        log.exception("MAAS deployment failed.")
        raise

if __name__ == '__main__':
    main()
