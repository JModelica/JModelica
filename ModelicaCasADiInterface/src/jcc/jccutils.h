#ifndef __jccutils_h
#define __jccutils_h

#include <jni.h>

#include "JArray.h"

#include "java/lang/String.h"
#include "java/lang/Class.h"

#include "initjcc.h"
#include "jccexception.h"

::java::lang::String StringFromUTF(const char *bytes);
jstring fromUTF(const char *bytes); /* consider: will the returned jstring leak? */

// todo: Provide a varargs version instead
template <typename T>
JArray<T> new_JArray(T item) {
    JArray<T> array = JArray<T>((jobject)(env->newObjectArray(jclass(T::class$->this$), 1)));
    env->setObjectArrayElement((jobjectArray)array.this$, 0, jobject(item.this$));
    return array;
}

template <typename T>
JArray<T> new_JArray(T items[], int n) {
    JArray<T> array = JArray<T>((jobject)(env->newObjectArray(jclass(T::class$->this$), n)));
    for (int k=0; k < n; k++) {
        env->setObjectArrayElement((jobjectArray)array.this$, k, jobject(items[k].this$));
    }
    return array;
}

JArray< ::java::lang::String> new_JArray(const char *items[], int n);

#endif
