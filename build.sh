aclocal
autoreconf --install --force -W all
autoconf
automake --add-missing
mkdir build
cd build
../configure --with-ipopt64=/usr/local/opt/ipopt
make
