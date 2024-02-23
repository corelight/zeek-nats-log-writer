#!/bin/bash
#
# Fetch NATS and copy executables into $1
set -eux

mkdir -p $1

NATS_ARCH=amd64

NATS_SERVER_VERSION=2.10.11
NATS_SERVER_SHA256=9a0e09abb9fa35d056902070496764517a8f42f4d77220abf9f185e3f502b2e5
NATS_SERVER_URL=https://github.com/nats-io/nats-server/releases/download/v${NATS_SERVER_VERSION}/nats-server-v${NATS_SERVER_VERSION}-linux-${NATS_ARCH}.zip

curl -sSf -L ${NATS_SERVER_URL} -o nats-server.zip
sha256sum nats-server.zip
echo "${NATS_SERVER_SHA256} nats-server.zip" | sha256sum --check || exit 1
unzip ./nats-server.zip
cp -v ./nats-server-v${NATS_SERVER_VERSION}*/nats-server $1

NATSCLI_VERSION=0.1.3
NATSCLI_SHA256=7c94cbee0295a828615fb4e0ffa730c3939fc3139db085a4e158592abb4bd5f0
NATSCLI_URL=https://github.com/nats-io/natscli/releases/download/v${NATSCLI_VERSION}/nats-${NATSCLI_VERSION}-linux-${NATS_ARCH}.zip

curl -sSf -L ${NATSCLI_URL} -o nats.zip
sha256sum nats.zip
echo "${NATSCLI_SHA256} nats.zip" | sha256sum --check || exit 1
unzip ./nats.zip
cp -v ./nats-${NATSCLI_VERSION}-*/nats $1
