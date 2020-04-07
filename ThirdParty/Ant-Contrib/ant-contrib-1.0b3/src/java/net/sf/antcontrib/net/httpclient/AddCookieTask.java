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

import org.apache.commons.httpclient.Cookie;
import org.apache.tools.ant.BuildException;

public class AddCookieTask
	extends AbstractHttpStateTypeTask {

	private List cookies = new ArrayList();
	
	public void addConfiguredCookie(Cookie cookie) {
		this.cookies.add(cookie);
	}

	protected void execute(HttpStateType stateType) throws BuildException {
		if (this.cookies.isEmpty()) {
			throw new BuildException("At least one cookie must be specified.");
		}
		
		Iterator it = cookies.iterator();
		while (it.hasNext()) {
			Cookie c = (Cookie)it.next();
			stateType.addConfiguredCookie(c);
		}
	}
	
	
}
