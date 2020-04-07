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

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.URI;
import org.apache.commons.httpclient.URIException;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Property;
import org.apache.tools.ant.util.FileUtils;

public abstract class AbstractMethodTask
	extends Task {

	private HttpMethodBase method;
	private File responseDataFile;
	private String responseDataProperty;
	private String statusCodeProperty;
	private HttpClient httpClient;
	private List responseHeaders = new ArrayList();
	
	public static class ResponseHeader {
		private String name;
		private String property;
		public String getName() {
			return name;
		}
		public void setName(String name) {
			this.name = name;
		}
		public String getProperty() {
			return property;
		}
		public void setProperty(String property) {
			this.property = property;
		}		
	}
	
	protected abstract HttpMethodBase createNewMethod();
	protected void configureMethod(HttpMethodBase method) {	
	}
	protected void cleanupResources(HttpMethodBase method) {		
	}
	
	public void addConfiguredResponseHeader(ResponseHeader responseHeader) {
		this.responseHeaders.add(responseHeader);
	}
	
	public void addConfiguredHttpClient(HttpClientType httpClientType) {
		this.httpClient = httpClientType.getClient();
	}
	
	protected HttpMethodBase createMethodIfNecessary() {
		if (method == null) {
			method = createNewMethod();
		}
		return method;
	}
	
	public void setResponseDataFile(File responseDataFile) {
		this.responseDataFile = responseDataFile;
	}

	public void setResponseDataProperty(String responseDataProperty) {
		this.responseDataProperty = responseDataProperty;
	}

	public void setStatusCodeProperty(String statusCodeProperty) {
		this.statusCodeProperty = statusCodeProperty;
	}

	public void setClientRefId(String clientRefId) {
		Object clientRef = getProject().getReference(clientRefId);
		if (clientRef == null) {
			throw new BuildException("Reference '" + clientRefId + "' does not exist.");
		}
		if (! (clientRef instanceof HttpClientType)) {
			throw new BuildException("Reference '" + clientRefId + "' is of the wrong type.");
		}
		httpClient = ((HttpClientType) clientRef).getClient();
	}

	public void setDoAuthentication(boolean doAuthentication) {
		createMethodIfNecessary().setDoAuthentication(doAuthentication);
	}

	public void setFollowRedirects(boolean doFollowRedirects) {
		createMethodIfNecessary().setFollowRedirects(doFollowRedirects);
	}

	public void addConfiguredParams(MethodParams params) {
		createMethodIfNecessary().setParams(params);
	}
	
	public void setPath(String path) {
		createMethodIfNecessary().setPath(path);
	}
	
	public void setURL(String url) {
		try {
			createMethodIfNecessary().setURI(new URI(url, false));
		}
		catch (URIException e) {
			throw new BuildException(e);
		}
	}
	
	public void setQueryString(String queryString) {
		createMethodIfNecessary().setQueryString(queryString);
	}
	
	public void addConfiguredHeader(Header header) {
		createMethodIfNecessary().setRequestHeader(header);
	}
	
	public void execute() throws BuildException {
		if (httpClient == null) {
			httpClient = new HttpClient();
		}
		
		HttpMethodBase method = createMethodIfNecessary();
		configureMethod(method);
		try {
			int statusCode = httpClient.executeMethod(method);
			if (statusCodeProperty != null) {
				Property p = (Property)getProject().createTask("property");
				p.setName(statusCodeProperty);
				p.setValue(String.valueOf(statusCode));
				p.perform();
			}
			
			Iterator it = responseHeaders.iterator();
			while (it.hasNext()) {
				ResponseHeader header = (ResponseHeader)it.next();
				Property p = (Property)getProject().createTask("property");
				p.setName(header.getProperty());
				Header h = method.getResponseHeader(header.getName());
				if (h != null && h.getValue() != null) {
					p.setValue(h.getValue());
					p.perform();
				}
				
			}
			if (responseDataProperty != null) {
				Property p = (Property)getProject().createTask("property");
				p.setName(responseDataProperty);
				p.setValue(method.getResponseBodyAsString());
				p.perform();				
			}
			else if (responseDataFile != null) {
				FileOutputStream fos = null;
				InputStream is = null;
				try {
					is = method.getResponseBodyAsStream();
					fos = new FileOutputStream(responseDataFile);
					byte buf[] = new byte[10*1024];
					int read = 0;
					while ((read = is.read(buf, 0, 10*1024)) != -1) {
						fos.write(buf, 0, read);
					}
				}
				finally {
					FileUtils.close(fos);
					FileUtils.close(is);
				}
			}
		}
		catch (IOException e) {
			throw new BuildException(e);
		}
		finally {
			cleanupResources(method);
		}
	}
}
