def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, TARGET, bitness=["32", "64"], BLAS_HOME_BASE=null, LAPACK_HOME_BASE=null, SUPERLU_HOME_BASE=null, SUNDIALS_HOME_BASE=null,stash=false, archive=true) {
    if (JM_CHECKOUT_PATH != null) {
        checkoutJM(${JM_BRANCH})
    }
    INSTALL_PATH_UNIX=unixpath("${INSTALL_PATH}")
    if (BLAS_HOME_BASE == null) {
        BLAS_HOME_BASE="${INSTALL_PATH_UNIX}/blas_install"
    }

    if (LAPACK_HOME_BASE == null) {
        LAPACK_HOME_BASE="${INSTALL_PATH_UNIX}/lapack_install"
    }

    if (SUPERLU_HOME_BASE == null) {
        SUPERLU_HOME_BASE="${INSTALL_PATH_UNIX}/superlu_install"
    }

    if (SUNDIALS_HOME_BASE == null) {
        SUNDIALS_HOME_BASE="${INSTALL_PATH_UNIX}/sundials_install"
    }
    for (bit in bitness) {
        stage ("assimulo_${TARGET} ${bit} bit") {
            runMSYSWithEnv("""\
            export JM_HOME="\$(pwd)/JModelica/"
            JENKINS_BUILD_DIR="\$(pwd)/build"
            cd \${JM_HOME}/external/build_externals/build/assimulo
            
            make clean BUILD_DIR=\${JENKINS_BUILD_DIR}/assimulo* BITNESS=${bit}
            make ${TARGET} USER_CONFIG=\${JM_HOME}/external/build_externals/configurations/Assimulo/windows/win${bit} JM_HOME=\${JM_HOME} BUILD_DIR=\${JENKINS_BUILD_DIR} BLAS_HOME=${BLAS_HOME_BASE}${bit} SUNDIALS_HOME=${SUNDIALS_HOME_BASE}${bit} LAPACK_HOME=${LAPACK_HOME_BASE}${bit} SUPERLU_HOME=${SUPERLU_HOME_BASE}${bit} INSTALL_DIR_FOLDER=${INSTALL_PATH_UNIX}/assimulo/${TARGET}/Python_${bit}
            """);
            if ("${TARGET}" == "folder") {
                runMSYSWithEnv("""\
                export JM_HOME="\$(pwd)/JModelica/"
                nosetests ${INSTALL_PATH_UNIX}/assimulo/${TARGET}/Python_${bit}/folder/assimulo/tests/*.py
                """, "", false, bit); 
            }
            if (stash || archive) {
                dir("${INSTALL_PATH}/assimulo/${TARGET}") {
                    if (stash) {
                        stash includes: "Python_${bit}/**", name: "Python_${bit}_assimulo_${TARGET}"
                    }
                    if (archive) {
                        archiveArtifacts artifacts: "Python_${bit}/**", fingerprint: false
                    }
                }
            }
        }
    }
}