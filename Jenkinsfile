// This loads the Jenkins pipeline library found in the ci folder.
def url = scm.getLocations()[0].remote

library identifier: 'JModelica@ci', retriever: modernSCM([$class: 'SubversionSCMSource', remoteBase: url, credentialsId: ''])

if ("${JOB_NAME}".toLowerCase().contains("chicago")) {
    env.SDK_HOME = 'C:\\JModelica.org-SDK-1.13\\' // Hard-coded since new SDK release 1.4
    bitness = 32
} else {
    env.SDK_HOME = resolveSDK()
    bitness = 64
}

// Extract branch info from url variable (this assumes that this Jenkinsfile
// has been checked out directly by Jenkins as part of pipeline build).
(JM_SVN_PATH, JM_SVN_TYPE, JM_SVN_NAME) = extractBranchInfo("https://svn.jmodelica.org", url)

// Temporarily cannot upload to server 
boolean SHOULD_UPLOAD_INSTALL = false // JM_SVN_PATH.equals("trunk")

// Set build name:
currentBuild.displayName += " (" + (env.TRIGGER_CAUSE == null ? "MANUAL" : env.TRIGGER_CAUSE) + ")"

// Set discard policy
properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '5', daysToKeepStr: '', numToKeepStr: ''))])

node ("716KS42") {
    stage("Checkout JModelica.org") {
        checkout([
            $class: 'SubversionSCM',
            locations: [
                [local: 'JModelica', remote: "https://svn.jmodelica.org/${JM_SVN_PATH}"],
            ],
            workspaceUpdater: [$class: 'UpdateWithCleanUpdater'],
            quietOperation: true,
        ])
    }
    
    stage("Build install folder") {
        runMSYSWithEnv("""\
BUILD_CASADI=1
export IN_HEADLESS=1

export SRC_HOME="\$(pwd)/JModelica/"
export BUILD_HOME="\$(pwd)/build"
export INSTALL_HOME="\$(pwd)/install"

cd "${unixpath(resolveSDK())}"
echo ==== Run configure
./configure.sh

echo ==== Go to build and run make
cd "\${BUILD_HOME}"
make
make install
if [ "\${BUILD_CASADI:-1}" == "1" ]; then
    make casadi_interface
fi
""", """\
set BUILD_MODE=1
""", false, bitness)
    }
    stage("Archive") {
        archive 'install/**'
        
        if (SHOULD_UPLOAD_INSTALL) {
            // Prepare the ZIP for future upload
            jmRevision=svnRevision("JModelica")
            def zipName="JModelica.org-Chicago-win-r${jmRevision}.zip"
            def readMeContents = libraryResource 'installZip_README.TXT'
            writeFile file: 'README.TXT', text: readMeContents
            runMSYSWithEnv("""\
rm -f *.zip
zip -r -q "${zipName}" install README.TXT
""", """\
set BUILD_MODE=1
""", false, bitness)
            stash includes: '*.zip', name: 'installZip'
        }
    }
    
    stage("Run jm_tests") {
        try {
            runMSYSWithEnv("""\
TEST_RES_DIR=\${WORKSPACE}/testRes
mkdir -p "\${TEST_RES_DIR}"
install/jm_tests -ie -x "\${TEST_RES_DIR}"
""", """\
set BUILD_MODE=1
""", false, bitness)
        } finally {
            junit testResults: 'testRes/*.xml', allowEmptyResults: true
        }
    }
}
if (SHOULD_UPLOAD_INSTALL) {
    // We need to run on master since we need a linux server with ssh-agent support
    node ('master') {
        stage ('Upload') {
            deleteDir()
            sshagent(['jmodelica.org']) {
                unstash 'installZip'
                sh 'scp *.zip jenkins@jmodelica.org:/srv/www/htdocs/downloads/nightly-builds'
            }
            deleteDir()
        }
    }
}
