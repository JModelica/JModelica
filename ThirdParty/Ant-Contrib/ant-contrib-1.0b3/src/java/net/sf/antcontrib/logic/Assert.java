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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import net.sf.antcontrib.logic.condition.BooleanConditionBase;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.TaskContainer;
import org.apache.tools.ant.taskdefs.Exit;
import org.apache.tools.ant.taskdefs.Sequential;
import org.apache.tools.ant.taskdefs.condition.Condition;


/**
 *
 */
public class Assert
	extends BooleanConditionBase
	implements TaskContainer {

	private List tasks = new ArrayList();
	private String message;
	private boolean failOnError;

	
	public void setFailOnError(boolean failOnError) {
		this.failOnError = failOnError;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public void addTask(Task task) {
		tasks.add(task);
	}
	
	public BooleanConditionBase createBool() {
		return this;
	}
	
	public void execute() {
		if (countConditions() == 0) {
			throw new BuildException("There is no condition specified.");
		}
		else if (countConditions() > 1) {
			throw new BuildException("There must be exactly one condition specified.");
		}
		
		Sequential sequential = (Sequential) getProject().createTask("sequential");
		Condition c = (Condition) getConditions().nextElement();
		if (! c.eval()) {
			if (failOnError) {
				Exit fail = (Exit) getProject().createTask("fail");
				fail.setMessage(message);
				sequential.addTask(fail);
			}
		}
		else {
			Iterator it = tasks.iterator();
			while (it.hasNext()) {
				sequential.addTask((Task)it.next());
			}
		}
	}
	

}
