/*
 * Copyright (c) 2001-2005 Ant-Contrib project.  All rights reserved.
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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.BuildFileTest;

/**
 * Testcase for <trycatch>.
 */
public class TryCatchTaskTest extends BuildFileTest {

    public TryCatchTaskTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/trycatch.xml");
    }

    public void testFullTest() {
        executeTarget("fullTest");
        assertEquals("Tada!", getProject().getProperty("foo"));
        Object e = getProject().getReference("bar");
        assertNotNull(e);
        assertTrue(e instanceof BuildException);
        assertEquals("Tada!", ((BuildException) e).getMessage());
    }
    
    public void testTwoCatches() {
        //  two catch blocks were not supported prior to TryCatchTask.java v 1.4.
        executeTarget("twoCatches");
    }

    public void testTwoFinallys() {
        expectSpecificBuildException("twoFinallys", "two finally children",
                                     "You must not specify more than one <finally>");
    }

    public void testTwoTrys() {
        expectSpecificBuildException("twoTrys", "two try children",
                                     "You must not specify more than one <try>");
    }

    public void testNoTry() {
        expectSpecificBuildException("noTry", "no try child",
                                     "A nested <try> element is required");
    }

    public void testNoException() {
        executeTarget("noException");
        int message = getLog().indexOf("Tada!");
        int catchBlock = getLog().indexOf("In <catch>");
        int finallyBlock = getLog().indexOf("In <finally>");
        assertTrue(message > -1);
        assertEquals(-1, catchBlock);
        assertTrue(finallyBlock > message);
        assertNull(getProject().getProperty("foo"));
        assertNull(getProject().getReference("bar"));
   }
}
    
