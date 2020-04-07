def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, TARGET, bitness=["32", "64"], FMIL_HOME_BASE=null, stash=false, archive=true) {
    if (JM_CHECKOUT_PATH != null) {
        checkoutJM(${JM_BRANCH})
    }
    INSTALL_PATH_UNIX=unixpath("${INSTALL_PATH}")
    if (FMIL_HOME_BASE == null) {
        FMIL_HOME_BASE="${INSTALL_PATH_UNIX}/fmil_install"
    }
    for (bit in bitness) {
        stage ("${TARGET} ${bit} bit") {
            runMSYSWithEnv("""\
            export JM_HOME="\$(pwd)/JModelica/"
            JENKINS_BUILD_DIR="\$(pwd)/build"
            cd \${JM_HOME}/external/build_externals/build/pyfmi
            make clean BUILD_DIR=\${JENKINS_BUILD_DIR} BITNESS=${bit}
            make ${TARGET} USER_CONFIG=\${JM_HOME}/external/build_externals/configurations/PyFMI/windows/win${bit} JM_HOME=\${JM_HOME} BUILD_DIR=\${JENKINS_BUILD_DIR} FMIL_INSTALL=${FMIL_HOME_BASE}${bit} INSTALL_DIR_FOLDER=${INSTALL_PATH_UNIX}/${TARGET}/Python_${bit}
            """);
            if ("${TARGET}" == "folder") {
               runMSYSWithEnv("""\
                export JM_HOME="\$(pwd)/JModelica/"
                nosetests \$(pwd)/install/folder/Python_${bit}/folder/pyfmi/tests/*.py
                ""","", false, bit); 
            }
            if (stash || archive) {
                dir("${INSTALL_PATH}/${TARGET}") {
                    if (stash) {
                        stash includes: "Python_${bit}/**", name: "Python_${bit}_pyfmi_${TARGET}"
                    }
                    if (archive) {
                        archiveArtifacts artifacts: "Python_${bit}/**", fingerprint: false
                    }
                }
            }
        }
    }
}
