#!/usr/bin/env python
# -*- coding: latin-1 -*-
#    Copyright (C) 2009 Modelon AB
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


# see 'help(distutils.version)'

from distutils.core import setup, Distribution
import os, os.path 
import sys
import pysvn
import string

def svnversion(path, committed = False):
    """
    This function provides the functionality of the svnversion program.
    
    See Also
    ========
    http://svnbook.red-bean.com/en/1.1/re57.html
    """
    client = pysvn.Client()
    try:
        status = client.status(path)
    except pysvn.ClientError:
        return 'exported'
    switched = False
    modified = False
    hi_rev = -1
    lo_rev = sys.maxint
    for s in status:
        if s.is_versioned and s.entry:
            # must test s.entry since ignored files have is_versioned = True but entry = None...
            switched = switched or s.is_switched
            modified = modified or (s.text_status == pysvn.wc_status_kind.modified)
            if committed:
                hi_rev = max(hi_rev, s.entry.commit_revision.number)
                lo_rev = min(lo_rev, s.entry.commit_revision.number)
            else:
                hi_rev = max(hi_rev, s.entry.revision.number)
                lo_rev = min(lo_rev, s.entry.revision.number)
    if lo_rev < hi_rev:
        s = '%d:%d' % (lo_rev,hi_rev)
    elif lo_rev == hi_rev:
        s = '%d' % hi_rev
    else:
        raise Error('Could not figure out revision info')
    if modified:
        s = s + 'M'
    if switched:
        s = s + 'S'
    return s


def get_package_dir (package_dir, package):
    # from distutils.commands.build_py
    """Return the directory, relative to the top of the source
       distribution, where package 'package' should be found
       (at least according to the 'package_dir' option, if any)."""

    path = string.split(package, '.')

    if not package_dir:
        if path:
            return apply(os.path.join, path)
        else:
            return ''
    else:
        tail = []
        while path:
            try:
                pdir = package_dir[string.join(path, '.')]
            except KeyError:
                tail.insert(0, path[-1])
                del path[-1]
            else:
                tail.insert(0, pdir)
                return apply(os.path.join, tail)
        else:
            # Oops, got all the way through 'path' without finding a
            # match in package_dir.  If package_dir defines a directory
            # for the root (nameless) package, then fallback on it;
            # otherwise, we might as well have not consulted
            # package_dir at all, as we just use the directory implied
            # by 'tail' (which should be the same as the original value
            # of 'path' at this point).
            pdir = package_dir.get('')
            if pdir is not None:
                tail.insert(0, pdir)

            if tail:
                return apply(os.path.join, tail)
            else:
                return ''

# get_package_dir ()
    

class svnDistribution(Distribution):
    """
    This subclass of the Distribution class is Subversion aware and
    adds a version file with committed revision range to each package folder.
    """
    def __init__(self, attrs):
        package_dir = attrs['package_dir']
        packages = attrs['packages']
        for package in packages:
            pdir = get_package_dir(package_dir,package)
            revision = svnversion(os.path.join(sys.path[0],pdir), committed = True)
            #        would not follow revision syntax rules:
            #        attrs['version'] = revision
            try:
                # then try to create a user specified version file
                filename, format  = attrs['revision_file']
                file(os.path.join(sys.path[0],pdir,filename),'w').write(format % revision)
            except KeyError:
                # in case a 'revision_file' attribute was not set, do nothing
                pass
        # the parent class does not know about 'version_file', so delete it
        del attrs['revision_file']
        Distribution.__init__(self, attrs)



setup(name='jmodelica',
      version = '1.0a1',
      description = 'JModelica.org Python packages', 
      maintainer = 'Modelon AB',
      maintainer_email = 'info@modelon.se',
      url = 'http://www.jmodelica.org',
      #download_url = 'https://www.jmodelica.org',
      packages = ['jmodelica',
                  'jmodelica.examples',
                  'jmodelica.examples.cstr',
                  'jmodelica.examples.parameter_estimation_1',
                  'jmodelica.examples.pendulum',
                  'jmodelica.examples.pendulum_no_opt',
                  'jmodelica.examples.vdp',
                  'jmodelica.examples.vdp_minimum_time',
                  'jmodelica.optimization',
                  'jmodelica.tests'
                  ],
      package_data = {'jmodelica.examples.cstr': ['*.mo'],
                  'jmodelica.examples.parameter_estimation_1': ['*.mo'],
                  'jmodelica.examples.pendulum': ['*.mo'],
                  'jmodelica.examples.pendulum_no_opt': ['*.mo'],
                  'jmodelica.examples.vdp': ['*.mo'],
                  'jmodelica.examples.vdp_minimum_time': ['*.mo'],
                  'jmodelica.optimization': ['*.mo']
                  },
      package_dir = {'':'src'},
      requires = ['numpy', 'scipy', 'matplotlib', 'win32api', 'lxml', 'jpype'],
      provides = 'jmodelica',
      license = 'GPLv3',
      # the following attributes are used with the version number feature...
      revision = 'default',
      distclass = svnDistribution,
      # the version_file attribute is understood by the svnDistribution class
      # and provides a way for the version information to be accessible by 
      # the module after it is installed
      revision_file = ('_revision.py', \
        '# This file is generated automatically\nrevision = "%s"')
      )

