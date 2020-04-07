#ifndef __jccexception_h
#define __jccexception_h

#include <string>

typedef int JavaError; // Hopefully JCC will use a better type some day

// Returns a string containing the stack trace of the Java exception currently being thrown.
// If no exception is being thrown, returns the string "unknown Java exception (already cleared?)".
// Clears the currently thrown Java exception.
std::string describeAndClearJavaException(JavaError e);
void rethrowJavaException(JavaError e);

#endif
