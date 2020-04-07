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
package net.sf.antcontrib.platform;

import org.apache.tools.ant.BuildFileTest;

/**
 * Testcase for <shellscript>
 *
 * @author Peter Reilly
 */
public class ShellScriptTest extends BuildFileTest {
    public ShellScriptTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("test/resources/platform/shellscript.xml");
        staticInitialize();
    }

    public void testShHello() {
        if (! hasSh)
            return;
        executeTarget("sh.hello");
        assertTrue(getLog().indexOf("hello world") > -1);
     }

    public void testBashHello() {
        if (! hasBash)
            return;
        executeTarget("bash.hello");
        assertTrue(getLog().indexOf("hello world") > -1);
     }

    public void testShInputString() {
        if (! hasSh)
            return;
        executeTarget("sh.inputstring");
        assertTrue(getLog().indexOf("hello world") > -1);
     }

    public void testShProperty() {
        if (! hasSh)
            return;
        executeTarget("sh.property");
        assertTrue(getLog().indexOf("this is a property") > -1);
     }


    public void testPythonHello() {
        if (! hasPython)
            return;
        executeTarget("python.hello");
        assertTrue(getLog().indexOf("hello world") > -1);
    }

    public void testPerlHello() {
        if (! hasPerl)
            return;
        executeTarget("perl.hello");
        assertTrue(getLog().indexOf("hello world") > -1);
    }

    public void testNoShell() {
        expectBuildExceptionContaining(
            "noshell", "Execute failed", "a shell that should not exist");
    }

    public void testSed() {
        if (! hasSed)
            return;
        executeTarget("sed.test");
        assertTrue(getLog().indexOf("BAR bar bar bar BAR bar") > -1);
    }

    public void testSetProperty() {
        if (! hasSh)
            return;
        executeTarget("sh.set.property");
        assertPropertyEquals("sh.set.property", "hello world");
    }

    public void testTmpSuffix() {
        if (! hasSh)
            return;
        executeTarget("sh.tmp.suffix");
        assertTrue(getLog().indexOf(".bat") > -1);
    }

    public void testCmd() {
        if (! hasCmd)
            return;
        executeTarget("cmd.test");
        assertTrue(getLog().indexOf("hello world") > -1);
    }

    public void testDir() {
        if (! hasBash)
            return;
        executeTarget("dir.test");
        assertTrue(
            getProject().getProperty("dir.test.property")
            .indexOf("subdir") > -1);
    }

    public void testCommand() {
        expectBuildExceptionContaining(
            "command.test", "Attribute failed",
            "Attribute command is not supported");
    }
    
    private static boolean initialized = false;
    private static boolean hasSh       = false;
    private static boolean hasBash     = false;
    private static boolean hasPython   = false;
    private static boolean hasPerl     = false;
    private static boolean hasSed      = false;
    private static boolean hasCmd      = false;
    private static Object staticMonitor = new Object();
    
    /**
     * check if the env contains the shells
     *    sh, bash, python and perl
     *    assume cmd.exe exists for windows
     */
    private void staticInitialize() {
        synchronized (staticMonitor) {
            if (initialized)
                return;
            initialized = true;
            hasSh = hasShell("hassh");
            hasBash = hasShell("hasbash");
            hasPerl = hasShell("hasperl");
            hasPython = hasShell("haspython");
            hasSed = hasShell("hassed");
            hasCmd = hasShell("hascmd");
            
        }
    }

    private boolean hasShell(String target) {
        try {
            executeTarget(target);
            return true;
        }
        catch (Throwable t) {
            return false;
        }
    }
        
}
