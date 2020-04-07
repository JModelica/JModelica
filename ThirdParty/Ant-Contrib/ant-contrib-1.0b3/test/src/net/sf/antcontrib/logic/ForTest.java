/*
 * Copyright (c) 2006 Ant-Contrib project.  All rights reserved.
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
 * Testcase for <for>.
 */
public class ForTest extends BuildFileTest {

    public ForTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/for.xml");
    }

    public void testLoop() {
        executeTarget("loop");
        assertTrue(getLog().indexOf(
                       "i is 10") != -1);
    }

    public void testStep() {
        executeTarget("step");
        assertTrue(getLog().indexOf(
                       "i is 10") != -1);
        assertTrue(getLog().indexOf(
                       "i is 3") == -1);
    }
}
