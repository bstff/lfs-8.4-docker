#!/bin/bash
set -e
echo "Building python.."
echo "Approximate build time: 1.5 SBU"
echo "Required disk space: 371 MB"


tar -xf Python-*.tar.xz -C /tmp/ \
  && mv /tmp/Python-* /tmp/Python \
  && pushd /tmp/Python

sed -i '/def add_multiarch_paths/a \        return' setup.py

./configure --prefix=/tools --without-ensurepip

make

make install

popd \
  && rm -rf /tmp/Python
