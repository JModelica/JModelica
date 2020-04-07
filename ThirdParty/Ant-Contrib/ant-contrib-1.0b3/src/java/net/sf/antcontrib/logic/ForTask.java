/*
 * Copyright (c) 2003-2005 Ant-Contrib project.  All rights reserved.
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
package net.sf.antcontrib.logic;

import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.MacroDef;
import org.apache.tools.ant.taskdefs.MacroInstance;
import org.apache.tools.ant.taskdefs.Parallel;
import org.apache.tools.ant.types.DirSet;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

/***
 * Task definition for the for task.  This is based on
 * the foreach task but takes a sequential element
 * instead of a target and only works for ant >= 1.6Beta3
 * @author Peter Reilly
 */
public class ForTask extends Task {

    private String     list;
    private String     param;
    private String     delimiter = ",";
    private Path       currPath;
    private boolean    trim;
    private boolean    keepgoing = false;
    private MacroDef   macroDef;
    private List       hasIterators = new ArrayList();
    private boolean    parallel = false;
    private Integer    threadCount;
    private Parallel   parallelTasks;
    private int        begin   = 0;
    private Integer    end     = null;
    private int        step    = 1;

    private int taskCount = 0;
    private int errorCount = 0;

    /**
     * Creates a new <code>For</code> instance.
     */
    public ForTask() {
    }

    /**
     * Attribute whether to execute the loop in parallel or in sequence.
     * @param parallel if true execute the tasks in parallel. Default is false.
     */
    public void setParallel(boolean parallel) {
        this.parallel = parallel;
    }

    /***
     * Set the maximum amount of threads we're going to allow
     * to execute in parallel
     * @param threadCount the number of threads to use
     */
    public void setThreadCount(int threadCount) {
        if (threadCount < 1) {
            throw new BuildException("Illegal value for threadCount " + threadCount
                                     + " it should be > 0");
        }
        this.threadCount = new Integer(threadCount);
    }

    /**
     * Set the trim attribute.
     *
     * @param trim if true, trim the value for each iterator.
     */
    public void setTrim(boolean trim) {
        this.trim = trim;
    }

    /**
     * Set the keepgoing attribute, indicating whether we
     * should stop on errors or continue heedlessly onward.
     *
     * @param keepgoing a boolean, if <code>true</code> then we act in
     * the keepgoing manner described.
     */
    public void setKeepgoing(boolean keepgoing) {
        this.keepgoing = keepgoing;
    }

    /**
     * Set the list attribute.
     *
     * @param list a list of delimiter separated tokens.
     */
    public void setList(String list) {
        this.list = list;
    }

    /**
     * Set the delimiter attribute.
     *
     * @param delimiter the delimiter used to separate the tokens in
     *        the list attribute. The default is ",".
     */
    public void setDelimiter(String delimiter) {
        this.delimiter = delimiter;
    }

    /**
     * Set the param attribute.
     * This is the name of the macrodef attribute that
     * gets set for each iterator of the sequential element.
     *
     * @param param the name of the macrodef attribute.
     */
    public void setParam(String param) {
        this.param = param;
    }

    private Path getOrCreatePath() {
        if (currPath == null) {
            currPath = new Path(getProject());
        }
        return currPath;
    }

    /**
     * This is a path that can be used instread of the list
     * attribute to interate over. If this is set, each
     * path element in the path is used for an interator of the
     * sequential element.
     *
     * @param path the path to be set by the ant script.
     */
    public void addConfigured(Path path) {
        getOrCreatePath().append(path);
    }

    /**
     * This is a path that can be used instread of the list
     * attribute to interate over. If this is set, each
     * path element in the path is used for an interator of the
     * sequential element.
     *
     * @param path the path to be set by the ant script.
     */
    public void addConfiguredPath(Path path) {
        addConfigured(path);
    }

    /**
     * @return a MacroDef#NestedSequential object to be configured
     */
    public Object createSequential() {
        macroDef = new MacroDef();
        macroDef.setProject(getProject());
        return macroDef.createSequential();
    }

    /**
     * Set begin attribute.
     * @param begin the value to use.
     */
    public void setBegin(int begin) {
        this.begin = begin;
    }

    /**
     * Set end attribute.
     * @param end the value to use.
     */
    public void setEnd(Integer end) {
        this.end = end;
    }

    /**
     * Set step attribute.
     *
     */
    public void setStep(int step) {
        this.step = step;
    }

    
    /**
     * Run the for task.
     * This checks the attributes and nested elements, and
     * if there are ok, it calls doTheTasks()
     * which constructes a macrodef task and a
     * for each interation a macrodef instance.
     */
    public void execute() {
        if (parallel) {
            parallelTasks = (Parallel) getProject().createTask("parallel");
            if (threadCount != null) {
                parallelTasks.setThreadCount(threadCount.intValue());
            }
        }
        if (list == null && currPath == null && hasIterators.size() == 0
            && end == null) {
            throw new BuildException(
                "You must have a list or path or sequence to iterate through");
        }
        if (param == null) {
            throw new BuildException(
                "You must supply a property name to set on"
                + " each iteration in param");
        }
        if (macroDef == null) {
            throw new BuildException(
                "You must supply an embedded sequential "
                + "to perform");
        }
        if (end != null) {
            int iEnd = end.intValue();
            if (step == 0) {
                throw new BuildException("step cannot be 0");
            } else if (iEnd > begin && step < 0) {
                throw new BuildException("end > begin, step needs to be > 0");
            } else if (iEnd <= begin && step > 0) {
                throw new BuildException("end <= begin, step needs to be < 0");
            }
        }
        doTheTasks();
        if (parallel) {
            parallelTasks.perform();
        }
    }


