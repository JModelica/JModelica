#include <string>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#ifdef linux
#include <dlfcn.h>
#endif
#include <jni.h>

#include "JCCEnv.h"
#include "initjcc.h"


using namespace std;


_DLL_EXPORT JCCEnv *env = NULL;
JavaVM *jvm;
JNIEnv *vm_env;

static const char *getenv_checked(const char *name) {
    const char *value = getenv(name);
    if (value == NULL) {
        throw std::runtime_error(string("Environment variable ") + name + " not set");
    }
    return value;    
}

jint initJVM()
{
    string jmhome = string(getenv_checked("JMODELICA_HOME"));    
    string mclib;
    try {
        mclib = string(getenv_checked("CASADI_INTERFACE_HOME"));
    } catch (std::runtime_error& e) {
        mclib = jmhome + "/lib/casadi_interface";
    }
    
    string mcjar = mclib + "/ModelicaCompiler.jar";
    string ocjar = mclib + "/OptimicaCompiler.jar";
    string utiljar = mclib + "/util.jar";
    string classpath = mcjar + CLASSPATH_SEP + ocjar + CLASSPATH_SEP + utiljar;
    string casadilib;
    try {
        casadilib = string(getenv_checked("CASADI_LIB_HOME"));
    } catch (std::runtime_error& e) {
        casadilib = jmhome + "/ThirdParty/CasADi/lib";
    }
    string libpath = mclib + CLASSPATH_SEP
                   + casadilib;
    
    return initJVM(classpath.data(), libpath.data());
}

jint initJVM(const char *classpath, const char *libpath)
{
    // ----------------------------- Load jvm.dll -----------------------------

    //     ---------------- Windows ----------------
#if defined(_MSC_VER) || defined(__WIN32)
    string jvmpath = string(getenv_checked("JPYPE_JVM"));

    HINSTANCE hVM = LoadLibrary(jvmpath.data());
    if (hVM == NULL) {
        throw std::runtime_error(string("Failed to load ") + jvmpath);
    }

    typedef jint (CALLBACK *fpCJV)(JavaVM**, void**, JavaVMInitArgs*);
    typedef jint (CALLBACK *fpGDJVA)(JavaVMInitArgs*);
    fpCJV CreateJavaVM = (fpCJV)::GetProcAddress(hVM, "JNI_CreateJavaVM");
    fpGDJVA GetDefaultJavaVMInitArgs = (fpGDJVA)::GetProcAddress(hVM, "JNI_GetDefaultJavaVMInitArgs");

#endif

    //     ---------------- Linux ----------------
#ifdef linux
    string jvmpath = string(getenv_checked("JAVA_HOME")) + "/jre/lib/i386/server/libjvm.so";

    void* handle = dlopen(jvmpath.data(), RTLD_LAZY);
    if (handle == NULL) {
        // Todo: There should be a better way to locate libjvm.so!
        string jvmpath2 = string(getenv_checked("JAVA_HOME")) + "/jre/lib/amd64/server/libjvm.so";
        handle = dlopen(jvmpath2.data(), RTLD_LAZY);

        if (handle == NULL) {
            throw std::runtime_error(string("Failed to load ") + jvmpath + " or " + jvmpath2);
        }
    }

    typedef jint (*fpCJV)(JavaVM**, void**, JavaVMInitArgs*);
    typedef jint (*fpGDJVA)(JavaVMInitArgs*);
    fpCJV CreateJavaVM = (fpCJV)dlsym(handle, "JNI_CreateJavaVM");
    fpGDJVA GetDefaultJavaVMInitArgs = (fpGDJVA)dlsym(handle, "JNI_GetDefaultJavaVMInitArgs");
#endif

    if (CreateJavaVM == NULL) {
        throw std::runtime_error("Failed to locate entry point JNI_CreateJavaVM");
    }
    if (GetDefaultJavaVMInitArgs == NULL) {
        throw std::runtime_error("Failed to locate entry point JNI_GetDefaultJavaVMInitArgs");
    }


    // ----------------------------- Start JVM --------------------------------
        
    JavaVMInitArgs vm_args;
    vm_args.version = JNI_VERSION_1_4;
    GetDefaultJavaVMInitArgs(&vm_args);

    vm_args.nOptions = 3;
    JavaVMOption* options = new JavaVMOption[vm_args.nOptions];
    string classpathopt = string("-Djava.class.path=") + classpath;
    string libpathopt = string("-Djava.library.path=") + libpath;
    options[0].optionString = (char *)classpathopt.data();
    options[1].optionString = (char *)libpathopt.data();

    options[2].optionString = (char *)"-Xmx600M";
    
    vm_args.options = options;
    vm_args.ignoreUnrecognized = false;
  
    jint res = CreateJavaVM(&jvm, (void**)&vm_env, &vm_args);
    delete[] options;

    if (res < 0) {
        throw std::runtime_error("Failed to create Java VM");
    }

    env = new JCCEnv(jvm, vm_env);
    return vm_env->GetVersion();
}

void destroyJVM() {
    delete env;
    env = NULL;
    jvm->DestroyJavaVM();
}
