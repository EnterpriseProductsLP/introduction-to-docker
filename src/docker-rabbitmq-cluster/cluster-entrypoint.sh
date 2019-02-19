#!/bin/bash

set -e

# Start RMQ from entry point.
# This will ensure that environment variables passed
# will be honored
/usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached

# Do the cluster dance
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq1
rabbitmqctl start_app
rabbitmqctl set_policy --priority 0 --apply-to "exchanges" ha-exchanges ".*" '{"ha-mode": "all"}'
rabbitmqctl set_policy --priority 0 --apply-to "queues" ha-queues ".*" '{"ha-mode": "all"}'

# Stop the entire RMQ server. This is done so that we
# can attach to it again, but without the -detached flag
# making it run in the forground
rabbitmqctl stop

# Wait a while for the app to really stop
sleep 2s

# Start it
rabbitmq-server
