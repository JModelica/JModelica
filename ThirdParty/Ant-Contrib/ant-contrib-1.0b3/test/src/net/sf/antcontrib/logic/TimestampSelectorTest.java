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
public class TimestampSelectorTest extends BuildFileTest {

    public TimestampSelectorTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/timestampselector.xml");
    }

    public void tearDown() {
        executeTarget("teardown");
    }

    public void testFileStampFL() {
        simpleTest("filestamp.fl", "file2.txt");
    }

    public void testFileStampPR() {
        simpleTest("filestamp.pr", "file2.txt");
    }

    public void testDirStampDL() {
        simpleTest("dirstamp.dl", "dir2");
    }

    public void testDirStampPR() {
        simpleTest("dirstamp.pr", "dir2");
    }

    private void simpleTest(String target, String expected)
    {
        executeTarget(target);
        assertTrue(getLog().indexOf(expected) > -1);
   }
}
