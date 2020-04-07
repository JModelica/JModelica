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
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmodelica.util.test.GenericTestCase;
import org.jmodelica.util.test.GenericTestTreeNode;
import org.jmodelica.util.test.TestSpecification;
import org.jmodelica.util.test.TestTree;
import org.junit.runner.Description;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.ParentRunner;
import org.junit.runners.model.InitializationError;

public class TestTreeRunner extends ParentRunner<GenericTestTreeNode> {

    private Map<String,Description> caseDesc;
    private Map<String,TestTreeRunner> runners;
    private List<GenericTestTreeNode> children;
    private Description desc;
    private TestSpecification spec;
    private File testFile;
    private Map<String,String> modelNames;
    private static boolean outputFailing = !System.getProperty("output_failing", "").equals("");
    private static String outputFailingFile = System.getProperty("output_failing", "");
    private static boolean appendMode;

    public TestTreeRunner(
            TestSpecification spec, UniqueNameCreator nc, File testFile, String parentName, String packageName) 
                    throws InitializationError {
        this(spec, nc, null, parentName, packageName, testFile);
    }

    public TestTreeRunner(
            TestSpecification spec, UniqueNameCreator nc, TestTree tree, String parentName, String packageName, File testFile) 
                    throws InitializationError {
        super(spec.getClass());
        String name;
        if (tree == null) {
            name = testFile.getName();
            tree = spec.createTestSuite(testFile).getTree();
            if (tree == null) {
                throw new InitializationError("Test file '" + name
                        + "' does not contain any tests. Note: The declared package name must match the file name");
            }
        } else {
            name = tree.getName();
        }
        String fullName = String.format("%s.%s", parentName, name);
        desc = Description.createSuiteDescription(nc.makeUnique(name));
        this.spec = spec;
        this.testFile = testFile;
        caseDesc = new HashMap<String,Description>();
        runners = new HashMap<String,TestTreeRunner>();
        children = new ArrayList<GenericTestTreeNode>();
        modelNames = new HashMap<String,String>();
        int i = 0;
        for (GenericTestTreeNode test : tree) {
            i++;
            Description chDesc = null;
            GenericTestTreeNode subTest = null;
            String testName = test.getName();
            if (testName == null) {
                testName = String.format("[%d]", i);
            }
            if (test instanceof TestTree) {
                TestTree subTree = (TestTree) test;
                if (subTree.numChildren() == 1) {
                    subTest = subTree.iterator().next();
                }
                if (subTest != null && !(subTest instanceof TestTree)) {
                    test = subTest;
                } else {
                    TestTreeRunner runner = new TestTreeRunner(spec, nc, subTree, fullName, packageName, testFile);
                    runners.put(subTree.getName(), runner);
                    chDesc = runner.getDescription();
                }
            } 
            if (!(test instanceof TestTree)) {
                String maybeSubTestName = test.getName();
                // TODO: Upgrade JUnit version, then use createTestDescription(String, String) instead
                String descStr = String.format("%s(%s)", nc.makeUnique(testName), packageName);
                chDesc = Description.createSuiteDescription(descStr);
                caseDesc.put(maybeSubTestName, chDesc);
                if(outputFailing) {
                    if(name.equals(testFile.getName())) { //Top-level test
                        modelNames.put(maybeSubTestName, testName);
                    } else {
                        modelNames.put(maybeSubTestName, String.format("%s.%s", name, testName));
                    }
                }
            }
            desc.addChild(chDesc);
            children.add(test);
        }
    }

    @Override
    protected Description describeChild(GenericTestTreeNode test) {
        if (test instanceof TestTree) {
            return runners.get(test.getName()).getDescription();
        } else {
            return caseDesc.get(test.getName());
        }
    }

    @Override
    protected List<GenericTestTreeNode> getChildren() {
        return children;
    }

    @Override
    protected void runChild(GenericTestTreeNode test, RunNotifier note) {
        if (test instanceof TestTree) {
            runners.get(test.getName()).run(note);
        } else {
            Description d = caseDesc.get(test.getName());
            if(((GenericTestCase) test).shouldBeIgnored()) {
                note.fireTestIgnored(d);
            } else {
                note.fireTestStarted(d);
                try {
                    ((GenericTestCase) test).testMe(spec.asserter());
                } catch (Throwable e) {
                    note.fireTestFailure(new Failure(d, e));
                    if(outputFailing) {
                        try(PrintWriter pw = new PrintWriter(new FileOutputStream(new File(outputFailingFile), appendMode))) {
                            pw.println(testFile.getAbsolutePath()+","+modelNames.get(test.getName()));
                            appendMode = true;
                        } catch (FileNotFoundException e1) {
                            e1.printStackTrace();
                        }
                    }
                }
                note.fireTestFinished(d);
            }
        }
    }

    @Override
    public Description getDescription() {
        return desc;
    }

}
