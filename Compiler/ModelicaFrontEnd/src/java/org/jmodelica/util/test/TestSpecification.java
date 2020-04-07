/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.util.test;

import java.io.File;

public abstract class TestSpecification {

    private File[] dirs;
    private Assert asserter;

    protected TestSpecification(File... dirs) {
        this.dirs = dirs;
    }

    protected TestSpecification(String... dirs) {
        this.dirs = new File[dirs.length];
        for (int i = 0; i < dirs.length; i++)
            this.dirs[i] = new File(dirs[i]);
    }

    public File[] getModuleDirs() {
        return dirs;
    }

    public Assert asserter() {
        if (asserter == null)
            asserter = createAssert();
        return asserter;
    }

    public abstract GenericTestSuite createTestSuite(File testFile);

    protected abstract Assert createAssert();

}
