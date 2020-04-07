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
package net.sf.antcontrib.antclipse;

import org.apache.tools.ant.BuildFileTest;

/**
 * Basic test for "antclipse" task. For the moment it just launches the test xml script.
 * @author Adrian Spinei aspinei@myrealbox.com
 * @version $Revision: 1.2 $
 */
public class AntclipseTest extends BuildFileTest
{

	/**
	 * Simple overriden constructor
	 * @param arg0
	 */
	public AntclipseTest(String arg0)
	{
		super(arg0);
	}

	/* (non-Javadoc)
	 * @see junit.framework.TestCase#setUp()
	 */
	public void setUp()
	{
		configureProject("test/resources/antclipse/antclipsetest.xml");
	}

	/* (non-Javadoc)
	 * @see junit.framework.TestCase#tearDown()
	 */
	public void tearDown()
	{
		//nothing to do
	}

	/**
	 * Launches the "everything" task. Should not throw errors.
	 */
	public void testExecuteDefaultBuild()
	{
		executeTarget("everything");
	}

}
