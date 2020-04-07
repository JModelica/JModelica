package org.jmodelica.util;

import java.lang.reflect.Array;

public class ArrayUtil {

    @SafeVarargs
    public static <T> T[] concat(T[] first, T[]... rest) {
        int len = first.length;
        for (T[] part : rest) {
            len += part.length;
        }
        
        Class<?> type = first.getClass().getComponentType();
        @SuppressWarnings("unchecked")
        T[] res = (T[]) Array.newInstance(type, len);
        
        System.arraycopy(first, 0, res, 0, first.length);
        int pos = first.length;
        for (T[] part : rest) {
            System.arraycopy(part, 0, res, pos, part.length);
            pos += part.length;
        }
        
        return res;
    }

    @SafeVarargs
    public static <T> T[] append(T[] arr, T... vals) {
        return concat(arr, vals);
    }

}
