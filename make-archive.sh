#!/bin/bash
set -eux
git submodule update --init --recursive

BASE=/tmp/zeek-nats
DEST=$BASE/zeek-nats-v$(cat VERSION)
TGT=../zeek-nats-v$(cat VERSION).tar.gz
rm -rf $BASE $TGT
mkdir -p $DEST
cp -R $(pwd)/* $DEST
rm -rf $DEST/build
tar cvzf $TGT -C $BASE .
realpath $TGT
