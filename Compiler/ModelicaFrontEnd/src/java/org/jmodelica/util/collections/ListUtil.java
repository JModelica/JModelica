package org.jmodelica.util.collections;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Utility methods for {@link java.util.List List}s.
 */
public final class ListUtil {

    /**
     * Hidden default constructor to prevent instantiation.
     */
    private ListUtil() {}

    /**
     * Creates a new immutable list with initial list elements.
     * 
     * @param <T>       the type of elements the list contains.
     * @param elements  the elements.
     * @return          a {@link java.util.List List} containing {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.List<T> unmodifiableList(T... elements) {
        return Collections.unmodifiableList(create(elements));
    }

    /**
     * Creates a new list with initial list elements.
     * 
     * @param <T>       the type of elements the list contains.
     * @param elements  the elements.
     * @return          a {@link java.util.List List} containing {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.List<T> create(T... elements) {
        java.util.List<T> list = new ArrayList<T>();
        for (T element : elements) {
            list.add(element);
        }
        return list;
    }

    /**
     * Creates a list of strings from the string representation of elements.
     * 
     * @param <T>       the type of elements the list contains.
     * @param elements  the elements.
     * @return          a {@link java.util.List List} containing the string representation of {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.List<String> stringList(T... elements) {
        java.util.List<String> strings = new ArrayList<String>();
        for (T element : elements) {
            strings.add(element.toString());
        }
        return strings;
    }
    
    /**
     * Converts an {@link Iterable} to a {@link List}.
     * 
     * @param <T>
     *            The type of element in the iterable.
     * @param iterable
     *            The iterable which elements to put in the list.
     * @return
     *         a list containing all the elements in {@code iterable}.
     */
    public static <T> List<T> list(Iterable<T> iterable) {
        List<T> list = new ArrayList<T>();
        for (T element : iterable) {
            list.add(element);
        }
        return list;
    }
    
    /**
     * Short-hand method for creating a list with predefined contents.
     * 
     * @param <T>
     *            The type of elements in the list.
     * @param ts
     *            The elements to put in the list.
     * @return
     *         a {@link List} containing the {@code T}-type elements {@code ts}.
     */
    @SafeVarargs
    public final static <T> List<T> list(T... ts) {
        return Arrays.asList(ts);
    }

    /**
     * Create a new list that is the concatenation of the given lists, in the order given.
     * 
     * @param lists  any number of lists to concatenate
     * @return       a newly created ArrayList that contains the concatenation of the given lists
     */
    @SafeVarargs
    public static <T> ArrayList<T> concatenate(List<T>... lists) {
        int size = 0;
        for (List<T> list : lists) {
            size += list.size();
        }
        ArrayList<T> res = new ArrayList<T>(size);
        for (List<T> list : lists) {
            res.addAll(list);
        }
        return res;
    }
}
