cd ..
rm -rf build
mkdir build
cd build
../configure --with-ipopt64=/usr/local/opt/ipopt
make