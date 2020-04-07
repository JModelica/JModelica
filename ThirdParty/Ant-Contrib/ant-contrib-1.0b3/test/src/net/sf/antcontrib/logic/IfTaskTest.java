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
 * Testcase for <if>.
 */
public class IfTaskTest extends BuildFileTest {

    public IfTaskTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/if.xml");
    }

    public void testNoCondition() {
        expectSpecificBuildException("noCondition", "no condition",
                                     "You must nest a condition into <if>");
    }        
        
    public void testTwoConditions() {
        expectSpecificBuildException("twoConditions", "two conditions",
                                     "You must not nest more than one "
                                     + "condition into <if>");
    }

    public void testNothingToDo() {
        expectLog("nothingToDo", "");
    }

    public void testTwoThens() {
        expectSpecificBuildException("twoThens", "two <then>s",
                                     "You must not nest more than one "
                                     + "<then> into <if>");
    }

    public void testTwoElses() {
        expectSpecificBuildException("twoElses", "two <else>s",
                                     "You must not nest more than one "
                                     + "<else> into <if>");
    }

    public void testNormalOperation() {
        executeTarget("normalOperation");
        assertTrue(getLog().indexOf("In then") > -1);
        assertTrue(getLog().indexOf("some value") > -1);
        assertEquals(-1, getLog().indexOf("${inner}"));
        assertEquals(-1, getLog().indexOf("In else"));
    }

    public void testNormalOperation2() {
        executeTarget("normalOperation2");
        assertTrue(getLog().indexOf("In else") > -1);
        assertEquals(-1, getLog().indexOf("In then"));
    }

    public void testNoConditionInElseif() {
        expectSpecificBuildException("noConditionInElseif", "no condition",
                                     "You must nest a condition into <elseif>");
    }

    public void testTwoConditionInElseif() {
        expectSpecificBuildException("twoConditionsInElseif", "two conditions",
                                     "You must not nest more than one "
                                     + "condition into <elseif>");
    }

    public void testNormalOperationElseif() {
        executeTarget("normalOperationElseif");
        assertTrue(getLog().indexOf("In elseif") > -1);
        assertEquals(-1, getLog().indexOf("In then"));
        assertEquals(-1, getLog().indexOf("In else-branch"));
    }

    public void testNormalOperationElseif2() {
        executeTarget("normalOperationElseif2");
        assertTrue(getLog().indexOf("In else-branch") > -1);
        assertEquals(-1, getLog().indexOf("In then"));
        assertEquals(-1, getLog().indexOf("In elseif"));
    }

}
