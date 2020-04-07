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
import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Property;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.types.Path.PathElement;
import org.apache.tools.ant.util.RegexpPatternMapper;
import org.xml.sax.AttributeList;
import org.xml.sax.HandlerBase;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 * Support class for the Antclipse task. Basically, it takes the .classpath Eclipse file
 * and feeds a SAX parser. The handler is slightly different according to what we want to
 * obtain (a classpath or a fileset)
 * @author Adrian Spinei aspinei@myrealbox.com
 * @version $Revision: 1.2 $
  * @since Ant 1.5
 */
public class ClassPathTask extends Task
{
	private String project;
	private String idContainer = "antclipse";
	private boolean includeSource = false; //default, do not include source
	private boolean includeOutput = false; //default, do not include output directory
	private boolean includeLibs = true; //default, include all libraries
	private boolean verbose = false; //default quiet
	RegexpPatternMapper irpm = null;
	RegexpPatternMapper erpm = null;
	public static final String TARGET_CLASSPATH = "classpath";
	public static final String TARGET_FILESET = "fileset";
	private String produce = null; //classpath by default

	/**
	 * Setter for task parameter
	 * @param includeLibs Boolean, whether to include or not the project libraries. Default is true.
	 */
	public void setIncludeLibs(boolean includeLibs)
	{
		this.includeLibs = includeLibs;
	}

	/**
	 * Setter for task parameter
	 * @param produce This parameter tells the task wether to produce a "classpath" or a "fileset" (multiple filesets, as a matter of fact).
	 */
	public void setproduce(String produce)
	{
		this.produce = produce;
	}

	/**
	 * Setter for task parameter
	 * @param verbose Boolean, telling the app to throw some info during each step. Default is false.
	 */
	public void setVerbose(boolean verbose)
	{
		this.verbose = verbose;
	}

	/**
	 * Setter for task parameter
	 * @param excludes A regexp for files to exclude. It is taken into account only when producing a classpath, doesn't work on source or output files. It is a real regexp, not a "*" expression.
	 */
	public void setExcludes(String excludes)
	{
		if (excludes != null)
		{
			erpm = new RegexpPatternMapper();
			erpm.setFrom(excludes);
			erpm.setTo("."); //mandatory
		}
		else
			erpm = null;
	}

	/**
	 * Setter for task parameter
	 * @param includes A regexp for files to include. It is taken into account only when producing a classpath, doesn't work on source or output files. It is a real regexp, not a "*" expression.
	 */
	public void setIncludes(String includes)
	{
		if (includes != null)
		{
			irpm = new RegexpPatternMapper();
			irpm.setFrom(includes);
			irpm.setTo("."); //mandatory
		}
		else
			irpm = null;
	}

	/**
	 * Setter for task parameter
	 * @param idContainer The refid which will serve to identify the deliverables. When multiple filesets are produces, their refid is a concatenation between this value and something else (usually obtained from a path). Default "antclipse" 
	 */
	public void setIdContainer(String idContainer)
	{
		this.idContainer = idContainer;
	}

	/**
	 * Setter for task parameter
	 * @param includeOutput Boolean, whether to include or not the project output directories. Default is false.
	 */
	public void setIncludeOutput(boolean includeOutput)
	{
		this.includeOutput = includeOutput;
	}

	/**
	 * Setter for task parameter
	 * @param includeSource Boolean, whether to include or not the project source directories. Default is false.
	 */
	public void setIncludeSource(boolean includeSource)
	{
		this.includeSource = includeSource;
	}

	/**
	 * Setter for task parameter
	 * @param project project name
	 */
	public void setProject(String project)
	{
		this.project = project;
	}

