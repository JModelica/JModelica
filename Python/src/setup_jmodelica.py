#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

from distutils.core import setup, Extension
import sys as S
import os as O

NAME = "JModelica.org"
AUTHOR = "Modelon AB"
AUTHOR_EMAIL = ""
VERSION = "trunk"
LICENSE = "GPL"
URL = "http://www.jmodelica.org"
DOWNLOAD_URL = "http://www.jmodelica.org/page/12"
DESCRIPTION = "A package for compiling Modelica / Optimica models into FMUs."
PLATFORMS = ["Linux", "Windows", "MacOS X"]
CLASSIFIERS = [ 'Programming Language :: Python',
                'Operating System :: MacOS :: MacOS X',
                'Operating System :: Microsoft :: Windows',
                'Operating System :: Unix']

LONG_DESCRIPTION = """

"""

# Fix path sep
copy_args=S.argv[1:]

for x in S.argv[1:]:
    if not x.find('--prefix'):
        copy_args[copy_args.index(x)] = x.replace('/',O.sep)
        
setup(name=NAME,
      version=VERSION,
      license=LICENSE,
      description=DESCRIPTION,
      long_description=LONG_DESCRIPTION,
      author=AUTHOR,
      author_email=AUTHOR_EMAIL,
      url=URL,
      download_url=DOWNLOAD_URL,
      platforms=PLATFORMS,
      classifiers=CLASSIFIERS,
      package_dir = {'jmodelica':'jmodelica','jmodelica.common':'common'},
      packages=['jmodelica','jmodelica.common','jmodelica.common.plotting'],
      script_args=copy_args
      )
