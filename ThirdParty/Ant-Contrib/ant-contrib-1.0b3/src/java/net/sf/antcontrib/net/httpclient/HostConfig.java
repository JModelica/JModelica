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

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.apache.commons.httpclient.HostConfiguration;
import org.apache.tools.ant.BuildException;

public class HostConfig
	extends HostConfiguration {
	
	public void setHost(String host) {
		setHost(host, getPort(), getProtocol());
	}

	public void setPort(int port) {
		setHost(getHost(), port, getProtocol());
	}
	
	public void setProtocol(String protocol) {
		setHost(getHost(), getPort(), protocol);
	}
	
	public void setAddress(String address) {
		try {
			setLocalAddress(InetAddress.getByName(address));
		}
		catch (UnknownHostException e) {
			throw new BuildException(e);
		}
	}
	
	public void setProxyHost(String host) {
		setProxy(host, getProxyPort());
	}
	
	public void setProxyPort(int port) {
		setProxy(getProxyHost(), port);
	}
	
	public HostParams createParams() {
		HostParams params = new HostParams();
		setParams(params);
		return params;
	}
}
