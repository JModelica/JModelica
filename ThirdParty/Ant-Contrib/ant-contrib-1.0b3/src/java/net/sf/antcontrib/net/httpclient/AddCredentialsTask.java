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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildException;

public class AddCredentialsTask
	extends AbstractHttpStateTypeTask {
	
	private List credentials = new ArrayList();
	private List proxyCredentials = new ArrayList();

	public void addConfiguredCredentials(Credentials credentials) {
		this.credentials.add(credentials);
	}

	public void addConfiguredProxyCredentials(Credentials credentials) {
		this.proxyCredentials.add(credentials);
	}
	
	protected void execute(HttpStateType stateType) throws BuildException {
		if (credentials.isEmpty() && proxyCredentials.isEmpty()) {
			throw new BuildException("Either regular or proxy credentials" +
					" must be supplied.");
		}
		
		Iterator it = credentials.iterator();
		while (it.hasNext()) {
			Credentials c = (Credentials)it.next();
			stateType.addConfiguredCredentials(c);
		}

		it = proxyCredentials.iterator();
		while (it.hasNext()) {
			Credentials c = (Credentials)it.next();
			stateType.addConfiguredProxyCredentials(c);
		}
	}
}
