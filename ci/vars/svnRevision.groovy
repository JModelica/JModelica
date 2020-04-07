def call(path) {
    print "Getting svn revision for path ${path}";
    def infoStr = bat returnStdout: true, script: """\
@echo off
"${resolveSDK()}\\Subversion\\bin\\svn.exe" info --xml "${path}"
""";
    def m = infoStr =~ /(?m)^\s+revision="([0-9]+)">$/;
    m.find(); // Fail fast :D
    try {
        return Integer.parseInt(m.group(1));
    } catch (e) {
        print "Failed to get revision, output:"
        print infoStr;
        throw e;
    }
}
