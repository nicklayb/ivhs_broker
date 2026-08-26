#!/bin/sh
set -e

BINARY_PATH=/opt/rel/ivhs_broker/bin/ivhs_broker

exec $BINARY_PATH "$@"
