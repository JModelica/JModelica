package org.jmodelica.util.collections;

import java.util.HashMap;
import java.util.Stack;

public class HashStack<T> {
    
    private final Stack<T> stack = new Stack<T>();
    private final HashMap<T,Integer> counter = new HashMap<T,Integer>();
    
    
    public boolean empty() {
        counter.clear();
        return stack.empty();
    }

    public T peek() {
        return stack.peek();
    }

    public T pop() {
        T val = stack.pop();
        if (val == null) {
            return val;
        }
        int count = counter.get(val) - 1;
        if (count == 0) {
            counter.remove(val);
        } else {
            counter.put(val, count);
        }
        return val;
    }

    public T push(T item) {
        Integer count = counter.get(item);
        if (count == null) {
            count = 1;
        } else {
            count++;
        }
        counter.put(item, count);
        return stack.push(item);
    }

    public boolean contains(Object o) {
        return counter.containsKey(o);
    }

}
