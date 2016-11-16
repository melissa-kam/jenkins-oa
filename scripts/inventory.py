#!/usr/bin/env python

import click
import os

from subprocess import check_output, CalledProcessError


def run_cmd(command):
    """ Runs a command and returns an array of its results

    :param command: String of a command to run within a shell
    :returns: Dictionary with keys relating to the execution's success
    """
    try:
        ret = check_output(command, shell=True).split('\n')
        return {'success': True, 'return': ret, 'exception': None}
    except CalledProcessError, cpe:
        return {'success': False,
                'return': None,
                'exception': cpe,
                'command': command}


class Device(object):

    def __init__(self, device):
        self.device = device

        self._info = None
        self._hostname = None
        self._private_ip = None

    @property
    def info(self):
        if self._info is None:
            command = 'ot --detailed-information {device}'
            output = run_cmd(command.format(device=self.device))
            self._info = output['return']
        return self._info

    @property
    def hostname(self):
        if self._hostname is None:
            for line in self.info:
                if 'Device:' in line:
                    fqdn = line.split()[-1]
                    self._hostname = fqdn.split('.')[0]
        return self._hostname

    @property
    def private_ip(self):
        if self._private_ip is None:
            for line in self.info:
                if 'Private IP:' in line:
                    self._private_ip = line.split()[-1]
        return self._private_ip


def last_octet(value):
    return value.split('.')[-1]


@click.command()
@click.argument('lab-name', nargs=1)
@click.argument('devices', nargs=-1)
def main(lab_name, devices):
    """ Given a list of device numbers, gather their detailed information

    :param devices: A list of device numbers
    """

    cwd = os.getcwd()
    git_root = run_cmd('git rev-parse --show-toplevel')['return'][0]

    if cwd != git_root:
        click.echo('''
Please execute this script from the root directory of the cloned source code.
Example: /opt/jenkins-oa/, {0}
'''.format(git_root), err=True)
        os._exit(1)

    devices = [Device(number) for number in devices]
    for device in devices:
        with open('inventory/host_vars/{0}.yml'.format(device.hostname), 'w') as fp:
            if any(name in device.hostname for name in ['storage', 'swift']):
                click.echo('Device hostname: {0}'.format(device.hostname))
                zone = click.prompt('Zone number')
                fp.write('''---
ansible_host: {0}
member_number: {1}
zone: {2}
'''.format(device.private_ip, last_octet(device.private_ip), zone))
            else:
                fp.write('''---
ansible_host: {0}
member_number: {1}
'''.format(device.private_ip, last_octet(device.private_ip)))

if __name__ == '__main__':
    main()