    private void doSequentialIteration(String val) {
        MacroInstance instance = new MacroInstance();
        instance.setProject(getProject());
        instance.setOwningTarget(getOwningTarget());
        instance.setMacroDef(macroDef);
        instance.setDynamicAttribute(param.toLowerCase(),
                                     val);
        if (!parallel) {
            instance.execute();
        } else {
            parallelTasks.addTask(instance);
        }
    }

    private void doToken(String tok) {
        try {
            taskCount++;
            doSequentialIteration(tok);
        } catch (BuildException bx) {
            if (keepgoing) {
                log(tok + ": " + bx.getMessage(), Project.MSG_ERR);
                errorCount++;
            } else {
                throw bx;
            }
        }
    }
    
    private void doTheTasks() {
        errorCount = 0;
        taskCount = 0;

        // Create a macro attribute
        if (macroDef.getAttributes().isEmpty()) {
        	MacroDef.Attribute attribute = new MacroDef.Attribute();
        	attribute.setName(param);
        	macroDef.addConfiguredAttribute(attribute);
        }
        
        // Take Care of the list attribute
        if (list != null) {
            StringTokenizer st = new StringTokenizer(list, delimiter);

            while (st.hasMoreTokens()) {
                String tok = st.nextToken();
                if (trim) {
                    tok = tok.trim();
                }
                doToken(tok);
            }
        }

        // Take care of the begin/end/step attributes
        if (end != null) {
            int iEnd = end.intValue();
            if (step > 0) {
                for (int i = begin; i < (iEnd + 1); i = i + step) {
                    doToken("" + i);
                }
            } else {
                for (int i = begin; i > (iEnd - 1); i = i + step) {
                    doToken("" + i);
                }
            }
        }
        
        // Take Care of the path element
        String[] pathElements = new String[0];
        if (currPath != null) {
            pathElements = currPath.list();
        }
        for (int i = 0; i < pathElements.length; i++) {
            File nextFile = new File(pathElements[i]);
            doToken(nextFile.getAbsolutePath());
        }

        // Take care of iterators
        for (Iterator i = hasIterators.iterator(); i.hasNext();) {
            Iterator it = ((HasIterator) i.next()).iterator();
            while (it.hasNext()) {
                doToken(it.next().toString());
            }
        }
        if (keepgoing && (errorCount != 0)) {
            throw new BuildException(
                "Keepgoing execution: " + errorCount
                + " of " + taskCount + " iterations failed.");
        }
    }

    /**
     * Add a Map, iterate over the values
     *
     * @param map a Map object - iterate over the values.
     */
    public void add(Map map) {
        hasIterators.add(new MapIterator(map));
    }

    /**
     * Add a fileset to be iterated over.
     *
     * @param fileset a <code>FileSet</code> value
     */
    public void add(FileSet fileset) {
        getOrCreatePath().addFileset(fileset);
    }

    /**
     * Add a fileset to be iterated over.
     *
     * @param fileset a <code>FileSet</code> value
     */
    public void addFileSet(FileSet fileset) {
        add(fileset);
    }

    /**
     * Add a dirset to be iterated over.
     *
     * @param dirset a <code>DirSet</code> value
     */
    public void add(DirSet dirset) {
        getOrCreatePath().addDirset(dirset);
    }

    /**
     * Add a dirset to be iterated over.
     *
     * @param dirset a <code>DirSet</code> value
     */
    public void addDirSet(DirSet dirset) {
        add(dirset);
    }

    /**
     * Add a collection that can be iterated over.
     *
     * @param collection a <code>Collection</code> value.
     */
    public void add(Collection collection) {
        hasIterators.add(new ReflectIterator(collection));
    }

    /**
     * Add an iterator to be iterated over.
     *
     * @param iterator an <code>Iterator</code> value
     */
    public void add(Iterator iterator) {
        hasIterators.add(new IteratorIterator(iterator));
    }

    /**
     * Add an object that has an Iterator iterator() method
     * that can be iterated over.
     *
     * @param obj An object that can be iterated over.
     */
    public void add(Object obj) {
        hasIterators.add(new ReflectIterator(obj));
    }

    /**
     * Interface for the objects in the iterator collection.
     */
    private interface HasIterator {
        Iterator iterator();
    }

    private static class IteratorIterator implements HasIterator {
        private Iterator iterator;
        public IteratorIterator(Iterator iterator) {
            this.iterator = iterator;
        }
        public Iterator iterator() {
            return this.iterator;
        }
    }

    private static class MapIterator implements HasIterator {
        private Map map;
        public MapIterator(Map map) {
            this.map = map;
        }
        public Iterator iterator() {
            return map.values().iterator();
        }
    }

    private static class ReflectIterator implements HasIterator {
        private Object  obj;
        private Method  method;
        public ReflectIterator(Object obj) {
            this.obj = obj;
            try {
                method = obj.getClass().getMethod(
                    "iterator", new Class[] {});
            } catch (Throwable t) {
                throw new BuildException(
                    "Invalid type " + obj.getClass() + " used in For task, it does"
                    + " not have a public iterator method");
            }
        }

        public Iterator iterator() {
            try {
                return (Iterator) method.invoke(obj, new Object[] {});
            } catch (Throwable t) {
                throw new BuildException(t);
            }
        }
    }
}
