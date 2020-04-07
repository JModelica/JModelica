/*
 * Copyright (c) 2001-2006 Ant-Contrib project.  All rights reserved.
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
package net.sf.antcontrib.net.httpclient;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;

public abstract class AbstractHttpStateTypeTask
	extends Task {
	
	private String stateRefId;

	public void setStateRefId(String stateRefId) {
		this.stateRefId = stateRefId;
	}
	
	public Credentials createCredentials() {
		return new Credentials();
	}
	
	static HttpStateType getStateType(Project project, String stateRefId) {
		if (stateRefId == null) {
			throw new BuildException("Missing 'stateRefId'.");
		}
		
		Object stateRef = project.getReference(stateRefId);
		if (stateRef == null) {
			throw new BuildException("Reference '" + stateRefId +
					"' is not defined.");
		}
		if (! (stateRef instanceof HttpStateType)) {
			throw new BuildException("Reference '" + stateRefId +
					"' is not of the correct type.");
		}
		
		return (HttpStateType) stateRef;
	}
	
	public void execute()
		throws BuildException {		
		execute(getStateType(getProject(), stateRefId));
	}

	protected abstract void execute(HttpStateType stateType)
		throws BuildException;
}
