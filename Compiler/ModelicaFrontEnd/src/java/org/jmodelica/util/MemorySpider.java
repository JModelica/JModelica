/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.util;

import java.lang.reflect.Field;
import java.security.AccessController;
import java.security.PrivilegedAction;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;
import java.util.Stack;

public class MemorySpider {

	public interface Visitor {
		void visit(Object o, Stack<Frame> path);
	}
	
	public static abstract class ClassFilteredVisitor<T> implements Visitor {
		
		private Class<T> filter;

		public ClassFilteredVisitor(Class<T> cls) {
			filter = cls;
		}

		@Override
        @SuppressWarnings("unchecked")
        public void visit(Object o, Stack<Frame> path) {
			if (filter.isAssignableFrom(o.getClass()))
				visitFiltered((T) o, path);
		}
		
		protected abstract void visitFiltered(T o, Stack<Frame> path);
		
	}
    
    private static class GetFieldsAction implements PrivilegedAction<Field[]> {
    	
    	private Class<?> cls;
    	
    	public Field[] perform(Class<?> cl) {
    		cls = cl;
    		return AccessController.doPrivileged(this);
    	}

		@Override
        public Field[] run() {
			return cls.getDeclaredFields();
		}
    	
    }
	
	public abstract class Frame {
		
		protected Object obj;

		protected Frame(Object o) {
			obj = o;
		}

		public Object getObject() {
			return obj;
		}
		
		public String name() {
			return obj.getClass().getSimpleName();
		}

	}

	public class FieldFrame extends Frame {

		private Field f;

		public FieldFrame(Field f, Object o) {
			super(getValue.perform(f, o));
			this.f = f;
		}
		
		@Override
        public String toString() {
			return "field " + f.getName() + " = " + name();
		}

	}

	public class ArrayFrame extends Frame {

		private int i;

		public ArrayFrame(Object o, int i) {
			super(java.lang.reflect.Array.get(o, i));
			this.i = i;
		}
		
		@Override
        public String toString() {
			return "array cell " + i + " = " + name();
		}

	}

	public class InitialFrame extends Frame {

		public InitialFrame(Object o) {
			super(o);
		}
		
		@Override
        public String toString() {
			return "initial object: " + name();
		}

	}

	public class LinkedListFrame extends Frame {

		protected LinkedListFrame(Object o) {
			super(o);
		}
		
		@Override
        public String toString() {
			return "object in linked list: " + name();
		}

	}
    
    private static class GetValueAction implements PrivilegedAction<Object> {
    	
    	private Field field;
    	
    	public Object perform(Field f, Object o) {
    		field = f;
    		if (!f.isAccessible())
    			AccessController.doPrivileged(this);
    		try {
				return f.get(o);
			} catch (IllegalAccessException e) {
				return null;
			}
    	}

		@Override
        public Object run() {
			field.setAccessible(true);
			return null;
		}
    	
    }
    
    public MemorySpider(Visitor v) {
		visitor = v;
		visited = new HashSet<Object>(2000);
	}
    
	private static GetFieldsAction getFields = new GetFieldsAction();
	private static GetValueAction  getValue  = new GetValueAction();

	private Set<Object> visited;
	private Visitor visitor;
	private Stack<Frame> path = new Stack<Frame>();
	
	public void traverse(Object o) {
		traverse(new InitialFrame(o));
	}
	
	public void traverse(Frame fr) {
		Object o = fr.getObject();
		if (o == null || visited.contains(o))
			return;
		path.push(fr);
		visited.add(o);
		visitor.visit(o, path);
		
		Class<?> type = o.getClass();
		if (type.isArray()) {
			int len = java.lang.reflect.Array.getLength(o);
			if (!type.getComponentType().isPrimitive()) {
				for (int i = 0; i < len; i++) {
					traverse(new ArrayFrame(o, i));
				}
			}
		} else if (o instanceof LinkedList) { // Special case for linked lists for efficiency
			for (Object o2 : (LinkedList<?>) o)
				traverse(new LinkedListFrame(o2));
		} else {
			for (; type != null; type = type.getSuperclass())
				for (Field f : getFields.perform(type)) 
					traverse(new FieldFrame(f, o));
		}
		path.pop();
	}
}
