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
 * Testcase for <propertycopy>.
 */
public class PropertyCopyTest extends BuildFileTest {

    public PropertyCopyTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/property/propertycopy.xml");
    }

	/**
	 * Runs a propertyCopy without a specified name attribute.
	 */
    public void testMissingName() {
        expectSpecificBuildException("missingName", "missing name",
                                     "You must specify a property to set.");
    }
        
    public void testMissingFrom() {
        expectSpecificBuildException("missingFrom", "missing from",
                                     "Missing the 'from' attribute.");
    }

    public void testNonSilent() {
        expectSpecificBuildException("nonSilent", "from doesn't exist",
                                     "Property 'bar' is not defined.");
    }

    public void testSilent() {
        executeTarget("silent");
        assertPropertyEquals("foo", null);
    }

    public void testNormal() {
        executeTarget("normal");
        assertPropertyEquals("displayName", "My Organiziation");
    }
}
