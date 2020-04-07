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

import org.apache.commons.httpclient.HttpClient;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.DataType;

public class HttpClientType
	extends DataType {

	private HttpClient client;
	
	public HttpClientType(Project p) {
		super();
		setProject(p);
		
		client = new HttpClient();
	}
	
	public HttpClient getClient() {
		if (isReference()) {
			return getRef().getClient();
		}
		else {
			return client;
		}
	}
	
	public void setStateRefId(String stateRefId) {
		if (isReference()) {
			tooManyAttributes();
		}
		HttpStateType stateType = AbstractHttpStateTypeTask.getStateType(
				getProject(),
				stateRefId);
		getClient().setState(stateType.getState());
	}
	
	protected HttpClientType getRef() {
		return (HttpClientType) super.getCheckedRef(HttpClientType.class,
				"http-client");
	}
	
	public ClientParams createClientParams() {
		if (isReference()) {
			tooManyAttributes();
		}
		ClientParams clientParams = new ClientParams();
		client.setParams(clientParams);
		return clientParams;
	}
	
	public HttpStateType createHttpState() {
		if (isReference()) {
			tooManyAttributes();
		}
		HttpStateType state = new HttpStateType(getProject());
		getClient().setState(state.getState());
		return state;
	}
	
	public HostConfig createHostConfig() {
		if (isReference()) {
			tooManyAttributes();
		}
		HostConfig config = new HostConfig();
		client.setHostConfiguration(config);
		return config;		
	}
}
