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
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.InputStreamRequestEntity;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.apache.commons.httpclient.methods.multipart.FilePart;
import org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity;
import org.apache.commons.httpclient.methods.multipart.Part;
import org.apache.commons.httpclient.methods.multipart.StringPart;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.util.FileUtils;

public class PostMethodTask
	extends AbstractMethodTask {

	private List parts = new ArrayList();
	private boolean multipart;
	private transient FileInputStream stream;
	
	
	public static class FilePartType {
		private File path;
		private String contentType = FilePart.DEFAULT_CONTENT_TYPE;
		private String charSet = FilePart.DEFAULT_CHARSET;

		public File getPath() {
			return path;
		}

		public void setPath(File path) {
			this.path = path;
		}

		public String getContentType() {
			return contentType;
		}

		public void setContentType(String contentType) {
			this.contentType = contentType;
		}

		public String getCharSet() {
			return charSet;
		}

		public void setCharSet(String charSet) {
			this.charSet = charSet;
		}		
	}
	
	public static class TextPartType {
		private String name = "";
		private String value = "";
		private String charSet = StringPart.DEFAULT_CHARSET;
		private String contentType = StringPart.DEFAULT_CONTENT_TYPE;

		public String getValue() {
			return value;
		}

		public void setValue(String value) {
			this.value = value;
		}

		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public String getCharSet() {
			return charSet;
		}

		public void setCharSet(String charSet) {
			this.charSet = charSet;
		}

		public String getContentType() {
			return contentType;
		}

		public void setContentType(String contentType) {
			this.contentType = contentType;
		}		
		
		public void setText(String text) {
			this.value = text;
		}
	}
	
	public void addConfiguredFile(FilePartType file) {
		this.parts.add(file);
	}
	
	public void setMultipart(boolean multipart) {
		this.multipart = multipart;
	}

	public void addConfiguredText(TextPartType text) {
		this.parts.add(text);
	}
	
	public void setParameters(File parameters) {
		PostMethod post = getPostMethod();
		Properties p = new Properties();
		Iterator it = p.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry entry = (Map.Entry) it.next();
			post.addParameter(entry.getKey().toString(),
					entry.getValue().toString());
		}
	}

	protected HttpMethodBase createNewMethod() {
		return new PostMethod();
	}
	
	private PostMethod getPostMethod() {
		return ((PostMethod)createMethodIfNecessary());
	}

	public void addConfiguredParameter(NameValuePair pair) {
		getPostMethod().setParameter(pair.getName(), pair.getValue());
	}
	
	public void setContentChunked(boolean contentChunked) {
		getPostMethod().setContentChunked(contentChunked);
	}
	
	protected void configureMethod(HttpMethodBase method) {
		PostMethod post = (PostMethod) method;

		if (parts.size() == 1 && ! multipart) {
			Object part = parts.get(0);
			if (part instanceof FilePartType) {
				FilePartType filePart = (FilePartType)part;
				try {
					stream = new FileInputStream(
							filePart.getPath().getAbsolutePath());
					post.setRequestEntity(
						new InputStreamRequestEntity(stream,
								filePart.getPath().length(),
								filePart.getContentType()));
				}
				catch (IOException e) {
					throw new BuildException(e);
				}
			}
			else if (part instanceof TextPartType) {
				TextPartType textPart = (TextPartType)part;
				try {
					post.setRequestEntity(
							new StringRequestEntity(textPart.getValue(),
									textPart.getContentType(),
									textPart.getCharSet()));
				}
				catch (UnsupportedEncodingException e) {
					throw new BuildException(e);
				}
			}
		}
		else if (! parts.isEmpty()){
			Part partArray[] = new Part[parts.size()];
			for (int i=0;i<parts.size();i++) {
				Object part = parts.get(i);
				if (part instanceof FilePartType) {
					FilePartType filePart = (FilePartType)part;
					try {
						partArray[i] = new FilePart(filePart.getPath().getName(),
								filePart.getPath().getName(),
								filePart.getPath(),
								filePart.getContentType(),
								filePart.getCharSet());
					}
					catch (FileNotFoundException e) {
						throw new BuildException(e);
					}
				}
				else if (part instanceof TextPartType) {
					TextPartType textPart = (TextPartType)part;
					partArray[i] = new StringPart(textPart.getName(),
							textPart.getValue(),
							textPart.getCharSet());
					((StringPart)partArray[i]).setContentType(textPart.getContentType());
				}
			}
			MultipartRequestEntity entity = new MultipartRequestEntity(
					partArray,
					post.getParams());
			post.setRequestEntity(entity);
		}
	}

	protected void cleanupResources(HttpMethodBase method) {
		FileUtils.close(stream);
	}
	
	
}
