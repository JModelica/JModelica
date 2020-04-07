package org.jmodelica.util.ccompiler;

/**
 * Describes how allocation of an element is performed in runtime
 * 
 * @author jonathan.kampe
 *
 */
public enum Dynamicity {
    /**
     * In the data section, using static keyword.
     */
    DATA,
    /**
     * On the stack.
     */
    STACK,
    /**
     * On the heap via the runtime memory pool.
     */
    HEAP;

    public boolean isHeap() {
        return this == HEAP;
    }
}
