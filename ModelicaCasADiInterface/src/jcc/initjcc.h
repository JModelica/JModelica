#ifndef __initjcc_h
#define __initjcc_h

#include <jni.h>  // JCCENv.h seems to be missing jni.h
#include "JCCEnv.h"


#ifdef linux
#define CLASSPATH_SEP ":"
#endif
#if defined(_MSC_VER) || defined(__WIN32)
#define CLASSPATH_SEP ";"
#endif


jint initJVM();
jint initJVM(const char *classpath, const char *libpath=NULL);
void destroyJVM();


extern _DLL_EXPORT JCCEnv *env;
extern JavaVM *jvm;
extern JNIEnv *vm_env;

#endif
