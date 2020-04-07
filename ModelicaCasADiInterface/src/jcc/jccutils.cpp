#include <iostream>
#include <stdexcept>
#include <jni.h>

#include "initjcc.h"
#include "jccutils.h"

using namespace java::lang;

// Returns the stack trace of a Java exception.
static std::string getStackTraceString(jthrowable exception) {
    jclass swClass = vm_env->FindClass("java/io/StringWriter");
    jmethodID swConstructor = vm_env->GetMethodID(swClass, "<init>", "()V");
    jobject sw = vm_env->NewObject(swClass, swConstructor);
    jclass pwClass = vm_env->FindClass("java/io/PrintWriter");
    jmethodID pwConstructor = vm_env->GetMethodID(pwClass, "<init>", "(Ljava/io/Writer;)V");
    jobject pw = vm_env->NewObject(pwClass, pwConstructor, sw);
	jclass exClass = vm_env->GetObjectClass(exception);
	jmethodID printStackTrace = vm_env->GetMethodID(exClass, "printStackTrace", "(Ljava/io/PrintWriter;)V");
	vm_env->CallObjectMethod(exception, printStackTrace, pw);
	jmethodID toString = vm_env->GetMethodID(swClass, "toString", "()Ljava/lang/String;");
	jstring message = (jstring) vm_env->CallObjectMethod(sw, toString);
	const char *mstr = vm_env->GetStringUTFChars(message, NULL);
    std::string trace = mstr;
    vm_env->ReleaseStringUTFChars(message, mstr);
    vm_env->DeleteLocalRef(pw);
    vm_env->DeleteLocalRef(pwClass);
    vm_env->DeleteLocalRef(sw);
    vm_env->DeleteLocalRef(swClass);
    vm_env->DeleteLocalRef(message);
    vm_env->DeleteLocalRef(exClass);
    return trace;
}

std::string describeAndClearJavaException(JavaError e) {
    jthrowable ex = vm_env->ExceptionOccurred();
    if (ex == NULL) {
        return "unknown Java exception (already cleared?)";
    }
    vm_env->ExceptionClear();
    std::string message = getStackTraceString(ex);
    vm_env->DeleteLocalRef(ex);
    return message;
}

void rethrowJavaException(JavaError e) {
    throw std::runtime_error(describeAndClearJavaException(e));
}

jstring fromUTF(const char *bytes) {
    return vm_env->NewStringUTF(bytes);
}
String StringFromUTF(const char *bytes) {
    return String(fromUTF(bytes));
}

JArray<String> new_JArray(const char *items[], int n) {
    String *itemsS = new String[n];
    for (int k=0; k < n; k++) itemsS[k] = StringFromUTF(items[k]);
    JArray<String> result = new_JArray<String>(itemsS, n);
    delete[] itemsS;
    return result;
}
