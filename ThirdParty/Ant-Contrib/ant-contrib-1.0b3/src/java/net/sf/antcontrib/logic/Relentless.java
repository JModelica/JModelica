/*
 * Copyright (c) 2004-2005 Ant-Contrib project.  All rights reserved.
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
import org.apache.tools.ant.Task;
import org.apache.tools.ant.TaskContainer;

import java.util.Iterator;
import java.util.Vector;

/** Relentless is an Ant task that will relentlessly execute other tasks,
 * ignoring any failures until all tasks have completed.  If any of the
 * executed tasks fail, then Relentless will fail; otherwise it will succeed.
 *
 * @author  Christopher Heiny
 * @version $Id: Relentless.java 12 2006-08-09 17:48:45Z mattinger $
 */
public class Relentless extends Task implements TaskContainer {
    /** We keep the list of tasks we will execute here.
     */
    private Vector taskList = new Vector();
    
    /** Flag indicating how much output to generate.
     */
    private boolean terse = false;
    
    /** Creates a new Relentless task. */
    public Relentless() {
    }
    
    /** This method will be called when it is time to execute the task.
     */
    public void execute() throws BuildException {
        int failCount = 0;
        int taskNo = 0;
        if ( taskList.size() == 0 ) {
            throw new BuildException( "No tasks specified for <relentless>." );
        }
        log("Relentlessly executing: " + this.getDescription());
        Iterator iter = taskList.iterator();
        while ( iter.hasNext() ) {
            Task t = (Task) iter.next();
            taskNo++;
            String desc = t.getDescription();
            if ( desc == null ) {
                desc = "task " + taskNo;
            }
            if (!terse) log("Executing: " + desc);
            try {
                t.perform();
            } catch (BuildException x) {
                log("Task " + desc + " failed: " + x.getMessage());
                failCount++;
            }
        }
        if ( failCount > 0 ) {
            throw new BuildException( "Relentless execution: " + failCount + " of " + taskList.size() + " tasks failed." );
        }
        else {
            log("All tasks completed successfully.");
        }
    }
    
    /** Ant will call this to inform us of nested tasks.
     */
    public void addTask(org.apache.tools.ant.Task task) {
        taskList.add(task);
    }
    
    /** Set this to true to reduce the amount of output generated.
     */
    public void setTerse(boolean terse) {
        this.terse = terse;
    }
    
    /** Retrieve the terse property, indicating how much output we will generate.
     */
    public boolean isTerse() {
        return terse;
    }
    
}
