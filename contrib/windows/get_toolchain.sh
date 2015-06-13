#!/bin/sh
# This file is a part of Julia. License is MIT: http://julialang.org/license

# download mingw-w64 compilers from opensuse build service, usage:
# ./get_toolchain.sh 64
# (or ./get_toolchain.sh 32)
# depends on curl, xmllint, gunzip, sort -V, sha256sum, and p7zip

# Run in top-level Julia directory
cd `dirname "$0"`/../..
# Stop on error
set -e
bits=$1

case $bits in
  32)
    host=i686-w64-mingw32
    exc=sjlj
    ;;
  64)
    host=x86_64-w64-mingw32
    exc=seh
    ;;
  *)
    echo 'error: run script either as `./get_toolchain.sh 32` or `./get_toolchain.sh 64`' >&2
    exit 1
    ;;
esac
echo "Downloading $host toolchain, check $PWD/get_toolchain.log for full output"
contrib/windows/winrpm.sh http://download.opensuse.org/repositories/windows:/mingw:/win$bits/openSUSE_13.1 \
  "mingw$bits-gcc mingw$bits-gcc-c++ mingw$bits-gcc-fortran \
   mingw$bits-libssp0 mingw$bits-libstdc++6 mingw$bits-libgfortran3" > get_toolchain.log

mingwdir=usr/$host/sys-root/mingw
chmod +x $mingwdir/bin/* $mingwdir/$host/bin/* $mingwdir/libexec/gcc/$host/*/*
mkdir -p usr/bin
for i in gcc_s_$exc-1 ssp-0 stdc++-6 gfortran-3 quadmath-0; do
  cp $mingwdir/bin/lib$i.dll usr/bin
done
for i in gcc g++ gfortran; do
  # this doesn't actually work properly on cygwin yet, since these
  # are mingw compiler executables that don't understand cygwin paths
  cp $mingwdir/bin/$i.exe $mingwdir/bin/$host-$i.exe
done
# copy around binutils and includes
cp $mingwdir/$host/bin/* $mingwdir/bin
cp -r $mingwdir/include $mingwdir/$host
$mingwdir/bin/g++ --version
echo "Toolchain successfully downloaded to $PWD/$mingwdir"
echo "Add toolchain to your path by running \`export PATH=$PWD/$mingwdir/bin:\$PATH\`"
