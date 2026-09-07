# Automation: CI/CD and Jules

How this repository builds itself, releases itself, and turns its own issues
into pull requests — and what a maintainer has to do by hand to switch that on.

---

## 1. What runs, and when

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | push, pull request | Repository hygiene, then real builds of the compiler, runtime and Python layers on Linux, macOS and Windows |
| `docker.yml` | push, tag, pull request | Multi-architecture container images (`linux/amd64`, `linux/arm64`) to GHCR |
| `release.yml` | tag `v*`, manual | Self-contained portable bundles per platform, attached to a GitHub release |
| `jules-issue.yml` | `jules` label, `/jules` comment, manual | Hands one issue to Jules, which opens a pull request |
| `jules-sweep.yml` | daily 04:00 UTC | Hands the oldest untouched issues to Jules, a few at a time |
| `jules-branches.yml` | weekly Monday 05:00 UTC | Surveys every branch, opens draft pull requests, hands them to Jules to finish |
| `jules-ci-fix.yml` | CI failure | Hands a failed CI run to Jules. **Off by default** |

## 2. Turning Jules on

Three steps. Only the first two are required, and both must be done by the
repository owner — neither can be automated, because the Jules GitHub App is
installed against a GitHub account and the API key is issued to a Google
account.

### Step 1 — install the Jules GitHub App

The API can only see repositories that the app has been granted. This is not
optional: without it, every workflow below fails at the point of creating a
session, regardless of whether the API key is valid.

1. Go to <https://jules.google.com> and sign in.
2. Connect GitHub, and grant access to `JModelica/JModelica` specifically.
3. Confirm afterwards under GitHub → Settings → Applications → **Google Labs
   Jules** → Configure that this repository is listed.

### Step 2 — add the API key

1. In the Jules web app, open **Settings** and create an API key. A Google
   account may hold at most three at a time.
2. Add it to the repository:

   ```sh
   gh secret set JULES_API_KEY --repo JModelica/JModelica
   ```

Keys found publicly exposed are disabled automatically by Google, so do not put
one in a workflow file, a comment, or an issue.

### Step 3 — verify the source name

Google's own documentation disagrees with Google's own action about how a
repository is addressed. The action builds `sources/github/{owner}/{repo}`,
matching the API quickstart; the API reference instead shows
`sources/github-{owner}-{repo}`. Check which one your account actually returns
before trusting the automation:

```sh
curl -s -H "x-goog-api-key: $JULES_API_KEY" \
  https://jules.googleapis.com/v1alpha/sources | jq -r '.sources[].name'
```

If the result uses the hyphenated form, the action cannot address this
repository and the workflows need a direct `curl` step against
`POST /v1alpha/sessions` instead — which is all the action does anyway. The
action is a thin composite wrapper around exactly one API call.

### Step 4 — set the starting branch

Every Jules workflow reads this. Without it they default to
`feature/modernization-checkpoint`, because `master` does not build and a fix
based on it would have nowhere useful to land.

```sh
gh variable set JULES_STARTING_BRANCH --body feature/modernization-checkpoint \
  --repo JModelica/JModelica
```

The action's own default is `main`, which does not exist here. That is why the
workflows always pass this explicitly.

### Step 5 — create the control labels

```sh
gh label create 'jules'        --description 'Hand this issue to Jules' --color 5319E7
gh label create 'jules:queued' --description 'Already handed to Jules'  --color C5DEF5
gh label create 'jules:skip'   --description 'Never hand this to Jules' --color EEEEEE
```

## 3. Using it

**One issue, on demand.** Add the `jules` label, or comment `/jules` on it —
optionally with extra direction, e.g. `/jules fix this on master instead`. Only
users with write access can trigger it; the issue body becomes the prompt for an
agent that writes code, so an untrusted trigger is an untrusted instruction.

**The backlog, automatically.** `jules-sweep.yml` runs daily and picks up the
oldest open issues that carry none of `jules:queued`, `jules:skip`, `wontfix`,
`duplicate` or `question`. Each becomes a Jules session; each session that
produces a real change opens a pull request.

Nothing is merged automatically. Jules opens pull requests; a human merges them.

### Controlling the spend

The free tier allows **15 tasks per rolling 24 hours and 3 concurrent
sessions**; Google AI Pro raises that to 100/15 and Ultra to 300/60. Those are
per-user limits, and API sessions are not documented as drawing from a separate
pool — assume they share it.

The sweep is therefore capped, and the cap is a variable rather than a constant
in a file:

```sh
gh variable set JULES_SWEEP_BATCH --body 3       # issues per daily run
gh variable set JULES_SWEEP_ENABLED --body false # pause the sweep entirely
```

`jules-ci-fix.yml` is off by default for the same reason. This repository's
build is currently expected to fail, so a CI-failure trigger would start a
session on every push and drain the day's quota within the hour:

```sh
gh variable set JULES_CI_FIX_ENABLED --body true   # only once CI is meaningful
```

### Maturing the old branches

This repository carried fifteen branches, most last touched in 2024, with no
record of which held finished work and which were abandoned mid-thought.
`jules-branches.yml` runs the whole set through one pipeline every Monday:

1. **Survey.** How far ahead of and behind master is each branch, how many files
   does it touch, and does it already have a pull request?
