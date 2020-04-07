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

import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Sequential;
import org.apache.tools.ant.taskdefs.condition.Condition;
import org.apache.tools.ant.taskdefs.condition.ConditionBase;

/**
 * Perform some tasks based on whether a given condition holds true or
 * not.
 *
 * <p>This task is heavily based on the Condition framework that can
 * be found in Ant 1.4 and later, therefore it cannot be used in
 * conjunction with versions of Ant prior to 1.4.</p>
 *
 * <p>This task doesn't have any attributes, the condition to test is
 * specified by a nested element - see the documentation of your
 * <code>&lt;condition&gt;</code> task (see
 * <a href="http://jakarta.apache.org/ant/manual/CoreTasks/condition.html">the
 * online documentation</a> for example) for a complete list of nested
 * elements.</p>
 *
 * <p>Just like the <code>&lt;condition&gt;</code> task, only a single
 * condition can be specified - you combine them using
 * <code>&lt;and&gt;</code> or <code>&lt;or&gt;</code> conditions.</p>
 *
 * <p>In addition to the condition, you can specify three different
 * child elements, <code>&lt;elseif&gt;</code>, <code>&lt;then&gt;</code> and
 * <code>&lt;else&gt;</code>.  All three subelements are optional.
 *
 * Both <code>&lt;then&gt;</code> and <code>&lt;else&gt;</code> must not be
 * used more than once inside the if task.  Both are
 * containers for Ant tasks, just like Ant's
 * <code>&lt;parallel&gt;</code> and <code>&lt;sequential&gt;</code>
 * tasks - in fact they are implemented using the same class as Ant's
 * <code>&lt;sequential&gt;</code> task.</p>
 *
 *  The <code>&lt;elseif&gt;</code> behaves exactly like an <code>&lt;if&gt;</code>
 * except that it cannot contain the <code>&lt;else&gt;</code> element
 * inside of it.  You may specify as may of these as you like, and the
 * order they are specified is the order they are evaluated in.  If the
 * condition on the <code>&lt;if&gt;</code> is false, then the first
 * <code>&lt;elseif&gt;</code> who's conditional evaluates to true
 * will be executed.  The <code>&lt;else&gt;</code> will be executed
 * only if the <code>&lt;if&gt;</code> and all <code>&lt;elseif&gt;</code>
 * conditions are false.
 *
 * <p>Use the following task to define the <code>&lt;if&gt;</code>
 * task before you use it the first time:</p>
 *
 * <pre><code>
 *   &lt;taskdef name="if" classname="net.sf.antcontrib.logic.IfTask" /&gt;
 * </code></pre>
 *
 * <h3>Crude Example</h3>
 *
 * <pre><code>
 * &lt;if&gt;
 *  &lt;equals arg1=&quot;${foo}&quot; arg2=&quot;bar&quot; /&gt;
 *  &lt;then&gt;
 *    &lt;echo message=&quot;The value of property foo is bar&quot; /&gt;
 *  &lt;/then&gt;
 *  &lt;else&gt;
 *    &lt;echo message=&quot;The value of property foo is not bar&quot; /&gt;
 *  &lt;/else&gt;
 * &lt;/if&gt;
 * </code>
 *
 * <code>
 * &lt;if&gt;
 *  &lt;equals arg1=&quot;${foo}&quot; arg2=&quot;bar&quot; /&gt;
 *  &lt;then&gt;
 *   &lt;echo message=&quot;The value of property foo is 'bar'&quot; /&gt;
 *  &lt;/then&gt;
 *
 *  &lt;elseif&gt;
 *   &lt;equals arg1=&quot;${foo}&quot; arg2=&quot;foo&quot; /&gt;
 *   &lt;then&gt;
 *    &lt;echo message=&quot;The value of property foo is 'foo'&quot; /&gt;
 *   &lt;/then&gt;
 *  &lt;/elseif&gt;
 *
 *  &lt;else&gt;
 *   &lt;echo message=&quot;The value of property foo is not 'foo' or 'bar'&quot; /&gt;
 *  &lt;/else&gt;
 * &lt;/if&gt;
 * </code></pre>
 *
 * @author <a href="mailto:stefan.bodewig@freenet.de">Stefan Bodewig</a>
 */
public class IfTask extends ConditionBase {

    public static final class ElseIf
        extends ConditionBase
    {
        private Sequential thenTasks = null;

        public void addThen(Sequential t)
        {
            if (thenTasks != null)
            {
                throw new BuildException("You must not nest more than one <then> into <elseif>");
            }
            thenTasks = t;
        }

        public boolean eval()
            throws BuildException
        {
            if (countConditions() > 1) {
                throw new BuildException("You must not nest more than one condition into <elseif>");
            }
            if (countConditions() < 1) {
                throw new BuildException("You must nest a condition into <elseif>");
            }
            Condition c = (Condition) getConditions().nextElement();

            return c.eval();
        }

        public void execute()
            throws BuildException
        {
            if (thenTasks != null)
            {
                thenTasks.execute();
            }
        }
    }

    private Sequential thenTasks = null;
    private Vector     elseIfTasks = new Vector();
    private Sequential elseTasks = null;

    /***
     * A nested Else if task
     */
    public void addElseIf(ElseIf ei)
    {
        elseIfTasks.addElement(ei);
    }

    /**
     * A nested &lt;then&gt; element - a container of tasks that will
     * be run if the condition holds true.
     *
     * <p>Not required.</p>
     */
    public void addThen(Sequential t) {
        if (thenTasks != null) {
            throw new BuildException("You must not nest more than one <then> into <if>");
        }
        thenTasks = t;
    }

    /**
     * A nested &lt;else&gt; element - a container of tasks that will
     * be run if the condition doesn't hold true.
     *
     * <p>Not required.</p>
     */
    public void addElse(Sequential e) {
        if (elseTasks != null) {
            throw new BuildException("You must not nest more than one <else> into <if>");
        }
        elseTasks = e;
    }

    public void execute() throws BuildException {
        if (countConditions() > 1) {
            throw new BuildException("You must not nest more than one condition into <if>");
        }
        if (countConditions() < 1) {
            throw new BuildException("You must nest a condition into <if>");
        }
        Condition c = (Condition) getConditions().nextElement();
        if (c.eval()) {
            if (thenTasks != null) {
                thenTasks.execute();
            }
        }
        else
        {
            boolean done = false;
            int sz = elseIfTasks.size();
            for (int i=0;i<sz && ! done;i++)
            {

                ElseIf ei = (ElseIf)(elseIfTasks.elementAt(i));
                if (ei.eval())
                {
                    done = true;
                    ei.execute();
                }
            }

            if (!done && elseTasks != null)
            {
                elseTasks.execute();
            }
        }
    }
}
