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
package net.sf.antcontrib.property;

import org.apache.tools.ant.BuildFileTest;

/**
 * Testcase for <pathtofileset>.
 */
public class PathToFileSetTest extends BuildFileTest {

    public PathToFileSetTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/property/pathtofileset.xml");
    }

    public void tearDown() {
        executeTarget("cleanup");
    }

    public void testSimple() {
        executeTarget("simple");
        assertPropertyContains("simple.0.property", "0.java");
        assertPropertyContains("simple.0.property", "1.java");
        assertPropertyNotContains("simple.0.property", "2.java");
        assertPropertyNotContains("simple.0.property", "3.java");
        assertPropertyNotContains("simple.1.property", "0.java");
        assertPropertyNotContains("simple.1.property", "1.java");
        assertPropertyContains("simple.1.property", "2.java");
        assertPropertyContains("simple.1.property", "3.java");
    }

    public void testSimpleException() {
        expectBuildExceptionContaining("simple-exception", "expect not relative to",
                                       "is not relative to");
    }

    private void assertPropertyContains(String property, String expected) {
        String result = getProject().getProperty(property);
        assertTrue("property " + property + " contains " + expected,
                   result.indexOf(expected) != -1);
    }

    private void assertPropertyNotContains(String property, String expected) {
        String result = getProject().getProperty(property);
        assertTrue("property " + property + " contains " + expected,
                   result.indexOf(expected) == -1);
    }
    
}
