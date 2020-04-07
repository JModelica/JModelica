/*
 * Copyright (c) 2006 Ant-Contrib project.  All rights reserved.
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
package net.sf.antcontrib.net;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.text.ParseException;
import java.util.Date;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Expand;
import org.apache.tools.ant.taskdefs.ImportTask;

import fr.jayasoft.ivy.Artifact;
import fr.jayasoft.ivy.DefaultModuleDescriptor;
import fr.jayasoft.ivy.DependencyResolver;
import fr.jayasoft.ivy.Ivy;
import fr.jayasoft.ivy.MDArtifact;
import fr.jayasoft.ivy.ModuleDescriptor;
import fr.jayasoft.ivy.ModuleId;
import fr.jayasoft.ivy.ModuleRevisionId;
import fr.jayasoft.ivy.report.ArtifactDownloadReport;
import fr.jayasoft.ivy.report.DownloadStatus;
import fr.jayasoft.ivy.repository.Repository;
import fr.jayasoft.ivy.resolver.FileSystemResolver;
import fr.jayasoft.ivy.resolver.IvyRepResolver;
import fr.jayasoft.ivy.resolver.URLResolver;

/***
 * Task to import a build file from a url.  The build file can be a build.xml,
 * or a .zip/.jar, in which case we download and extract the entire archive, and
 * import the file "build.xml"
 * @author inger
 *
 */
public class URLImportTask
	extends Task {

	private String org;
	private String module;
	private String rev = "latest.integration";
	private String type = "jar";
	private String repositoryUrl;
	private String repositoryDir;
	private URL ivyConfUrl;
	private File ivyConfFile;
	private String artifactPattern = "/[org]/[module]/[ext]s/[module]-[revision].[ext]";
	private String ivyPattern = "/[org]/[module]/ivy-[revision].xml";
	
	public void setModule(String module) {
		this.module = module;
	}

	public void setOrg(String org) {
		this.org = org;
	}

	public void setRev(String rev) {
		this.rev = rev;
	}

	public void setIvyConfFile(File ivyConfFile) {
		this.ivyConfFile = ivyConfFile;
	}

	public void setIvyConfUrl(URL ivyConfUrl) {
		this.ivyConfUrl = ivyConfUrl;
	}

	public void execute()
		throws BuildException {

		Ivy ivy = new Ivy();
		DependencyResolver resolver = null;
		Repository rep = null;
		
		if (repositoryUrl != null) {
			resolver = new URLResolver();
			((URLResolver)resolver).addArtifactPattern(
					repositoryUrl + "/" + artifactPattern
					);
			((URLResolver)resolver).addIvyPattern(
					repositoryUrl + "/" + ivyPattern
					);
			resolver.setName("default");
		}
		else if (repositoryDir != null) {
			resolver = new FileSystemResolver();
			((FileSystemResolver)resolver).addArtifactPattern(
					repositoryDir + "/" + artifactPattern
					);
			((FileSystemResolver)resolver).addIvyPattern(
					repositoryDir + "/" + ivyPattern
					);
		}
		else if (ivyConfUrl != null) {
			try {
				ivy.configure(ivyConfUrl);
			}
			catch (IOException e) {
				throw new BuildException(e);
			}
			catch (ParseException e) {
				throw new BuildException(e);
			}
		}
		else if (ivyConfFile != null) {
			try {
				ivy.configure(ivyConfFile);
			}
			catch (IOException e) {
				throw new BuildException(e);
			}
			catch (ParseException e) {
				throw new BuildException(e);
			}
		}
		else {
			resolver = new IvyRepResolver();
		}
		resolver.setName("default");
		ivy.addResolver(resolver);
		ivy.setDefaultResolver(resolver.getName());
		
		ModuleId moduleId =
			new ModuleId(org, module);		
		ModuleRevisionId revId =
			new ModuleRevisionId(moduleId, rev);
		ModuleDescriptor md =
			new DefaultModuleDescriptor(revId, "integration", new Date());		
		Artifact artifact =
			new MDArtifact(md, module, type, type);
		
		ArtifactDownloadReport report =
			ivy.download(artifact, null);
		
		DownloadStatus status = report.getDownloadStatus();
		if (status == DownloadStatus.FAILED) {
			throw new BuildException("Could not resolve resource.");
		}
		
		String path = ivy.getArchivePathInCache(artifact);
		
		File file = new File(ivy.getDefaultCache(), path);
		
		File importFile = null;
		
	    if ("xml".equalsIgnoreCase(type)) {
	    	importFile = file;
	    }
	    else if ("jar".equalsIgnoreCase(type)) {
	    	File dir = new File(file.getParentFile(),
	    			file.getName() + ".extracted");
   		    dir.mkdir();
	    	Expand expand = (Expand)getProject().createTask("unjar");
	    	expand.setSrc(file);
	    	expand.setDest(dir);
	    	expand.perform();
	    	importFile = new File(dir, "build.xml");
	    	if (! importFile.exists()) {
	    		throw new BuildException("Cannot find a 'build.xml' file in " +
	    				file.getName());
	    	}
	    }
	    else {
	    	throw new BuildException("Don't know what to do with type: " + type);
	    }
		
	    File buildFile = null;
	    ImportTask importTask = new ImportTask();
	    importTask.setProject(getProject());
	    importTask.setOwningTarget(getOwningTarget());
	    importTask.setLocation(getLocation());
	    importTask.setFile(buildFile.getAbsolutePath());
	    importTask.perform();
	    log("Import complete.", Project.MSG_INFO);
	}
}
