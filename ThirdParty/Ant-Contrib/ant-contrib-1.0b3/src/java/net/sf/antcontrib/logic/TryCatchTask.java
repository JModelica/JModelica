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

import java.util.Enumeration;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Sequential;

/**
 * A wrapper that lets you run a set of tasks and optionally run a
 * different set of tasks if the first set fails and yet another set
 * after the first one has finished.
 *
 * <p>This mirrors Java's try/catch/finally.</p>
 *
 * <p>The tasks inside of the required <code>&lt;try&gt;</code>
 * element will be run.  If one of them should throw a {@link
 * org.apache.tools.ant.BuildException BuildException} several things
 * can happen:</p>
 *
 * <ul>
 *   <li>If there is no <code>&lt;catch&gt;</code> block, the
 *   exception will be passed through to Ant.</li>
 *
 *   <li>If the property attribute has been set, a property of the
 *   given name will be set to the message of the exception.</li>
 *
 *   <li>If the reference attribute has been set, a reference of the
 *   given id will be created and point to the exception object.</li>
 *
 *   <li>If there is a <code>&lt;catch&gt;</code> block, the tasks
 *   nested into it will be run.</li>
 * </ul>
 *
 * <p>If a <code>&lt;finally&gt;</code> block is present, the task
 * nested into it will be run, no matter whether the first tasks have
 * thrown an exception or not.</p>
 *
 * <p><strong>Attributes:</strong></p>
 *
 * <table>
 *   <tr>
 *     <td>Name</td>
 *     <td>Description</td>
 *     <td>Required</td>
 *   </tr>
 *   <tr>
 *     <td>property</td>
 *     <td>Name of a property that will receive the message of the
 *     exception that has been caught (if any)</td>
 *     <td>No</td>
 *   </tr>
 *   <tr>
 *     <td>reference</td>
 *     <td>Id of a reference that will point to the exception object
 *     that has been caught (if any)</td>
 *     <td>No</td>
 *   </tr>
 * </table>
 *
 * <p>Use the following task to define the <code>&lt;trycatch&gt;</code>
 * task before you use it the first time:</p>
 *
 * <pre><code>
 *   &lt;taskdef name="trycatch" 
 *            classname="net.sf.antcontrib.logic.TryCatchTask" /&gt;
 * </code></pre>
 * 
 * <h3>Crude Example</h3>
 *
 * <pre><code>
 * &lt;trycatch property=&quot;foo&quot; reference=&quot;bar&quot;&gt;
 *   &lt;try&gt;
 *     &lt;fail&gt;Tada!&lt;/fail&gt;
 *   &lt;/try&gt;
 *
 *   &lt;catch&gt;
 *     &lt;echo&gt;In &amp;lt;catch&amp;gt;.&lt;/echo&gt;
 *   &lt;/catch&gt;
 *
 *   &lt;finally&gt;
 *     &lt;echo&gt;In &amp;lt;finally&amp;gt;.&lt;/echo&gt;
 *   &lt;/finally&gt;
 * &lt;/trycatch&gt;
 *
 * &lt;echo&gt;As property: ${foo}&lt;/echo&gt;
 * &lt;property name=&quot;baz&quot; refid=&quot;bar&quot; /&gt;
 * &lt;echo&gt;From reference: ${baz}&lt;/echo&gt;
 * </code></pre>
 *
 * <p>results in</p>
 *
 * <pre><code>
 *   [trycatch] Caught exception: Tada!
 *       [echo] In &lt;catch&gt;.
 *       [echo] In &lt;finally&gt;.
 *       [echo] As property: Tada!
 *       [echo] From reference: Tada!
 * </code></pre>
 *
 * @author <a href="mailto:stefan.bodewig@freenet.de">Stefan Bodewig</a>
 * @author <a href="mailto:RITCHED2@Nationwide.com">Dan Ritchey</a>
 */
public class TryCatchTask extends Task {

    public static final class CatchBlock extends Sequential {
        private String throwable = BuildException.class.getName();

        public CatchBlock() {
            super();
        }

        public void setThrowable(String throwable) {
            this.throwable = throwable;
        }

        public boolean execute(Throwable t) throws BuildException {
            try {
                Class c = Thread.currentThread().getContextClassLoader().loadClass(throwable);
                if (c.isAssignableFrom(t.getClass())) {
                    execute();
                    return true;
                }
                return false;
            }
            catch (ClassNotFoundException e) {
                throw new BuildException(e);
            }
        }
    }


    private Sequential tryTasks = null;
    private Vector catchBlocks = new Vector();
    private Sequential finallyTasks = null;
    private String property = null;
    private String reference = null;

    /**
     * Adds a nested &lt;try&gt; block - one is required, more is
     * forbidden.
     */
    public void addTry(Sequential seq) throws BuildException {
        if (tryTasks != null) {
            throw new BuildException("You must not specify more than one <try>");
        }
        
        tryTasks = seq;
    }

    public void addCatch(CatchBlock cb) {
        catchBlocks.add(cb);
    }

    /**
     * Adds a nested &lt;finally&gt; block - at most one is allowed.
     */
    public void addFinally(Sequential seq) throws BuildException {
        if (finallyTasks != null) {
            throw new BuildException("You must not specify more than one <finally>");
        }
        
        finallyTasks = seq;
    }

    /**
     * Sets the property attribute.
     */
    public void setProperty(String p) {
        property = p;
    }

    /**
     * Sets the reference attribute.
     */
    public void setReference(String r) {
        reference = r;
    }

    /**
     * The heart of the task.
     */
    public void execute() throws BuildException {
    	Throwable thrown = null;
    	
        if (tryTasks == null) {
            throw new BuildException("A nested <try> element is required");
        }

        try {
            tryTasks.perform();
        } catch (Throwable e) {
            if (property != null) {
                /*
                 * Using setProperty instead of setNewProperty to
                 * be able to compile with Ant < 1.5.
                 */
                getProject().setProperty(property, e.getMessage());
            }
            
            if (reference != null) {
                getProject().addReference(reference, e);
            }

            boolean executed = false;
            Enumeration blocks = catchBlocks.elements();
            while (blocks.hasMoreElements() && ! executed) {
                CatchBlock cb = (CatchBlock)blocks.nextElement();
                executed = cb.execute(e);
            }
            
            if (! executed) {
            	thrown = e;
            }
        } finally {
            if (finallyTasks != null) {
                finallyTasks.perform();
            }
        }
        
        if (thrown != null) {
        	throw new BuildException(thrown);
        }
    }

}
