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
package org.jmodelica.junit;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.jmodelica.util.test.TestSpecification;
import org.junit.runner.Description;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class JModelicaRunner extends ParentRunner<ModuleRunner> {

    private List<ModuleRunner> children;

    public JModelicaRunner(Class<?> testClass) throws InitializationError {
        super(testClass);
        if (TestSpecification.class.isAssignableFrom(testClass)) {
            try {
                TestSpecification spec = (TestSpecification) testClass.getDeclaredConstructor().newInstance();
                children = new ArrayList<ModuleRunner>();
                for (File f : spec.getModuleDirs()) {
                    File testDir = new File(f, "src/test");
                    if (testDir.isDirectory() && testDir.listFiles().length > 0) 
                        children.add(new ModuleRunner(spec, f));
                }
            } catch (Exception e) {
                throw new InitializationError(Collections.<Throwable>singletonList(e));
            }
        } else {
            throw new InitializationError("Test class must inherit org.jmodelica.ModelicaTestSpecification.");
        }
    }

    @Override
    public Description describeChild(ModuleRunner mod) {
        return mod.getDescription();
    }

    @Override
    public List<ModuleRunner> getChildren() {
        return children;
    }

    @Override
    public void runChild(ModuleRunner mod, RunNotifier note) {
        mod.run(note);
    }

}
