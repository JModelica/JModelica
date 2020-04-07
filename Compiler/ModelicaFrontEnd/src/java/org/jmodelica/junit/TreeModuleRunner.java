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
import java.util.List;

import org.jmodelica.util.test.TestSpecification;
import org.junit.runner.Description;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class TreeModuleRunner extends ParentRunner<TestTreeRunner> {

    private List<TestTreeRunner> children;
    private Description desc;

    public TreeModuleRunner(TestSpecification spec, UniqueNameCreator nc, File path, String packageName) throws InitializationError {
        super(spec.getClass());
        children = new ArrayList<TestTreeRunner>();
        String name = path.getName();
        desc = Description.createSuiteDescription(name);
        File testDir = new File(path, TreeJModelicaRunner.TEST_SUB_PATH);
        for (File f : testDir.listFiles(TreeJModelicaRunner.MODELICA_FILES)) {
            TestTreeRunner mod = new TestTreeRunner(spec, nc, f, name, packageName);
            children.add(mod);
            desc.addChild(mod.getDescription());
        }
    }

    @Override
    public Description describeChild(TestTreeRunner mod) {
        return mod.getDescription();
    }

    @Override
    public List<TestTreeRunner> getChildren() {
        return children;
    }

    @Override
    public void runChild(TestTreeRunner mod, RunNotifier note) {
        mod.run(note);
    }

    @Override
    public Description getDescription() {
        return desc;
    }

}
