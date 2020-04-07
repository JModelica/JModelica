def call(JM_SVN_PATH) {
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
}