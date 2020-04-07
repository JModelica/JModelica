package net.sf.antcontrib.logic;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;
import java.util.Vector;

import org.apache.tools.ant.AntClassLoader;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Executor;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Target;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.input.InputHandler;
import org.apache.tools.ant.types.FilterSet;
import org.apache.tools.ant.types.Path;

public class ProjectDelegate
extends Project {

	private Project delegate;
	private Project subproject;

	public ProjectDelegate(Project delegate) {
		super();
		this.delegate = delegate;
	}

	public Project getSubproject() {
		return subproject;
	}

	public void addBuildListener(BuildListener arg0) {
		delegate.addBuildListener(arg0);
	}

	public void addDataTypeDefinition(String arg0, Class arg1) {
		delegate.addDataTypeDefinition(arg0, arg1);
	}

	public void addFilter(String arg0, String arg1) {
		delegate.addFilter(arg0, arg1);
	}

	public void addOrReplaceTarget(String arg0, Target arg1) {
		delegate.addOrReplaceTarget(arg0, arg1);
	}

	public void addOrReplaceTarget(Target arg0) {
		delegate.addOrReplaceTarget(arg0);
	}

	public void addReference(String arg0, Object arg1) {
		delegate.addReference(arg0, arg1);
	}

	public void addTarget(String arg0, Target arg1) throws BuildException {
		delegate.addTarget(arg0, arg1);
	}

	public void addTarget(Target arg0) throws BuildException {
		delegate.addTarget(arg0);
	}

	public void addTaskDefinition(String arg0, Class arg1) throws BuildException {
		delegate.addTaskDefinition(arg0, arg1);
	}

	public void checkTaskClass(Class arg0) throws BuildException {
		delegate.checkTaskClass(arg0);
	}

	public void copyFile(File arg0, File arg1, boolean arg2, boolean arg3, boolean arg4) throws IOException {
		delegate.copyFile(arg0, arg1, arg2, arg3, arg4);
	}

	public void copyFile(File arg0, File arg1, boolean arg2, boolean arg3) throws IOException {
		delegate.copyFile(arg0, arg1, arg2, arg3);
	}

	public void copyFile(File arg0, File arg1, boolean arg2) throws IOException {
		delegate.copyFile(arg0, arg1, arg2);
	}

	public void copyFile(File arg0, File arg1) throws IOException {
		delegate.copyFile(arg0, arg1);
	}

	public void copyFile(String arg0, String arg1, boolean arg2, boolean arg3, boolean arg4) throws IOException {
		delegate.copyFile(arg0, arg1, arg2, arg3, arg4);
	}

	public void copyFile(String arg0, String arg1, boolean arg2, boolean arg3) throws IOException {
		delegate.copyFile(arg0, arg1, arg2, arg3);
	}

	public void copyFile(String arg0, String arg1, boolean arg2) throws IOException {
		delegate.copyFile(arg0, arg1, arg2);
	}

	public void copyFile(String arg0, String arg1) throws IOException {
		delegate.copyFile(arg0, arg1);
	}

	public void copyInheritedProperties(Project arg0) {
		delegate.copyInheritedProperties(arg0);
	}

	public void copyUserProperties(Project arg0) {
		delegate.copyUserProperties(arg0);
	}

	public AntClassLoader createClassLoader(Path arg0) {
		return delegate.createClassLoader(arg0);
	}

	public Object createDataType(String arg0) throws BuildException {
		return delegate.createDataType(arg0);
	}

	public Task createTask(String arg0) throws BuildException {
		return delegate.createTask(arg0);
	}

	public int defaultInput(byte[] arg0, int arg1, int arg2) throws IOException {
		return delegate.defaultInput(arg0, arg1, arg2);
	}

	public void demuxFlush(String arg0, boolean arg1) {
		delegate.demuxFlush(arg0, arg1);
	}

	public int demuxInput(byte[] arg0, int arg1, int arg2) throws IOException {
		return delegate.demuxInput(arg0, arg1, arg2);
	}

	public void demuxOutput(String arg0, boolean arg1) {
		delegate.demuxOutput(arg0, arg1);
	}

	public boolean equals(Object arg0) {
		return delegate.equals(arg0);
	}

	public void executeSortedTargets(Vector arg0) throws BuildException {
		delegate.executeSortedTargets(arg0);
	}

	public void executeTarget(String arg0) throws BuildException {
		delegate.executeTarget(arg0);
	}

	public void executeTargets(Vector arg0) throws BuildException {
		delegate.executeTargets(arg0);
	}

	public void fireBuildFinished(Throwable arg0) {
		delegate.fireBuildFinished(arg0);
	}

	public void fireBuildStarted() {
		delegate.fireBuildStarted();
	}

	public void fireSubBuildFinished(Throwable arg0) {
		delegate.fireSubBuildFinished(arg0);
	}

	public void fireSubBuildStarted() {
		delegate.fireSubBuildStarted();
	}

	public File getBaseDir() {
		return delegate.getBaseDir();
	}

	public Vector getBuildListeners() {
		return delegate.getBuildListeners();
	}

	public ClassLoader getCoreLoader() {
		return delegate.getCoreLoader();
	}

	public Hashtable getDataTypeDefinitions() {
		return delegate.getDataTypeDefinitions();
	}

	public InputStream getDefaultInputStream() {
		return delegate.getDefaultInputStream();
	}

	public String getDefaultTarget() {
		return delegate.getDefaultTarget();
	}

	public String getDescription() {
		return delegate.getDescription();
	}

	public String getElementName(Object arg0) {
		return delegate.getElementName(arg0);
	}

	public Executor getExecutor() {
		return delegate.getExecutor();
	}

	public Hashtable getFilters() {
		return delegate.getFilters();
	}

	public FilterSet getGlobalFilterSet() {
		return delegate.getGlobalFilterSet();
	}

	public InputHandler getInputHandler() {
		return delegate.getInputHandler();
	}

	public String getName() {
		return delegate.getName();
	}

	public Hashtable getProperties() {
		return delegate.getProperties();
	}

	public String getProperty(String arg0) {
		return delegate.getProperty(arg0);
	}

	public Object getReference(String arg0) {
		return delegate.getReference(arg0);
	}

	public Hashtable getReferences() {
		return delegate.getReferences();
	}

	public Hashtable getTargets() {
		return delegate.getTargets();
	}

	public Hashtable getTaskDefinitions() {
		return delegate.getTaskDefinitions();
	}

	public Task getThreadTask(Thread arg0) {
		return delegate.getThreadTask(arg0);
	}

	public Hashtable getUserProperties() {
		return delegate.getUserProperties();
	}

	public String getUserProperty(String arg0) {
		return delegate.getUserProperty(arg0);
	}

	public int hashCode() {
		return delegate.hashCode();
	}

	public void init() throws BuildException {
		delegate.init();
	}

	public void initSubProject(Project arg0) {
		delegate.initSubProject(arg0);
		this.subproject = arg0;
	}

	public boolean isKeepGoingMode() {
		return delegate.isKeepGoingMode();
	}

	public void log(String arg0, int arg1) {
		delegate.log(arg0, arg1);
	}

	public void log(String arg0) {
		delegate.log(arg0);
	}

	public void log(Target arg0, String arg1, int arg2) {
		delegate.log(arg0, arg1, arg2);
	}

	public void log(Task arg0, String arg1, int arg2) {
		delegate.log(arg0, arg1, arg2);
	}

	public void registerThreadTask(Thread arg0, Task arg1) {
		delegate.registerThreadTask(arg0, arg1);
	}

	public void removeBuildListener(BuildListener arg0) {
		delegate.removeBuildListener(arg0);
	}

	public String replaceProperties(String arg0) throws BuildException {
		return delegate.replaceProperties(arg0);
	}

	public File resolveFile(String arg0, File arg1) {
		return delegate.resolveFile(arg0, arg1);
	}

	public File resolveFile(String arg0) {
		return delegate.resolveFile(arg0);
	}

	public void setBaseDir(File arg0) throws BuildException {
		delegate.setBaseDir(arg0);
	}

	public void setBasedir(String arg0) throws BuildException {
		delegate.setBasedir(arg0);
	}

	public void setCoreLoader(ClassLoader arg0) {
		delegate.setCoreLoader(arg0);
	}

	public void setDefault(String arg0) {
		delegate.setDefault(arg0);
	}

	public void setDefaultInputStream(InputStream arg0) {
		delegate.setDefaultInputStream(arg0);
	}

	public void setDefaultTarget(String arg0) {
		delegate.setDefaultTarget(arg0);
	}

	public void setDescription(String arg0) {
		delegate.setDescription(arg0);
	}

	public void setExecutor(Executor arg0) {
		delegate.setExecutor(arg0);
	}

	public void setFileLastModified(File arg0, long arg1) throws BuildException {
		delegate.setFileLastModified(arg0, arg1);
	}

	public void setInheritedProperty(String arg0, String arg1) {
		delegate.setInheritedProperty(arg0, arg1);
	}

	public void setInputHandler(InputHandler arg0) {
		delegate.setInputHandler(arg0);
	}

	public void setJavaVersionProperty() throws BuildException {
		delegate.setJavaVersionProperty();
	}

	public void setKeepGoingMode(boolean arg0) {
		delegate.setKeepGoingMode(arg0);
	}

	public void setName(String arg0) {
		delegate.setName(arg0);
	}

	public void setNewProperty(String arg0, String arg1) {
		delegate.setNewProperty(arg0, arg1);
	}

	public void setProperty(String arg0, String arg1) {
		delegate.setProperty(arg0, arg1);
	}

	public void setSystemProperties() {
		delegate.setSystemProperties();
	}

	public void setUserProperty(String arg0, String arg1) {
		delegate.setUserProperty(arg0, arg1);
	}

	public String toString() {
		return delegate.toString();
	}		
}