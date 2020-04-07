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
 package net.sf.antcontrib.inifile;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Iterator;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Property;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class IniFileTask
        extends Task
{
    public static abstract class IniOperation
    {
        private String section;
        private String property;

        public IniOperation()
        {
            super();
        }

        public String getSection()
        {
            return section;
        }


        public void setSection(String section)
        {
            this.section = section;
        }


        public String getProperty()
        {
            return property;
        }


        public void setProperty(String property)
        {
            this.property = property;
        }

        public void execute(Project project, IniFile iniFile)
        {
                operate(iniFile);
        }

        protected abstract void operate(IniFile file);
    }

    public static abstract class IniOperationConditional extends IniOperation
    {
        private String ifCond;
        private String unlessCond;

        public IniOperationConditional()
        {
            super();
        }

        public void setIf(String ifCond)
        {
            this.ifCond = ifCond;
        }

        public void setUnless(String unlessCond)
        {
            this.unlessCond = unlessCond;
        }

        /**
         * Returns true if the define's if and unless conditions
         * (if any) are satisfied.
         */
        public boolean isActive(org.apache.tools.ant.Project p)
        {
            if (ifCond != null && p.getProperty(ifCond) == null)
            {
                return false;
            }
            else if (unlessCond != null && p.getProperty(unlessCond) != null)
            {
                return false;
            }

            return true;
        }

        public void execute(Project project, IniFile iniFile)
        {
            if (isActive(project))
                operate(iniFile);
        }
    }

	public static abstract class IniOperationPropertySetter extends IniOperation
	{
		private boolean override;
		private String resultproperty;

		public IniOperationPropertySetter()
		{
			super();
		}

		public void setOverride(boolean override)
		{
			this.override = override;
		}

		public void setResultProperty(String resultproperty)
		{
			this.resultproperty = resultproperty;
		}

		protected final void setResultPropertyValue(Project project, String value)
		{
			if (value != null)
			{
				if (override)
				{
					if (project.getUserProperty(resultproperty) == null)
						project.setProperty(resultproperty, value);
					else
						project.setUserProperty(resultproperty, value);
				}
				else
				{
					Property p = (Property)project.createTask("property");
					p.setName(resultproperty);
					p.setValue(value);
					p.execute();
				}
			}
		}
	}

    public static final class Remove
            extends IniOperationConditional
    {
        public Remove()
        {
            super();
        }

        protected void operate(IniFile file)
        {
            String secName = getSection();
            String propName = getProperty();

            if (propName == null)
            {
                file.removeSection(secName);
            }
            else
            {
                IniSection section = file.getSection(secName);
                if (section != null)
                    section.removeProperty(propName);
            }
        }
    }


    public final class Set
            extends IniOperationConditional
    {
        private String value;
        private String operation;

        public Set()
        {
            super();
        }


        public void setValue(String value)
        {
            this.value = value;
        }


        public void setOperation(String operation)
        {
            this.operation = operation;
        }


        protected void operate(IniFile file)
        {
            String secName = getSection();
            String propName = getProperty();

            IniSection section = file.getSection(secName);
            if (section == null)
            {
                section = new IniSection(secName);
                file.setSection(section);
            }

            if (propName != null)
            {
                if (operation != null)
                {
                    if ("+".equals(operation))
                    {
                        IniProperty prop = section.getProperty(propName);
                        value = prop.getValue();
                        int intVal = Integer.parseInt(value) + 1;
                        value = String.valueOf(intVal);
                    }
                    else if ("-".equals(operation))
                    {
                        IniProperty prop = section.getProperty(propName);
                        value = prop.getValue();
                        int intVal = Integer.parseInt(value) - 1;
                        value = String.valueOf(intVal);
                    }
                }
                section.setProperty(new IniProperty(propName, value));
            }
        }
    }

	public final class Exists
		extends IniOperationPropertySetter
	{
		public Exists()
		{
			super();
		}

		protected void operate(IniFile file)
		{
			boolean exists = false;
			String secName = getSection();
			String propName = getProperty();

			if (secName == null)
				throw new BuildException("You must supply a section to search for.");

			if (propName == null)
				exists = (file.getSection(secName) != null);
			else
				exists = (file.getProperty(secName, propName) != null);

			setResultPropertyValue(getProject(), Boolean.valueOf(exists).toString());
		}
	}

	public final class Get
		extends IniOperationPropertySetter
	{
		public Get()
		{
			super();
		}

		protected void operate(IniFile file)
		{
			String secName = getSection();
			String propName = getProperty();

			if (secName == null)
				throw new BuildException("You must supply a section to search for.");

			if (propName == null)
				throw new BuildException("You must supply a property name to search for.");

			setResultPropertyValue(getProject(), file.getProperty(secName, propName));
		}
    }

    private File source;
    private File dest;
    private Vector operations;

    public IniFileTask()
    {
        super();
        this.operations = new Vector();
    }

    public Set createSet()
    {
        Set set = new Set();
        operations.add(set);
        return set;
    }

    public Remove createRemove()
    {
        Remove remove = new Remove();
        operations.add(remove);
        return remove;
    }

    public Exists createExists()
    {
        Exists exists = new Exists();
        operations.add(exists);
        return exists;
    }

    public Get createGet()
    {
        Get get = new Get();
        operations.add(get);
        return get;
    }

    public void setSource(File source)
    {
        this.source = source;
    }


    public void setDest(File dest)
    {
        this.dest = dest;
    }


    public void execute()
        throws BuildException
    {
        if (dest == null)
            throw new BuildException("You must supply a dest file to write to.");

        IniFile iniFile = null;

        try
        {
            iniFile = readIniFile(source);
        }
        catch (IOException e)
        {
            throw new BuildException(e);
        }

        Iterator it = operations.iterator();
        IniOperation operation = null;
        while (it.hasNext())
        {
            operation = (IniOperation)it.next();
            operation.execute(getProject(), iniFile);
        }

        FileWriter writer = null;

        try
        {
            try
            {
                writer = new FileWriter(dest);
                iniFile.write(writer);
            }
            finally
            {
                try
                {
                    if (writer != null)
                        writer.close();
                }
                catch (IOException e)
                {
                    ; // gulp
                }
            }
        }
        catch (IOException e)
        {
            throw new BuildException(e);
        }

    }


    private IniFile readIniFile(File source)
        throws IOException
    {
        FileReader reader = null;
        IniFile iniFile = new IniFile();

        if (source == null)
            return iniFile;

        try
        {
            reader = new FileReader(source);
            iniFile.read(reader);
        }
        finally
        {
            try
            {
                if (reader != null)
                    reader.close();
            }
            catch (IOException e)
            {
                ; // gulp
            }
        }

        return iniFile;
    }
}
