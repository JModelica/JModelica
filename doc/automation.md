# Automation: CI/CD and Jules

How this repository builds itself, releases itself, and turns its own issues
into pull requests — and what a maintainer has to do by hand to switch that on.

---

## 1. What runs, and when

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | push, pull request | Repository hygiene, then real builds of the compiler, runtime and Python layers on Linux, macOS and Windows |
| `docker.yml` | push, tag, pull request | Multi-architecture container images (`linux/amd64`, `linux/arm64`) to GHCR |
| `release.yml` | tag `v*` or a tag starting with a digit, manual | Self-contained portable bundles per platform, attached to a GitHub release |
| `jules-issue.yml` | `jules` label, `/jules` comment, manual | Hands one issue to Jules, which opens a pull request |
| `jules-sweep.yml` | daily 04:00 UTC | Hands the oldest untouched issues to Jules, a few at a time |
| `jules-branches.yml` | weekly Monday 05:00 UTC | Surveys every branch, opens draft pull requests, hands them to Jules to finish |
| `jules-ci-fix.yml` | any workflow failing; daily 05:00 UTC | Hands the failure to Jules, which owns keeping the Actions tab green |
| `jules-shepherd.yml` | every 3 hours | Follows up the sessions the others start: answers them, relays CI on their pull requests, reports the ones that end with nothing |

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

The workflows address the repository as `sources/github/{owner}/{repo}`, the
form the API quickstart documents; the API reference instead shows
`sources/github-{owner}-{repo}`. The first form is confirmed working here — the
session for issue #24 on 2026-09-07 was created with it — but check what your
account returns if handovers start failing:

```sh
curl -s -H "x-goog-api-key: $JULES_API_KEY" \
  https://jules.googleapis.com/v1alpha/sources | jq -r '.sources[].name'
```

`jules-preflight.yml` runs that check from the Actions tab. If the result uses
the hyphenated form, change the `source` in `.github/actions/jules-session`.

### Step 4 — the starting branch

Every Jules workflow starts from the repository's default branch, `master`,
which carries the modernized build since `feature/modernization-checkpoint` was
merged into it. To start somewhere else, set:

```sh
gh variable set JULES_STARTING_BRANCH --body some-branch --repo JModelica/JModelica
```

If this variable is still set to `feature/modernization-checkpoint` from the
earlier setup, delete it (`gh variable delete JULES_STARTING_BRANCH`): that
branch is frozen, and pull requests against it land nowhere.

### Step 5 — create the control labels

```sh
gh label create 'jules'        --description 'Hand this issue to Jules' --color 5319E7
gh label create 'jules:queued' --description 'Already handed to Jules'  --color C5DEF5
gh label create 'jules:skip'   --description 'Never hand this to Jules' --color EEEEEE
```

`jules:stuck` is created by the workflows the first time they need it.

## 3. Using it

**One issue, on demand.** Add the `jules` label, or comment `/jules` on it —
optionally with extra direction, e.g. `/jules fix this on master instead`. Only
users with write access can trigger it; the issue body becomes the prompt for an
agent that writes code, so an untrusted trigger is an untrusted instruction.

**The backlog, automatically.** `jules-sweep.yml` runs daily and picks up the
oldest open issues that carry none of `jules:skip`, `jules:stuck`, `wontfix`,
`duplicate` or `question`. Each becomes a Jules session; each session that
produces a real change opens a pull request.

A handover expires. An issue labelled `jules:queued` with no open pull request
mentioning it is handed over again once its last handover is
`JULES_REQUEUE_DAYS` old (default 7). After `JULES_MAX_ATTEMPTS` handovers
(default 3) it gets `jules:stuck` and a comment asking a maintainer to decide.
The attempts are counted from the handover comments on the issue. Before this,
`jules:queued` was permanent: a session that stalled left its issue parked for
good, and by September 2026 every open issue was parked and the sweep selected
nothing each day.

**Following the sessions up.** Jules pauses when it wants an answer or a plan
approval, and a paused session nobody answers never finishes. Nor does Jules
see CI on its own pull requests, and it only acts on pull request comments from
the person who started the task. `jules-shepherd.yml` covers all of that
through the API, for sessions the automation started: those whose title starts
with `auto:`, the prefix every workflow here gives its sessions, and older
untitled ones whose prompt opens the way the workflow prompts do. Sessions you
start by hand are left alone:

- a plan awaiting approval is approved;
- a question is answered with "decide and finish; put anything that needs a
  maintainer under *Needs a decision* in the pull request", at most
  `JULES_SHEPHERD_MAX_NUDGES` times (default 3);
