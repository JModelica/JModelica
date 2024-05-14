rm -rf build
rm -rf m4
mkdir m4
autoreconf -fi
mkdir build
cd build
../configure --with-ipopt64=/usr 2>&1 | tee configure.log
# ../configure --enable-ninja --with-ipopt64=/usr 2>&1 | tee configure.log
make 2>&1 | tee make.log
# ninja 2>&1 | tee make.log