	/**
	 * @see org.apache.tools.ant.Task#execute()
	 */
	public void execute() throws BuildException
	{
		if (!TARGET_CLASSPATH.equalsIgnoreCase(this.produce) && !TARGET_FILESET.equals(this.produce))
			throw new BuildException(
				"Mandatory target must be either '" + TARGET_CLASSPATH + "' or '" + TARGET_FILESET + "'");
		ClassPathParser parser = new ClassPathParser();
		AbstractCustomHandler handler;
		if (TARGET_CLASSPATH.equalsIgnoreCase(this.produce))
		{
			Path path = new Path(this.getProject());
			this.getProject().addReference(this.idContainer, path);
			handler = new PathCustomHandler(path);
		}
		else
		{
			FileSet fileSet = new FileSet();
			this.getProject().addReference(this.idContainer, fileSet);
			fileSet.setDir(new File(this.getProject().getBaseDir().getAbsolutePath().toString()));
			handler = new FileSetCustomHandler(fileSet);
		}
		parser.parse(new File(this.getProject().getBaseDir().getAbsolutePath(), ".classpath"), handler);
	}

	abstract class AbstractCustomHandler extends HandlerBase
	{
		protected String projDir;
		protected static final String ATTRNAME_PATH = "path";
		protected static final String ATTRNAME_KIND = "kind";
		protected static final String ATTR_LIB = "lib";
		protected static final String ATTR_SRC = "src";
		protected static final String ATTR_OUTPUT = "output";
		protected static final String EMPTY = "";
	}

	class FileSetCustomHandler extends AbstractCustomHandler
	{
		private FileSet fileSet = null;

		/**
		 * nazi style, forbid default constructor
		 */
		private FileSetCustomHandler()
		{
		}

		/**
		 * @param fileSet
		 */
		public FileSetCustomHandler(FileSet fileSet)
		{
			super();
			this.fileSet = fileSet;
			projDir = getProject().getBaseDir().getAbsolutePath().toString();
		}

		/**
		 * @see org.xml.sax.DocumentHandler#endDocument()
		 */
		public void endDocument() throws SAXException
		{
			super.endDocument();
			if (fileSet != null && !fileSet.hasPatterns())
				fileSet.setExcludes("**/*");
			//exclude everything or we'll take all the project dirs
		}

		public void startElement(String tag, AttributeList attrs) throws SAXParseException
		{
			if (tag.equalsIgnoreCase("classpathentry"))
			{
				//start by checking if the classpath is coherent at all
				String kind = attrs.getValue(ATTRNAME_KIND);
				if (kind == null)
					throw new BuildException("classpathentry 'kind' attribute is mandatory");
				String path = attrs.getValue(ATTRNAME_PATH);
				if (path == null)
					throw new BuildException("classpathentry 'path' attribute is mandatory");

				//put the outputdirectory in a property
				if (kind.equalsIgnoreCase(ATTR_OUTPUT))
				{
					String propName = idContainer + "outpath";
					Property property = new Property();
					property.setName(propName);
					property.setValue(path);
					property.setProject(getProject());
					property.execute();
					if (verbose)
						System.out.println("Setting property " + propName + " to value " + path);
				}

				//let's put the last source directory in a property
				if (kind.equalsIgnoreCase(ATTR_SRC))
				{
					String propName = idContainer + "srcpath";
					Property property = new Property();
					property.setName(propName);
					property.setValue(path);
					property.setProject(getProject());
					property.execute();
					if (verbose)
						System.out.println("Setting property " + propName + " to value " + path);
				}

				if ((kind.equalsIgnoreCase(ATTR_SRC) && includeSource)
					|| (kind.equalsIgnoreCase(ATTR_OUTPUT) && includeOutput)
					|| (kind.equalsIgnoreCase(ATTR_LIB) && includeLibs))
				{
					//all seem fine
					//	check the includes
					String[] inclResult = new String[] { "all included" };
					if (irpm != null)
					{
						inclResult = irpm.mapFileName(path);
					}
					String[] exclResult = null;
					if (erpm != null)
					{
						exclResult = erpm.mapFileName(path);
					}
					if (inclResult != null && exclResult == null)
					{
						//THIS is the specific code
						if (kind.equalsIgnoreCase(ATTR_OUTPUT))
						{
							//we have included output so let's build a new fileset
							FileSet outFileSet = new FileSet();
							String newReference = idContainer + "-" + path.replace(File.separatorChar, '-');
							getProject().addReference(newReference, outFileSet);
							if (verbose)
								System.out.println(
									"Created new fileset "
										+ newReference
										+ " containing all the files from the output dir "
										+ projDir
										+ File.separator
										+ path);
							outFileSet.setDefaultexcludes(false);
							outFileSet.setDir(new File(projDir + File.separator + path));
							outFileSet.setIncludes("**/*"); //get everything
						}
						else
							if (kind.equalsIgnoreCase(ATTR_SRC))
							{
								//we have included source so let's build a new fileset
								FileSet srcFileSet = new FileSet();
								String newReference = idContainer + "-" + path.replace(File.separatorChar, '-');
								getProject().addReference(newReference, srcFileSet);
								if (verbose)
									System.out.println(
										"Created new fileset "
											+ newReference
											+ " containing all the files from the source dir "
											+ projDir
											+ File.separator
											+ path);
								srcFileSet.setDefaultexcludes(false);
								srcFileSet.setDir(new File(projDir + File.separator + path));
								srcFileSet.setIncludes("**/*"); //get everything
							}
							else
							{
								//not otuptut, just add file after file to the fileset
								File file = new File(fileSet.getDir(getProject()) + "/" + path);
								if (file.isDirectory())
									path += "/**/*";
								if (verbose)
									System.out.println(
										"Adding  "
											+ path
											+ " to fileset "
											+ idContainer
											+ " at "
											+ fileSet.getDir(getProject()));
								fileSet.setIncludes(path);
							}
					}
				}
			}
		}
	}

