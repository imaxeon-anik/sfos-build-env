# Reusable CI

## Runner prerequisites

1. Use a dedicated Linux x64 machine/VM with the configured SDK and target.
2. Register one GitHub Actions runner for this SDK engine, labeled `sfos-sdk`.
3. Run it as the SDK owner, not root, and set `SFDK` in the runner service environment if needed.
4. Restrict the runner group to approved private repositories. Do not put developer SSH keys,
   phone keys, signing keys or unrelated private source trees on it.
5. In each calling repository, create the `sfos-build` environment with required reviewers
   and deployment branch restrictions. Ensure your GitHub plan supports those protections.
   GitHub can create an unprotected environment implicitly, so the YAML alone is not an approval gate.

The workflow excludes pull-request events, but **push builds still execute arbitrary repository
code**. Approval and repository/runner restrictions are necessary. Prefer ephemeral runners.
Repository-scoped concurrency does not serialize across repositories; use only one runner
per shared SDK engine, or dedicate an engine per runner.

## Private repository access

Enable access for intended caller repositories in this repository's Actions settings, subject
to GitHub's account/organization restrictions. Not every cross-owner private reuse arrangement
is supported. Private workflow access does not automatically grant checkout access to scripts.

Create `BUILD_ENV_READ_TOKEN` in the caller: a short-lived GitHub App token or fine-grained token
with Contents: read on **only sfos-build-env**. Enter it directly in GitHub Secrets; never paste
it into source, logs or chat. Pass it explicitly as shown in the example. App API keys are not needed.

Copy `examples/application-workflow.yml` to the app's `.github/workflows/`. Replace both
`REPLACE_WITH_FULL_COMMIT_SHA` strings with the same reviewed 40-character commit SHA from
this repository. Do not use a moving branch for the production recipe. A caller checks out
its own commit and builds its own spec; no Sailmate source is built implicitly.

The uploaded artifact includes build logs. Application build scripts may print sensitive data,
so do not provide unnecessary secrets and review logs before sharing artifacts. Retention is
14 days. Releases and GHCR images are not automatically published.

## GitHub-hosted builds

Only wrapper checks run on GitHub-hosted machines today. A hosted RPM workflow will require
a separately validated container or SDK provisioning strategy. Do not label the self-hosted
workflow as an SSD-independent hosted build until that work is complete.