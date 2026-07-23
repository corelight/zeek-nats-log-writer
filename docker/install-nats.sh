#!/bin/bash
#
# Fetch NATS and copy executables into $1
set -eux

NATS_SERVER_VERSION=2.14.3
NATS_SERVER_AMD64_SHA256=f3d0c820c749f81d717310fb00d4903919e70e3e66b268bd352a088b9788eb93
NATS_SERVER_ARM64_SHA256=1759b6a0ddebade9471b7c02891dfaa8c73b526c6f3ce391d4e21ec3eceffab8

NATSCLI_VERSION=0.4.0
NATSCLI_AMD64_SHA256=8dbd437c826b953dbd7432cf890ef22ba3c33dccc3dce5e71b3e8d055427849c
NATSCLI_ARM64_SHA256=9ce0c8a6653cd697d0b32687fcb53b59c13a2ad7a6ade7af8ad8a1c0f7357a87

ARCH="$(uname -m)"
if [ "$ARCH" == "x86_64" ]; then
    NATS_ARCH=amd64
    NATS_SERVER_SHA256=$NATS_SERVER_AMD64_SHA256
    NATSCLI_SHA256=$NATSCLI_AMD64_SHA256
elif [ "$ARCH" == "aarch64" ]; then
    NATS_ARCH=arm64
    NATS_SERVER_SHA256=$NATS_SERVER_ARM64_SHA256
    NATSCLI_SHA256=$NATSCLI_ARM64_SHA256
else
    echo "Unhandled ARCH=${ARCH}" >&2
    exit 1
fi

NATS_SERVER_URL=https://github.com/nats-io/nats-server/releases/download/v${NATS_SERVER_VERSION}/nats-server-v${NATS_SERVER_VERSION}-linux-${NATS_ARCH}.tar.gz
NATSCLI_URL=https://github.com/nats-io/natscli/releases/download/v${NATSCLI_VERSION}/nats-${NATSCLI_VERSION}-linux-${NATS_ARCH}.zip

mkdir -p $1

curl -sSf -L ${NATS_SERVER_URL} -o nats-server.tar.gz
sha256sum nats-server.tar.gz
echo "${NATS_SERVER_SHA256} nats-server.tar.gz" | sha256sum --check || exit 1
tar xvf nats-server.tar.gz
cp -v ./nats-server-v${NATS_SERVER_VERSION}*/nats-server $1


curl -sSf -L ${NATSCLI_URL} -o nats.zip
sha256sum nats.zip
echo "${NATSCLI_SHA256} nats.zip" | sha256sum --check || exit 1
unzip ./nats.zip
cp -v ./nats-${NATSCLI_VERSION}-*/nats $1