	class PathCustomHandler extends AbstractCustomHandler
	{
		private Path path = null;

		/**
		 * @param path the path to add files
		 */
		public PathCustomHandler(Path path)
		{
			super();
			this.path = path;
		}

		/**
		 * nazi style, forbid default constructor
		 */
		private PathCustomHandler()
		{
		}

		public void startElement(String tag, AttributeList attrs) throws SAXParseException
		{
			if (tag.equalsIgnoreCase("classpathentry"))
			{
				//start by checking if the classpath is coherent at all
				String kind = attrs.getValue(ATTRNAME_KIND);
				if (kind == null)
					throw new BuildException("classpathentry 'kind' attribute is mandatory");
				String path = attrs.getValue(ATTRNAME_PATH);
				if (path == null)
					throw new BuildException("classpathentry 'path' attribute is mandatory");

				//put the outputdirectory in a property
				if (kind.equalsIgnoreCase(ATTR_OUTPUT))
				{
					String propName = idContainer + "outpath";
					Property property = new Property();
					property.setName(propName);
					property.setValue(path);
					property.setProject(getProject());
					property.execute();
					if (verbose)
						System.out.println("Setting property " + propName + " to value " + path);
				}

				//let's put the last source directory in a property
				if (kind.equalsIgnoreCase(ATTR_SRC))
				{
					String propName = idContainer + "srcpath";
					Property property = new Property();
					property.setName(propName);
					property.setValue(path);
					property.setProject(getProject());
					property.execute();
					if (verbose)
						System.out.println("Setting property " + propName + " to value " + path);
				}

				if ((kind.equalsIgnoreCase(ATTR_SRC) && includeSource)
					|| (kind.equalsIgnoreCase(ATTR_OUTPUT) && includeOutput)
					|| (kind.equalsIgnoreCase(ATTR_LIB) && includeLibs))
				{
					//all seem fine
					//	check the includes
					String[] inclResult = new String[] { "all included" };
					if (irpm != null)
					{
						inclResult = irpm.mapFileName(path);
					}
					String[] exclResult = null;
					if (erpm != null)
					{
						exclResult = erpm.mapFileName(path);
					}
					if (inclResult != null && exclResult == null)
					{
						//THIS is the only specific code
						if (verbose)
							System.out.println("Adding  " + path + " to classpath " + idContainer);
						PathElement element = this.path.createPathElement();
						element.setLocation(new File(path));
					}
				}
			}
		}
	}
}
