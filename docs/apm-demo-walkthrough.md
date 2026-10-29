# APM Demo Walkthrough

This walkthrough demonstrates APM as the package manager and compiler for this repository's AI-agent harness. It is designed for a mixed audience: people evaluating APM, platform engineers, and engineering leaders. You will trace configuration from declaration to runtime files, then use the harness for one read-only Kubernetes review.

**What this demo can show:** how a manifest and lockfile make agent setup easier to share and reproduce across supported runtimes, and how shared packages combine with repository-specific platform guidance.

**What it cannot prove:** that APM makes a model smarter or guarantees identical answers across runtimes. APM manages and compiles agent configuration; the selected runtime and model execute the task.

## 1. Start from a clean clone

Install the APM CLI and at least two of the runtimes you want to compare. Follow the [repository prerequisites](../README.md#prerequisites), then use a fresh clone:

```bash
git clone https://github.com/dazmc/k8s-platform.git
cd k8s-platform
apm install --frozen
apm compile
```

The frozen install replays the dependency versions recorded in `apm.lock.yaml`; compile generates files for the runtimes declared by the project. Run this from a clean clone so prior local edits do not affect what you show.

## 2. Trace one dependency through APM

Open `apm.yml` and find the `thinkjones/awesome-apm-stacks/user-core` dependency. The lockfile stores the repository and package name in separate fields, so inspect its `user-core` entry:

```bash
grep -n 'thinkjones/awesome-apm-stacks/user-core' apm.yml
grep -n -A 7 'name: user-core' apm.lock.yaml
```

Show the audience the three parts of the flow:

1. **Manifest (`apm.yml`)** declares the package and target runtimes (`claude`, `copilot`, and `opencode`).
2. **Lockfile (`apm.lock.yaml`)** records the resolved dependency graph and pinned source content, so teammates can install the same package versions.
3. **Compiled configuration** makes agent instructions and skills available in runtime-specific layouts.

Inspect representative generated and hand-written files:

```bash
find .agents/skills -maxdepth 2 -name SKILL.md | head
find .claude .github -maxdepth 2 -type f | head
find .opencode -maxdepth 2 -type f | sort | head -40
git status --short
```

The exact generated files depend on the targets and packages. In this repository, APM-generated outputs include `.agents/`, `.claude/`, `.github/`, and compiled instruction files such as `AGENTS.md` and `CLAUDE.md`. Do not hand-edit compiled outputs; change the manifest or the source instructions and compile again.

## 3. Separate shared packages from this repo's platform guidance

Use this task to show how the layers combine, rather than describing APM in isolation:

1. **APM manifest and lockfile:** `apm.yml` declares the reusable stacks and runtime targets; `apm.lock.yaml` records the resolved package versions and content.
2. **Compiled agent setup:** `apm compile` generates configuration and distributes selected guidance to supported runtimes. These generated files are outputs, not the source to edit.
3. **Repository context:** the repo supplies its own platform files, including the AKS scaffold and its design notes. OpenCode additionally loads the three hand-written instruction files listed in `opencode.json`; they give it local conventions but are not automatically loaded by Claude Code or Copilot.
4. **Task and response:** you provide a task prompt, such as the review below. The runtime and model use the files and guidance available to them to produce a response. APM prepares the agent setup; it does not perform the review or operate the cluster.

The relationship is: **APM-selected guidance + repository-specific context + your task prompt → runtime/model response.** The same prompt can produce different answers across runtimes and models, and some repo guidance is OpenCode-specific. The demo shows how APM distributes agent setup and how that setup can be used with a real repo task; it does not establish that APM improves answer quality or makes outputs identical.

## 4. Run the same read-only Kubernetes task in two runtimes

Choose any two installed runtimes supported by this repo. In each, use the same prompt and inspect the same committed scaffold:

> Review `terraform/azure/prod/` and `docs/clusters/aks-prod-eastus.md` as an unapplied AKS demo scaffold. Give the three most important reliability, security, or operational gaps, with file and line references. Separate existing design decisions from documented Day-1 follow-ups. Do not run Terraform, access a cloud account or cluster, or propose applying changes.

The target is a **read-only review of repository files**. Do not run `terraform plan` or `terraform apply`; do not connect to Azure or a Kubernetes cluster. The scaffold's design notes describe it as approved and scaffolded, not applied.

For the demo, a useful response should identify three concrete gaps, cite the source file and line for each, and distinguish implemented design choices from future Day-1 work. The response is the runtime/model's work product; the APM contribution is the reusable and project-specific setup that was available to inform it.

Compare observations rather than expecting identical wording:

| What to compare | Record |
|---|---|
| Setup | Did the runtime load the expected shared skills and platform-specific instructions? |
| Provenance | Can you identify which guidance came from APM packages and which came from repository instructions? |
| Review criteria | Did it respect the read-only boundary, distinguish current design from follow-ups, and provide checkable file/line references? |
| Differences | What did each runtime omit, emphasize, or interpret differently? |

This is a small, illustrative comparison, not a controlled benchmark. Runtime, model, configuration, and session context may differ. Report what happened in this run; do not infer that APM guarantees better output or identical behavior.

## 5. Show the boundary of APM's value

Summarize the result in three layers:

| Layer | Responsibility |
|---|---|
| APM | Declares and resolves reusable agent packages, pins them in the lockfile, and compiles configuration for selected runtimes. |
| Repository harness | Adds platform conventions, task-specific instructions, and examples such as the AKS scaffold. |
| Runtime and model | Load the configuration and perform the requested work; outputs can vary. |

The most defensible APM value to demonstrate is repeatability and distribution of agent setup—not an automatic increase in answer quality. The AKS Terraform is a harness demo artifact and is **not deployed**.

## Optional variation: change configuration, not infrastructure

In a disposable clone, change one target in `apm.yml`, run `apm compile`, and inspect the generated-file diff. This demonstrates that target selection affects compiled agent setup. Restore the disposable clone afterward; do not change or apply the AKS infrastructure as part of this exercise.

## Presenter wrap-up

Ask the audience what became easier to declare, reproduce, or share—and what still depends on repository-specific instructions or the runtime. If you want to claim a quality improvement, design a larger comparison with controlled prompts, models, runtime versions, and a rubric; this walkthrough alone does not establish that claim.
