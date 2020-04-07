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
import org.apache.tools.ant.types.Path;

/**
 * Testcase for <outofdate>.
 *
 * @author Peter Reilly
 */
public class OutOfDateTest extends BuildFileTest {

    public OutOfDateTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/logic/outofdate.xml");
    }

    public void tearDown() {
        executeTarget("cleanup");
    }
    
    public void testSimple() {
        executeTarget("simple");
    }
    
    public void testVerbose() {
        executeTarget("verbose");
        assertTrue(getLog().indexOf("outofdate with regard to") > -1);
    }
    
    public void testDelete() {
        executeTarget("delete");
    }
    
    public void testDeleteAll() {
        executeTarget("delete-all");
    }
    
    public void testDeleteQuiet() {
        executeTarget("init");
        executeTarget("delete-quiet");
        assertTrue("No deleting message", getLog().indexOf("Deleting") == -1);
    }
    
    public void testFileset() {
        executeTarget("outofdate.init");
        executeTarget("outofdate.test");
        assertTrue(getLog().indexOf("outofdate triggered") > -1);
        String outofdateSources =
            getProject().getProperty("outofdate.sources");
        // switch \ to / if present
        outofdateSources.replace('\\', '/');
        assertTrue("newer.text empty", outofdateSources.indexOf(
                       "newer.text") > -1);
        assertTrue("file.notdone", outofdateSources.indexOf(
                       "outofdate/source/1/2/file.notdone") > -1);
        assertTrue("file.done", outofdateSources.indexOf(
                       "outofdate/source/1/2/file.done") == -1);
        assertTrue("done.y", outofdateSources.indexOf(
                       "outofdate/source/1/done.y") == -1);
        assertTrue("partial.y", outofdateSources.indexOf(
                       "outofdate/source/1/partial.y") > -1);
        String outofdateTargets =
            getProject().getProperty("outofdate.targets");
        assertTrue(outofdateTargets.indexOf(
                       "outofdate.xml") > -1);
        assertTrue(outofdateTargets.indexOf(
                       "outofdate/gen/1/2/file.notdone") > -1);
        assertTrue(outofdateTargets.indexOf(
                       "outofdate/gen/1/partial.h") > -1);
        assertTrue(outofdateTargets.indexOf(
                       "outofdate/gen/1/partial.c") == -1);
        assertTrue(outofdateTargets.indexOf(
                       "outofdate/gen/1/done.h") == -1);

        Path sourcesPath = (Path) getProject().getReference(
            "outofdate.sources.path");
        assertTrue(sourcesPath != null);
        String[] sources = sourcesPath.list();
        assertTrue(sources.length == 3);
        Path targetsPath = (Path) getProject().getReference(
            "outofdate.targets.path");
        String[] targets = targetsPath.list();
        assertTrue(targetsPath != null);
        assertTrue(targets.length == 3);
    }

    public void testEmptySources() {
        executeTarget("empty-sources");
    }
    
}
