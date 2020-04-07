#include <stdarg.h>
#include "ModelicaUtilities.h"

void createVFormatMessage(const char* format, ...)
{
    va_list arg_ptr;
    va_start(arg_ptr, format);
    ModelicaVFormatMessage(format, arg_ptr);
    va_end(arg_ptr);
}

void createVFormatError(const char* format, ...)
{
    va_list arg_ptr;
    va_start(arg_ptr, format);
    ModelicaVFormatError(format, arg_ptr);
    va_end(arg_ptr);
}

void testModelicaMessage()
{   
    ModelicaMessage("Hello from testModelicaMessage\n");
}


void testModelicaFormatMessage()
{
    char msg[] = "testModelicaFormatMessage\n";
    ModelicaFormatMessage("Hello from %s", msg);
}

void testModelicaVFormatMessage()
{
    char msg[] = "testModelicaVFormatMessage\n";
    char fmt[] = "Hello from %s";
    createVFormatMessage(fmt, msg);
}

void testModelicaError()
{
    ModelicaError("Hello from testModelicaError\n");
}

void testModelicaFormatError()
{
    char msg[] = "testModelicaFormatError\n";
    ModelicaFormatError("Hello from %s", msg);
}

void testModelicaVFormatError()
{
    char msg[] = "testModelicaVFormatError\n";
    char fmt[] = "Hello from %s";
    createVFormatError(fmt, msg);
}

void testModelicaAllocateString()
{
    char* word = ModelicaAllocateString(sizeof("Hello"));
}

void testModelicaAllocateStringWithErrorReturn()
{
    char* word = ModelicaAllocateStringWithErrorReturn(sizeof("Hello"));
}

double testModelicaMessages(double a)
{
    testModelicaMessage();
    testModelicaFormatMessage();
    testModelicaVFormatMessage();
    return a + 1;
}

void testModelicaErrorMessages()
{
    testModelicaError();
    testModelicaFormatError();
    testModelicaVFormatError();
}

void testModelicaAllocateStrings()
{
    testModelicaAllocateString();
    testModelicaAllocateStringWithErrorReturn();
}

