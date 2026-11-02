<!--
Automated agents: AGENTS.md section 5 is binding. The `meta` CI job rejects
build artifacts and absolute symlinks mechanically, before a human looks at this.
-->

## What this changes

<!-- The root cause and the fix. Not a restatement of the diff. -->

Fixes #

## How it was verified

<!--
Paste the actual commands and their output. If you could not build or could not
test, say so here explicitly — that is useful information, and claiming a
verification that did not happen is not.
-->

```
```

## Checklist

- [ ] No build artifacts committed (generated `.c`, installed trees, `*.o`, `*.so`, `*.dll`, `*.jar`, `*.class`, `*.fmu`)
- [ ] No symlinks pointing at absolute paths
- [ ] No whitespace-only or line-ending changes to files not otherwise edited
- [ ] No hard-coded absolute paths, and no assumption of x86_64
- [ ] Scratch and debug files removed
- [ ] A regression test covers this, or the description says why one is not possible

## Anything left unverified

<!--
State it plainly. A known gap that is written down is a smaller problem than one
a reviewer has to discover.
-->
