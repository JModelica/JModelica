#!/bin/bash

autoscan
mkdir -p m4
# autoreconf --install --force --verbose --warnings=all
autoreconf --install --force
mkdir -p build
cd build

# Detect operating system and distribution
OS="$(uname -s)"
DISTRO=""

case "$OS" in
    Linux*)
        # Assume generic Linux, then try to determine specific distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$NAME
        elif [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            DISTRO=$DISTRIB_ID
        fi
        ;;
    Darwin*)
        DISTRO="macOS"
        ;;
    CYGWIN*)
        DISTRO="Windows (Cygwin)"
        ;;
    MSYS*)
        DISTRO="Windows (MSYS2)"
        ;;
    MINGW*)
        DISTRO="Windows (Mingw-w64)"
        ;;
    FreeBSD*)
        DISTRO="FreeBSD"
        ;;
    *)
        DISTRO="Unknown"
        ;;
esac

echo "Operating System: $OS"
echo "Distribution: $DISTRO"

# Add your conditional logic based on detected $OS and $DISTRO
if [ "$DISTRO" = "macOS" ]; then
    echo "Performing tasks for macOS."
    ../configure --with-ipopt64=/usr/local/opt/ipopt
elif [ "$DISTRO" = "Ubuntu" ]; then
    echo "Performing tasks for Ubuntu."
    ../configure --with-ipopt64=/usr --host=x86_64-linux-gnu 2>&1 | tee configure.log
    make 2>&1 | tee make.log
elif [ "$DISTRO" = "Windows (Cygwin)" ]; then
    echo "Performing tasks for Windows Cygwin."
elif [ "$DISTRO" = "Windows (MSYS2)" ]; then
    echo "Performing tasks for Windows MSYS2."
elif [ "$DISTRO" = "Windows (Mingw-w64)" ]; then
    echo "Performing tasks for Windows Mingw-w64."
elif [ "$DISTRO" = "FreeBSD" ]; then
    echo "Performing tasks for FreeBSD."
else
    echo "Operating system not specifically handled by this script."
fi

cd ..