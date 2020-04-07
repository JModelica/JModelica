def call(command, extraBat="", returnStdout = false, bitness = 64) {
    writeFile file:'run.sh', text:"""\
#!/bin/bash
cd "${unixpath(pwd())}"
${command}
"""
    def output = bat returnStdout:returnStdout, script:"""\
${returnStdout ? '@echo off' : ''}
${extraBat}
set WORKSPACE=${pwd()}
IF NOT DEFINED JMODELICA_HOME set JMODELICA_HOME=%WORKSPACE%/install
set SDK_HOME=${resolveSDK()}
call %SDK_HOME%\\setenv.bat ${bitness}
%SDK_HOME%\\MinGW\\msys\\1.0\\bin\\sh --login "${pwd()}\\run.sh"
"""
    if (returnStdout) {
        // Need to split due to output of "Welcome to MSYS shell..."
        String[] outputSplit = output.trim().split("\\r?\\n", 2)
        if (outputSplit.length >= 2) {
            output = outputSplit[1]
        }
    }
    return output
}
