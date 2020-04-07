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

import org.apache.commons.httpclient.Cookie;
import org.apache.commons.httpclient.HttpState;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.DataType;

public class HttpStateType
	extends DataType {

	private HttpState state;
	
	public HttpStateType(Project p) {
		super();
		setProject(p);
		
		state = new HttpState();
	}
	
	public HttpState getState() {
		if (isReference()) {
			return getRef().getState();
		}
		else {
			return state;
		}
	}
	
	protected HttpStateType getRef() {
		return (HttpStateType) super.getCheckedRef(HttpStateType.class,
				"http-state");
	}
	
	public void addConfiguredCredentials(Credentials credentials) {
		if (isReference()) {
			tooManyAttributes();
		}

		AuthScope scope = new AuthScope(credentials.getHost(),
				credentials.getPort(),
				credentials.getRealm(),
				credentials.getScheme());
		
		UsernamePasswordCredentials c = new UsernamePasswordCredentials(
				credentials.getUsername(),
				credentials.getPassword());
		
		state.setCredentials(scope, c);
	}
	
	public void addConfiguredProxyCredentials(Credentials credentials) {
		if (isReference()) {
			tooManyAttributes();
		}

		AuthScope scope = new AuthScope(credentials.getHost(),
				credentials.getPort(),
				credentials.getRealm(),
				credentials.getScheme());
		
		UsernamePasswordCredentials c = new UsernamePasswordCredentials(
				credentials.getUsername(),
				credentials.getPassword());
		
		state.setProxyCredentials(scope, c);
	}
	
	public void addConfiguredCookie(Cookie cookie) {
		if (isReference()) {
			tooManyAttributes();
		}
		
		state.addCookie(cookie);
	}
}
