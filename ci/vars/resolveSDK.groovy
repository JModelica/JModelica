def call() {
    if (env.SDK_HOME) {
        return env.SDK_HOME
    } else {
        return 'C:\\JModelica.org-SDK-1.14\\'
    }
}