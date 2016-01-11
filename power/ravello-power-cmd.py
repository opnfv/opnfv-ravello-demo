#!/usr/bin/env python

import argparse
from ravello_sdk import RavelloClient


class RavelloPowerAdapter():

    def __init__(self, user, password, application_name, vm_name):
        self.client = RavelloClient()
        self.client.login(user, password)
        self.application_name = application_name
        self.vm_name = vm_name

    def _get_application_id(self):
        for app in self.client.get_applications():
            if app['name'] == self.application_name:
                return app['id']
        return None

    def _get_vm_id(self):
        app_id = self._get_application_id()
        for vm in self.client.get_vms(app_id):
            if vm['name'] == self.vm_name:
                return vm['id']
        return None

    def get_vm_state(self):
        return self.client.get_vm_state(self._get_application_id(),
                                        self._get_vm_id())

    def power_on_vm(self):
        vm_state = self.get_vm_state()
        if vm_state in ['STARTED', 'STARTING']:
            return
        elif vm_state == 'STOPPED':
            self.client.start_vm(self._get_application_id(), self._get_vm_id())
        else:
            raise Exception("Error when powering on the VM. Cannot handle "
                            "VM state: '%s'" % vm_state)

    def power_off_vm(self):
        vm_state = self.get_vm_state()
        if vm_state in ['STOPPED', 'STOPPING']:
            return
        if vm_state == 'STARTED':
            self.client.poweroff_vm(self._get_application_id(),
                                    self._get_vm_id())
        else:
            raise Exception("Error when powering off the VM. Cannot handle "
                            "VM state: '%s'" % vm_state)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--ravello-user", dest="user", type=str,
                        help="Ravello user", required=True)
    parser.add_argument("-p", "--ravello-password", dest="password", type=str,
                        help="Ravello user password", required=True)
    parser.add_argument("-a", "--ravello-application-name",
                        dest="application_name", type=str,
                        help="Ravello application name", required=True)
    parser.add_argument("-v", "--ravello-vm-name", dest="vm_name",
                        type=str, help="Ravello VM name", required=True)
    parser.add_argument(type=str, help="VM power command. Valid options: "
                        "'on', 'off', 'status'", dest="new_state",
                        choices=['on', 'off', 'status'])
    options = parser.parse_args()

    adapter = RavelloPowerAdapter(user=options.user, password=options.password,
                                  application_name=options.application_name,
                                  vm_name=options.vm_name)
    if options.new_state == 'on':
        adapter.power_on_vm()
    elif options.new_state == 'off':
        adapter.power_off_vm()
    elif options.new_state == 'status':
        print adapter.get_vm_state()
