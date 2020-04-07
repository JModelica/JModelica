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
package net.sf.antcontrib.walls;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Move;

/*
 * Created on Aug 25, 2003
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
/**
 * FILL IN JAVADOC HERE
 *
 * @author Dean Hiller(dean@xsoftware.biz)
 */
public class SilentMove extends Move {

    public void log(String msg) {
        log(msg, Project.MSG_INFO);
    }
    
    public void log(String msg, int level) {
        if(level == Project.MSG_INFO)
            super.log(msg, Project.MSG_VERBOSE);
        else if(level == Project.MSG_VERBOSE)
            super.log(msg, Project.MSG_DEBUG);

    }
}