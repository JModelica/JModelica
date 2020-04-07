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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmodelica.util.test.GenericTestCase;
import org.jmodelica.util.test.GenericTestSuite;
import org.jmodelica.util.test.TestSpecification;
import org.junit.runner.Description;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class ModelicaFileRunner extends ParentRunner<GenericTestCase> {

    private GenericTestSuite suite;
    private Description desc;
    private TestSpecification spec;
    private Map<String,Description> childDesc = new HashMap<>();

    public ModelicaFileRunner(TestSpecification spec, File testFile) throws InitializationError {
        super(spec.getClass());
        suite = spec.createTestSuite(testFile);
        desc = Description.createSuiteDescription(testFile.getName());
        this.spec = spec;
        for (GenericTestCase test : suite.getAll()) {
            String descStr = String.format("%s(%s)", test.getName(), testFile);
            Description chDesc = Description.createSuiteDescription(descStr);
            childDesc.put(test.getName(), chDesc);
            desc.addChild(chDesc);
        }
    }

    @Override
    public Description describeChild(GenericTestCase test) {
        return childDesc.get(test.getName());
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<GenericTestCase> getChildren() {
        return (List<GenericTestCase>) suite.getAll();
    }

    @Override
    public void runChild(GenericTestCase test, RunNotifier note) {
        Description d = describeChild(test);
        note.fireTestStarted(d);
        try {
            test.testMe(spec.asserter());
        } catch (Throwable e) {
            note.fireTestFailure(new Failure(d, e));
        }
        note.fireTestFinished(d);
    }

    @Override
    public Description getDescription() {
        return desc;
    }

}