2. **Fully merged branches** — those with no commits master lacks — are listed
   in the run summary along with the `git push --delete` commands to remove
   them. They are reported, never deleted: that is irreversible and it is the
   owner's call.
3. **Branches with unique work and no pull request** get a **draft** one, so CI
   judges them on evidence instead of on anyone's recollection of what they were
   for.
4. **Jules is then handed the branch** and told to reach one of three outcomes:
   finish it and mark the pull request ready; push partial work with a clear
   statement of what is left; or identify it as obsolete, with the commit or
   file that supersedes it named as evidence.

Smallest diffs are taken first — they are the likeliest to be finishable, and
each one merged shrinks the conflict surface for the rest.

Nothing in this decides "mature enough to merge" on its own. CI produces the
evidence, Jules does the work, a human merges.

```sh
# Everything, as the schedule would
gh workflow run jules-branches.yml

# One branch, pull request only, no Jules session
gh workflow run jules-branches.yml \
  -f branches='wip/cmake' -f hand_to_jules=false
```

`master` and `feature/modernization-checkpoint` are excluded by the `PROTECTED`
list in the workflow.

#### One caveat worth knowing

A pull request opened with `GITHUB_TOKEN` does **not** trigger other workflows —
GitHub suppresses that to prevent recursion — so CI will not start on its own,
which defeats the point of step 3. To get automatic CI on these pull requests,
create a fine-grained personal access token with `contents: read` and
`pull-requests: write` and add it as `AUTOMATION_TOKEN`:

```sh
gh secret set AUTOMATION_TOKEN --repo JModelica/JModelica
```

Without it the workflow still works and says so in each pull request body; CI
then needs a push, or a close-and-reopen, to start.

### What Jules reads

`AGENTS.md` in the repository root, automatically, on every task. It is the
single place to change how the agent behaves — build commands, branch policy,
and the rules about what must never be committed. Keeping it accurate matters
more than any prompt in these workflows.

The build environment is configured **in the Jules web app**, not in this
repository: sidebar → the repository under *codebases* → **Configuration** →
*Initial Setup*. Put the dependency installation there and use **Run and
Snapshot**, which caches the result so that later tasks do not repeat a long
install. For this project that script should be roughly:

```sh
sudo apt-get update
sudo apt-get install -y build-essential gfortran cmake ninja-build swig \
  libsundials-dev libopenblas-dev liblapack-dev zlib1g-dev coinor-libipopt-dev
```

Jules VMs already provide gcc 13, clang 18, CMake, Ninja, JDK 21, Gradle and
Python 3.12, so only the project's own libraries need installing.

## 4. Security

The Jules action is pinned by commit SHA, not by tag. It receives the API key,
and a tag can be moved; a SHA cannot. Dependabot proposes updates weekly with
the new version named in the comment.

Note also that the README of `google-labs-code/jules-action` documents
`uses: google-labs-code/jules-invoke@v1`. Neither part of that resolves: `v1`
does not exist as a tag or a branch, and `jules-invoke` is the repository's
former name, working only through GitHub's rename redirect. The pinned SHA
`bff7875e` is tag `v1.0.0`.

Issue and comment text reaching an agent is treated as data, not instruction:
the prompts fence it explicitly and tell the agent to ignore directives found
inside it. That is mitigation, not a guarantee, which is why the write-access
check exists as well.

## 5. Artifacts

### Container images — working today

```sh
docker pull ghcr.io/jmodelica/jmodelica:latest
```

One tag, both architectures; `docker` resolves the right one for the host. This
is the project's most portable artifact and the only path that gets arm64 built
and tested, since it uses QEMU under `buildx` rather than depending on arm64
runner availability.

### Portable bundles — scaffolded, blocked on the build

`release.yml` produces one archive per platform through
`tools/package_portable.py`. Each is relocatable and self-contained: a minimal
Java runtime built with `jlink`, the compiler jars, the native runtime
libraries, the Python interface and the Modelica Standard Library. Unpack
anywhere, run `bin/jmodelica`, no installation and no system JDK.

The host must still provide a C compiler. That is inherent: compiling a Modelica
model to an FMU means compiling generated C. It is not a packaging shortfall,
and no amount of bundling removes it.

**These bundles cannot be produced yet.** The `jlink` stage works; the compiler
and runtime stages fail for the reasons in `AGENTS.md` section 3. The pipeline
is complete and correct — the source underneath it is not there yet, and that is
what the Jules automation above is pointed at.

`release.yml` builds every platform natively rather than cross-compiling,
because `jlink` emits a runtime only for the architecture of the JDK running it.
The extra architectures (`linux-aarch64`, `macos-x86_64`, `windows-aarch64`) are
behind a variable, because an unavailable runner label queues forever instead of
failing:

```sh
gh variable set ENABLE_EXTRA_RUNNERS --body true
```

Set it once you have confirmed those runner images are available to this
repository.

## 6. Branch protection

`meta` is the only job that should be required. It is fast, it passes today, and
it enforces what a reviewer would otherwise enforce by eye.

```sh
gh api -X PUT repos/JModelica/JModelica/branches/master/protection \
  -f 'required_status_checks[strict]=true' \
  -f 'required_status_checks[contexts][]=Repository hygiene' \
  -F 'enforce_admins=false' \
  -F 'required_pull_request_reviews=null' \
  -F 'restrictions=null'
```

Requiring the build jobs would block every pull request, including the ones
fixing the build.
