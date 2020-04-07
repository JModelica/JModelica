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
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
  * Ant task that runs a target without creating a new project.
  *
  * @author Nicola Ken Barozzi nicolaken@apache.org
  */
public class RunTargetTask extends Task {

    private String target = null;

    /**
     * The target attribute
     *
     * @param target the name of a target to execute
     */
    public void setTarget(String target) {
        this.target = target;
    }

    /**
     * execute the target
     *
     * @exception BuildException if a target is not specified
     */
    public void execute() throws BuildException {
        if (target == null) {
            throw new BuildException("target property required");
        }

        getProject().executeTarget(target);
    }
}
