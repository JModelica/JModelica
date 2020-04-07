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
 * Testcase for <switch>.
 */
public class SwitchTest extends BuildFileTest {

    public SwitchTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/switch.xml");
    }

    public void testNoValue() {
        expectSpecificBuildException("noValue", "no value",
                                     "Value is missing");
    }        
        
    public void testNoChildren() {
        expectSpecificBuildException("noChildren", "no children",
                                     "No cases supplied");
    }

    public void testTwoDefaults() {
        expectSpecificBuildException("twoDefaults", "two defaults",
                                     "Cannot specify multiple default cases");
    }

    public void testNoMatch() {
        expectSpecificBuildException("noMatch", "no match",
                                     "No case matched the value foo"
                                     + " and no default has been specified.");
    }

    public void testCaseNoValue() {
        expectSpecificBuildException("caseNoValue", "<case> no value",
                                     "Value is required for case.");
    }

    public void testDefault() {
        executeTarget("testDefault");
        assertTrue(getLog().indexOf("In default") > -1);
        assertTrue(getLog().indexOf("baz") > -1);
        assertEquals(-1, getLog().indexOf("${inner}"));
        assertEquals(-1, getLog().indexOf("In case"));
    }

    public void testCase() {
        executeTarget("testCase");
        assertTrue(getLog().indexOf("In case") > -1);
        assertTrue(getLog().indexOf("baz") > -1);
        assertEquals(-1, getLog().indexOf("${inner}"));
        assertEquals(-1, getLog().indexOf("In default"));
    }

    public void testCaseSensitive() {
        executeTarget("testCaseSensitive");
        assertTrue(getLog().indexOf("In default") > -1);
        assertEquals(-1, getLog().indexOf("In case"));
    }

    public void testCaseInSensitive() {
        executeTarget("testCaseInSensitive");
        assertTrue(getLog().indexOf("In case") > -1);
        assertEquals(-1, getLog().indexOf("In default"));
    }

}
