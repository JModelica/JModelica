String call(String windowsPath) {
    // This does:
    // Replace 'D:\' with '/D/'
    // Replace '\' with '/'
    // Revert back '/ ' to '\ ' (since previous rule changes '\ ' to '/ ' and one might have escaped the space
    // Replace '(' with '\(' and ')' with '\)'
    return windowsPath.replaceAll('^([A-Za-z]):\\\\', '/$1/').replaceAll('\\\\', '/')
            .replaceAll('/? ', '\\\\ ').replaceAll('([\\(\\)])', '\\\\$1')
}