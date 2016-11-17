#!/usr/bin/env python
import datetime
import dateutil.parser
import os

from novaclient import client

SLAVE_NAME = os.environ.get('SLAVE_NAME', 'Jenkins-OM-AIO')
NUM_HRS = os.environ.get('NUM_HRS', 6)

USERNAME = os.environ['OS_USERNAME']
API_KEY = os.environ['OS_PASSWORD']
TENANT_ID = os.environ['OS_TENANT_NAME']
AUTH_URL = os.environ['OS_AUTH_URL']
REGION_NAME = os.environ['OS_REGION_NAME']


def main():
    nova = client.Client(2, USERNAME, API_KEY, TENANT_ID, AUTH_URL,
                         region_name=REGION_NAME)

    servers = nova.servers.list()
    for server in servers:
        created = dateutil.parser.parse(server.created)
        now_local_tz = datetime.datetime.now(created.tzinfo)
        num_hrs_ago = now_local_tz - datetime.timedelta(hours=int(NUM_HRS))

        old = created < num_hrs_ago
        error = server.status == 'Error'

        if (SLAVE_NAME in server.name and (error or old)):
            msg = "Deleting server: {0}; Error: {1}; Older than ({2} hrs): {3}"
            print(msg.format(server.name, error, NUM_HRS, old))
            server.delete()


if __name__ == "__main__":
    main()
