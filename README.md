Build instructions for the JModelica.org project.

Please read all parts of this document carefully before starting the
installation procedure.

Windows users are recommended to use the JModelica.org-SDK installer which
contains all the tools necessary to build the platform. If the
JModelica.org-SDK is used to build the platform, please see the User's Guide
at http://www.jmodelica.org for building instructions.

This file describes the build procedure for Linux systems.

0. Requirements.

In order to compile JModelica.org you will need a Unix-like environment.
Depending on your operating system, different procedures are required.

The following tools need to be installed:

- The gcc compiler suite
- Subversion
- Apache Ant
  - on Ubuntu `sudo apt install ant`
- Cmake (for Sundials)
  - on Ubuntu `sudo apt-get install cmake`
- SWIG
- Java development kit
  - on Ubuntu `sudo apt install default-jdk`
- Python 2.7 (with development headers)
  - on Ubuntu 
    - `sudo apt install python2` 
    - `sudo apt install python-pip`
    - `python2 -m pip install virtualenv`
    - Use `virtualenv` to create a virtual environment with Python 2 isolated from your system's default Python `~/.local/bin/virtualenv --python=/usr/bin/python2 jmodelica_env` and then activate the virtual environment to use the isolated Python installation within it `source jmodelica_env/bin/activate`
    - then `python2 -m pip install numpy` and `python2 -m pip install numpy`

The list of required Python packages can be found in the User's Guide.
It is available at http://www.jmodelica.org/page/236.

Note that some of the Python packages are needed also to build JModelica.org. Note that
on Ubuntu it is required to install Python with headers (python-dev) while the headers
usually follow a normal installation on Windows.

The dependencies can be installed manually or through a package manager such as apt-get
on Ubuntu systems.

1. Get JModelica.org

Check out a working copy of JModelica.org:

> svn co https://svn.jmodelica.org/trunk JModelica

Make sure that the full path to the directory where you check out JModelica.org
does not contain any spaces nor ~ character.

2. Get Ipopt

Download Ipopt (version 3.9 or later) from https://projects.coin-or.org/Ipopt.
Unzip the tar-ball and put in a directory that does not hold any spaces nor ~
character in its path. Build the package according to its INSTALL file. Make
sure to run

> make install

on macOS you may install via HomeBrew:

> brew install ipopt

which usually installs in the `/usr/local/opt/ipopt` directory, To check the installation path you may run

> brew --prefix ipopt

3. Configure

Run the configure script. It is recommended that you create a new
directory for building the platform

> cd JModelica
> chmod +x ./configure
> chmod +x ./run_java.sh
> chmod +x ./config.sub
> mkdir build
> cd build
> ../configure --with-ipopt=/path/to/ipopt-install-dir \

on macOS:

> ../configure --with-ipopt64=/usr/local/opt/ipopt

If you have installed IPOPT via `sudo apt install coinor-libipopt-dev` on Ubuntu, then:

> ../configure --with-ipopt64=/usr

You may want to give additional arguments to configure.
Type configure --help for information. By default, the
installation directory (--prefix) is set to /usr/local/jmodelica -
use the --prefix argument to change the default location (recommended).

4. Build and install

In order to build, type

> make

which will build the JModelica.org software components and in addition build
the SUNDIALS integrator suite. Note that you may need to set JAVA_HOME to the
path of a Java development kit installation. In order to install, type

> make install

which will render the directories 'lib' and 'include' to be created in the
installation directory and the corresponding libraries and directories and
header files will be copied. In addition, templates, XML schemas, third party
dependencies and makefiles used to build the generated C code are copied into
the installation directory. Also, the Python code is copied into the
installation directory.

In order to also build and install CasADi, use the command

> make install_casadi

5. Generate documentation.

The command

> make docs

will generate documentation in the 'doc' directory. The generated documentation
is also available at www.jmodelica.org, where nightly generated docs are
published.

6. Running JModelica.org from Python

JModelica.org supports the following environment variables:

- JMODELICA_HOME containing the path to the JModelica.org installation
  directory (again, without spaces or ~ in the path).
- PYTHONPATH containing the path to the directory $JMODELICA_HOME/Python.
- JAVA_HOME containing the path to a Java JRE or SDK installation.
- IPOPT_HOME containing the path to an Ipopt installation directory.
- LD_LIBRARY_PATH containing the path to the $IPOPT_HOME/lib directory
  (Linux only.)
- MODELICAPATH containing a sequence of paths representing directories
  where Modelica libraries are located, separated by colons.

We recommend using the scripts:

$JMODELICA_HOME/bin/jm_ipython.sh

or

$JMODELICA_HOME/bin/jm_python.sh

to start IPython (recommended) or Python. In these scripts, the default values
of the environment variables are set to match your particular installation
configuration.

The default settings can be overridden either by setting one of the supported
environment variables globally or by adding a local startup.py file located in
the directory $HOME/jmodelica.org and change a variable there.

7. Test the distribution

Run

> make test

to run the JModelica.org test suites.

To test that the Python packages are working, start Python or IPython. Type

> import pyjmi.examples.cstr as cstr
> cstr.run_demo()

You should now see the output of Ipopt and windows containing plots showing the
optimization results should be opened.

8. Check Python packages

There is a function in the jmodelica package to check the status of the Python
packages required by JModelica. Type

> import pymodelica
> pymodelica.check_packages()

This will list all required packages, if they are installed and package version
(if available). Compare your status output to the list of required packages
which can be found in this file under: 'Running JModelica.org from Python' or
on the web site www.jmodelica.org.
