def call(base, url) {
    if (!url.startsWith(base)) {
        throw new IllegalArgumentException("${url} does not start with ${base} as expected!")
    }
    def path = url.substring(base.length())
    def matcher = path =~ /^\/*(trunk|(branches|tags)\/+([^\/]+))\/?/
    if (!matcher.find()) {
        throw new IllegalArgumentException("Unable to determine trunk, branch or tag from the path ${path} in url ${url}!");
    }
    def basePath = matcher.group(1)
    // Is it trunk, tags or branches:
    def type = matcher.group(1).equals("trunk") ? matcher.group(1) : matcher.group(2)
    // What is the name of the branch or tag:
    def name = matcher.group(1).equals("trunk") ? matcher.group(1) : matcher.group(3)
    return [basePath, type, name]
}