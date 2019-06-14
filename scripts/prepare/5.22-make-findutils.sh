#!/bin/bash
set -e
echo "Building findutils.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 35 MB"

# 5.22. Findutils package contains programs to find files. These programs are
# provided to recursively search through a directory tree and to create,
# maintain, and search a database (often faster than the recursive find,
# but unreliable if the database has not been recently updated).

tar -xf findutils-*.tar.gz -C /tmp/ \
  && mv /tmp/findutils-* /tmp/findutils \
  && pushd /tmp/findutils

sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h

./configure --prefix=/tools

make

make install

# cleanup
popd \
  && rm -rf /tmp/findutils
