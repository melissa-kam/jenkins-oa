#!/usr/bin/env python

import argh
import json

from subprocess import check_call, CalledProcessError


def run_cmd(command):
    """ Runs a command and returns an array of its results

    :param command: String of a command to run within a shell
    :returns: Dictionary with keys relating to the execution's success
    """
    try:
        ret = check_call(command, shell=True)
        return {'success': True, 'return': ret, 'exception': None}
    except CalledProcessError, cpe:
        return {'success': False,
                'return': None,
                'exception': cpe,
                'command': command}


def main(inventory=None):
    """ Given an inventory file, place SSH keys onto
        designated hosts

    :param inventory: Path to a inventory file with credentials
    """

    with open(inventory, 'r') as fp:
        credentials = json.load(fp)

        for host in credentials.keys():
            ip = credentials.get(host)['ip']
            username = credentials.get(host)['username']
            password = credentials.get(host)['password']

            command = ('sshpass -p {password} ssh-copy-id'
                       ' -o UserKnownHostsFile=/dev/null'
                       ' -o StrictHostKeyChecking=no {username}@{host}')
            run_cmd(command.format(username=username,
                                   password=password,
                                   host=ip))

argh.dispatch_command(main)
