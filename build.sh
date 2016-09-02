#!/usr/bin/env bash

echo "Building Unison Container"
docker build --tag=unison .

echo "Copying unison binaries"
mkdir -p build
docker run --rm -v `pwd`/build:/build unison cp /usr/local/bin/unison /usr/local/bin/unison-fsmonitor /build

#
# Create the archive
#
cd build
mkdir -p usr/local/bin
mv unison unison-fsmonitor usr/local/bin

version="$(docker run --rm unison /bin/bash -c "unison -version | sed -e 's| version |-|g'")"

echo "Creating ${version}-linux-x86_64.tar.gz"

tar czf ../"${version}-linux-x86_64.tar.gz" usr
