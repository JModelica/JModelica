def call(command, returnStdout = false) {
	writeFile file :'run.sh', text:"""\
#!/bin/bash
cd ${WORKSPACE}
${command}
"""
    def output = sh returnStdout:returnStdout, script:"""\
export WORKSPACE=\${PWD}
if [ -z \$JMODELICA_HOME ]; then 
export JMODELICA_HOME=${WORKSPACE}/install
fi
chmod +x ${WORKSPACE}/run.sh
${WORKSPACE}/run.sh
"""
    return output
}