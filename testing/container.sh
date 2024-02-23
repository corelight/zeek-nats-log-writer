#!/bin/bash
#
# Helper script to run the tests in container, starting up the nats-server
set -x
cd $(dirname "$0")

type nats-server
nats-server -js &
NATS_PID=$!

btest -c btest.cfg -A -d
RESULT=$?

kill $NATS_PID
wait $NATS_PID

exit $RESULT
