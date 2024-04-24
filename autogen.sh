autoscan
autoreconf --install --force --verbose --warnings=all
mkdir -p build
cd build
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # ...
        ../configure --with-ipopt64=/usr --host=x86_64-linux-gnu
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ../configure --with-ipopt64=/usr/local/opt/ipopt
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
else
        # Unknown.
fi

make