/*
 * Copyright (c) 2001-2004 Ant-Contrib project.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package net.sf.antcontrib.logic;

import org.apache.tools.ant.BuildFileTest;

/**
 * Testcase for <foreach>.
 */
public class ForeachTaskTest extends BuildFileTest {

    public ForeachTaskTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/foreach.xml");
    }

    public void tearDown() {
        executeTarget("teardown");
    }

    public void testSimpleList() {
        simpleTest("simpleList");
    }

    public void testDelimiter() {
        simpleTest("delimiter");
    }

    public void testFileset() {
        simpleTest("fileset");
        assertTrue(getLog().indexOf("The nested fileset element is deprectated,"
                                    + " use a nested path instead") > -1);
    }

    public void testFilesetAndList() {
        simpleTest("filesetAndList");
        assertTrue(getLog().indexOf("The nested fileset element is deprectated,"
                                    + " use a nested path instead") > -1);
    }

    public void testNoList() {
        expectSpecificBuildException("noList", "neither list nor fileset",
                                     "You must have a list or path to iterate through");
    }

    public void testNoTarget() {
        expectSpecificBuildException("noTarget", "no target",
                                     "You must supply a target to perform");
    }

    public void testNoParam() {
        expectSpecificBuildException("noParam", "no param",
                                     "You must supply a property name to set on each iteration in param");
    }

    public void testNestedParam() {
        executeTarget("nestedParam");
        assertTrue(getLog().indexOf("Called with param: rincewind") > -1);
    }

    public void testNestedReference() {
        executeTarget("nestedReference");
        assertTrue(getLog().indexOf("Called with param: twoflower") > -1);
    }

    public void testPath() {
        simpleTest("path");
    }

    public void testPathAndList() {
        simpleTest("pathAndList");
    }

    private void simpleTest(String target) {
        executeTarget(target);
        int last = -1;
        for (int i = 1; i < 4; i++) {
            int thisIdx = getLog().indexOf("Called with param: " + i);
            assertTrue(thisIdx > last);
            last = thisIdx;
        }
   }
}
