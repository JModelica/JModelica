/*
 * Copyright (c) 2004 Ant-Contrib project.  All rights reserved.
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

package net.sf.antcontrib.util;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import org.apache.tools.ant.BuildException;

/**
 * Utility class to handle reflection on java objects.
 * Its main purpose is to allow ant-contrib classes
 * to compile under ant1.5 but allow the classes to
 * use ant1.6 classes and code if present.
 * The class is a holder class for an object and
 * uses java reflection to call methods on the objects.
 * If things go wrong, BuildExceptions are thrown.
 * @author Peter Reilly
 */

public class Reflector {
    private Object obj;
    /**
     * Constructor for the wrapper using a classname
     * @param name the classname of the object to construct.
     */
    public Reflector(String name) {
        try {
            Class clazz;
            clazz = Class.forName(name);
            Constructor constructor;
            constructor = clazz.getConstructor(new Class[]{});
            obj = constructor.newInstance(new Object[]{});
        } catch (Throwable t) {
            throw new BuildException(t);
        }
    }

    /**
     * Constructor using a passed in object.
     * @param obj the object to wrap.
     */

    public Reflector(Object obj) {
        this.obj = obj;
    }

    /**
     * @return the wrapped object.
     */
    public Object getObject() {
        return obj;
    }

    /**
     * Call a method on the object with no parameters.
     * @param methodName the name of the method to call
     * @return the object returned by the method
     */
    public Object call(String methodName) {
        try {
            Method method;
            method = obj.getClass().getMethod(
                methodName, new Class[] {});
            return method.invoke(obj, new Object[] {});
        } catch (InvocationTargetException t) {
            Throwable t2 = t.getTargetException();
            if (t2 instanceof BuildException) {
                throw (BuildException) t2;
            }
            throw new BuildException(t2);
        } catch (Throwable t) {
            throw new BuildException(t);
        }
    }

    /**
     * Call a method with an object using a specific
     * type as for the method parameter.
     * @param methodName the name of the method
     * @param className the name of the class of the parameter of the method
     * @param o the object to use as the argument of the method
     * @return the object returned by the method
     */
    public Object callExplicit(
        String methodName, String className, Object o) {
        try {
            Method method;
            Class clazz = Class.forName(className);
            method = obj.getClass().getMethod(
                methodName, new Class[] {clazz});
            return method.invoke(obj, new Object[] {o});
        } catch (InvocationTargetException t) {
            Throwable t2 = t.getTargetException();
            if (t2 instanceof BuildException) {
                throw (BuildException) t2;
            }
            throw new BuildException(t2);
        } catch (Throwable t) {
            throw new BuildException(t);
        }
    }

    /**
     * Call a method with an object using a specific
     * type as for the method parameter.
     * @param methodName the name of the method
     * @param classType the class of the parameter of the method
     * @param o the object to use as the argument of the method
     * @return the object returned by the method
     */
    public Object callExplicit(
        String methodName, Class classType, Object o) {
        try {
            Method method;
            method = obj.getClass().getMethod(
                methodName, new Class[] {classType});
            return method.invoke(obj, new Object[] {o});
        } catch (InvocationTargetException t) {
            Throwable t2 = t.getTargetException();
            if (t2 instanceof BuildException) {
                throw (BuildException) t2;
            }
            throw new BuildException(t2);
        } catch (Throwable t) {
            throw new BuildException(t);
        }
    }

    /**
     * Call a method with one parameter.
     * @param methodName the name of the method to call
     * @param o the object to use as the parameter, this must
     *          be of the same type as the method parameter (not a subclass).
     * @return the object returned by the method
     */
    public Object call(String methodName, Object o) {
        try {
            Method method;
            method = obj.getClass().getMethod(
                methodName, new Class[] {o.getClass()});
            return method.invoke(obj, new Object[] {o});
        } catch (InvocationTargetException t) {
            Throwable t2 = t.getTargetException();
            if (t2 instanceof BuildException) {
                throw (BuildException) t2;
            }
            throw new BuildException(t2);
        } catch (Throwable t) {
            throw new BuildException(t);
        }
    }

    /**
     * Call a method with two parameters.
     * @param methodName the name of the method to call
     * @param o1 the object to use as the first parameter, this must
     *           be of the same type as the method parameter (not a subclass).
     * @param o2 the object to use as the second parameter, this must
     *           be of the same type as the method parameter (not a subclass).
     * @return the object returned by the method
     */
    public Object call(String methodName, Object o1, Object o2) {
        try {
            Method method;
            method = obj.getClass().getMethod(
                methodName, new Class[] {o1.getClass(), o2.getClass()});
            return method.invoke(obj, new Object[] {o1, o2});
        } catch (InvocationTargetException t) {
            Throwable t2 = t.getTargetException();
            if (t2 instanceof BuildException) {
                throw (BuildException) t2;
            }
            throw new BuildException(t2);
        } catch (Throwable t) {
            throw new BuildException(t);
        }
    }
}
