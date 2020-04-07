#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

from distutils.core import setup, Extension
import os as O
import sys as S

NAME = "PyJMI"
AUTHOR = "Modelon AB"
AUTHOR_EMAIL = ""
VERSION = "trunk"
LICENSE = "GPL"
URL = "http://www.jmodelica.org"
DOWNLOAD_URL = "http://www.jmodelica.org/page/12"
DESCRIPTION = "A package for working with dynamic models compliant with the JModelica.org model interface."
PLATFORMS = ["Linux", "Windows", "MacOS X"]
CLASSIFIERS = [ 'Programming Language :: Python',
                'Operating System :: MacOS :: MacOS X',
                'Operating System :: Microsoft :: Windows',
                'Operating System :: Unix']

LONG_DESCRIPTION = """

"""

sep = O.path.sep

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
      package_dir = {'pyjmi':'pyjmi','pyjmi.common':'common'},
      packages=['pyjmi','pyjmi.optimization','pyjmi.initialization','pyjmi.examples','pyjmi.common','pyjmi.common.plotting','pyjmi.log','pyjmi.optimization.mhe'],
      package_data = {'pyjmi':['examples'+sep+'files'+sep+'*.*','examples'+sep+'files'+sep+'DISTLib backup'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Include'+sep+'*.*','examples'+sep+'files'+sep+'Resources'+sep+'src'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Library'+sep+'darwin32'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Library'+sep+'darwin64'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Library'+sep+'linux32'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Library'+sep+'linux64'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Library'+sep+'win32'+sep+'*.*',
                               'examples'+sep+'files'+sep+'Resources'+sep+'Library'+sep+'win64'+sep+'*.*',
                               'examples'+sep+'files'+sep+'FMUS'+sep+'*.*',]},
      script_args=copy_args
      )
