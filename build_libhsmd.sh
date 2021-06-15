#!/bin/bash
# Run with:
#    docker run --rm -v $PWD:/io quay.io/pypa/manylinux2014_x86_64 /io/build_libhsmd.sh
set -e
# Manylinux, openblas version, lex_ver, Python versions
source /io/common_vars.sh
source ${IO_PATH}/multibuild/library_builders.sh
PYTHON_VERSIONS="3.6 3.7 3.8 3.9"
LIBHSMD_VERSION="${LIBHSMD_VERSION:-0.10.0.post1}"

LIBSODIUM_VERSION="${LIBSODIUM_VERSION:-1.0.16}"
export BUILD_PREFIX="${BUILD_PREFIX:-/usr/local}"
ln -s /opt/python/cp36-cp36m/bin/python /usr/bin/python3 || true

cd /io

rm_mkdir unfixed_wheels

cd /io/libhsmd-${LIBHSMD_VERSION}

rm -rf src || true
git clone --depth=1 --recursive --branch=libhsmd-python https://github.com/cdecker/lightning.git src

sed -i 's/ MAP_ANON / 0 /g' src/external/libwally-core/src/ctest/test_psbt_limits.c
yum install -y gmp-devel zlib-devel valgrind-devel

for PYTHON in ${PYTHON_VERSIONS}; do
    PY="$(cpython_path $PYTHON)/bin/python"
    $PY setup.py bdist_wheel
done

repair_wheelhouse /io/libhsmd-${LIBHSMD_VERSION}/dist $WHEELHOUSE