- red CI on its open pull request is relayed to the session once per commit, at
  most `JULES_SHEPHERD_MAX_RELAYS` times (default 5). Checks that also fail on
  the base branch are named as not the pull request's, so Jules does not widen
  the change to fix them;
- a session that started from a branch since merged into the default branch,
  or deleted, is archived and its issue released for the next sweep: its pull
  request would target a dead base;
- a session that ends without a pull request is reported on its issue. A failed
  one releases the issue for the next sweep; one that completed — Jules decided
  nothing should change — gets `jules:stuck`, with Jules's last message quoted.

Handled sessions are archived, which is how the shepherd knows not to handle
them twice. The run summary lists every session and what was done about it,
which makes it the quickest place to see what Jules is up to. Set
`JULES_SHEPHERD_ENABLED` to `false` to pause it.

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

### Keeping the Actions tab green

Jules owns the health of <https://github.com/JModelica/JModelica/actions>. When
any of `CI`, `Container images` or `Release` goes red, `jules-ci-fix.yml` hands
the failure over to be diagnosed and fixed.

The hard part is not triggering — it is triggering *once*. The build is
currently expected to fail, so a naive "on failure" trigger would start a
session on every push and drain the day's quota within the hour, most of them
working on the same problem in parallel. Three guards prevent that:

1. **Deduplication by commit.** A commit handed over within
   `JULES_CI_FIX_RETRY_HOURS` (default 72) is not handed over again, however
   many workflows it broke. After that, if it is still red, it is: one session
   that came to nothing must not leave a branch red for good.
2. **A daily budget.** At most `JULES_CI_FIX_DAILY_MAX` handovers per rolling
   24 hours, default 3, counted as distinct commits.
3. **Open-work check.** If a Jules pull request against *the branch that broke*
   was active within the retry window, Jules is already working; no second
   session starts. Jules opens pull requests under the account that owns the
   API key, so they are recognised by the task link in their description rather
   than by author.

The ledger for guards 1 and 2 is this workflow's own run history, and only runs
whose handover step actually succeeded count. The handover job is named
`Hand over <commit>`, which is how the ledger knows which commit a run handed
over. An earlier version counted every run that was not skipped. A run whose
guards *decline* still concludes `success`, so the declines filled the budget
and then, for commit `22c5b14`, counted as that commit's handover: master was
red from 2026-09-08 and no session was ever started for it.

`workflow_run` only fires when CI runs, and CI only runs on a push, so a red
branch nobody pushes to would never be looked at again. A daily scheduled run
therefore checks the latest `CI` and `Container images` results on the default
branch and goes through the same guards.

```sh
gh variable set JULES_CI_FIX_DAILY_MAX --body 5
gh variable set JULES_CI_FIX_RETRY_HOURS --body 48
gh variable set JULES_CI_FIX_ENABLED --body false   # pause it entirely
```

The prompt is explicit about what a fix may not be. Jules is told not to
disable a test, add `continue-on-error`, lower a warning level, delete an
assertion, drop a failing platform from the matrix, or relax the artifact
guard. Each of those turns a real signal into a false one, which is worse than
the red build it started from. Where the honest answer is that a failure cannot
be fixed in one session, it is told to push what it has and say what is left.

The prompt also tells Jules that the session is unattended. That is not a
courtesy — a session that ends on "which approach would you prefer?" leaves the
branch exactly as red as it found it, and nobody is subscribed to answer. It is
told to decide, justify the decision in one line, and put anything that
genuinely needs a maintainer into the pull request description under a
"Needs a decision" heading, where a human will see it.

This is also why the CI jobs are gated on `detect` rather than exiting early:
a build job that finds no build system, exits 0 and reports green would teach
exactly the wrong lesson. Those jobs show as *skipped* instead, which is
visually distinct from success and cannot be mistaken for a passing build.

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

Sessions are created by `.github/actions/jules-session`, a local composite
action, rather than by `google-labs-code/jules-action`. That action called curl
without `--fail`, so a refused request printed an error and the step went green;
it discarded the response, so the session could not be followed up; and it ran
`actions/checkout` inside the caller's job, wiping its workspace. The local
action sends the same payload, fails on an HTTP error, and returns the session
name and URL. The API key reaches curl through a header read from the
environment, never on a command line.

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

`release.yml` has never run. That is the trigger working as specified, not a
fault: it fires on a tag, and the repository carries exactly one tag — `2.14`,
inherited from upstream and pushed long before this workflow existed. Nothing
has been tagged since, and nothing has been dispatched by hand. It will stay
that way until the compiler and runtime stages can succeed, because a release
run that dies at the build produces no bundle and tells you nothing you did not
already know from CI. Tag, or dispatch it, once `AGENTS.md` section 3 is clear.

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
