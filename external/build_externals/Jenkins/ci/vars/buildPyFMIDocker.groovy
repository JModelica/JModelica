def call(PLATFORM, TARGET, USER_CONFIG) {
    stage("PyFMI ${TARGET} ${PLATFORM}") {
        
        def ARTIFACT_FILE="${WORKSPACE}/JModelica/artifacts_pyfmi"
        def MAKE_ARGS="JM_HOME=${WORKSPACE}/JModelica PATH_TO_MOUNT=${WORKSPACE}/JModelica USER_CONFIG=${USER_CONFIG} ARTIFACT_FILE=${ARTIFACT_FILE}"
        
        dir ('JModelica/external/build_externals/docker/src/components/PyFMI') {
            try{
                sh 'ls -la'
                sh "make docker_${TARGET} ${MAKE_ARGS}"
                dir("${WORKSPACE}/JModelica") {
                    artifact_list = sh returnStdout: true, script: "cat ${ARTIFACT_FILE}"
                    archiveArtifacts artifacts: artifact_list, fingerprint: false
                    sh "rm ${ARTIFACT_FILE}"
                }
                sh "make docker_test_${TARGET} ${MAKE_ARGS}"
            } finally {
                sh "make clean_in_docker ${MAKE_ARGS}"
            }
        }
    }
}