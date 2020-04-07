def call(JM_CHECKOUT_PATH, JM_BRANCH, INSTALL_PATH, bitness=["32", "64"], stash=false, archive=true) {
    if (JM_CHECKOUT_PATH != null) {
        checkoutJM(${JM_BRANCH})
    }
    INSTALL_PATH_UNIX=unixpath("${INSTALL_PATH}")
    for (bit in bitness) {
        stage ("FMILibrary ${bit} bit") {
            runMSYSWithEnv("""\
            export JM_HOME="\$(pwd)/JModelica/"
            JENKINS_BUILD_DIR="\$(pwd)/build"
            cd \${JM_HOME}/external/build_externals/build/fmil
            rm -rf ${INSTALL_PATH_UNIX}/folder
            rm -rf ${INSTALL_PATH_UNIX}/wheel
            make clean_install USER_CONFIG=\${JM_HOME}/external/build_externals/configurations/FMILibrary/windows/win${bit} BUILD_DIR=\${JENKINS_BUILD_DIR} FMIL_INSTALL=${INSTALL_PATH_UNIX}/fmil_install${bit}
            """);
            if (stash || archive) {
                dir("${INSTALL_PATH}") {
                    if (stash) {
                        stash includes: "fmil_install${bit}/**", name: "fmil_install${bit}"
                    }
                    if (archive) {
                        archiveArtifacts artifacts: "fmil_install${bit}/**", fingerprint: false
                    }
                }
            }
        }
    }
}