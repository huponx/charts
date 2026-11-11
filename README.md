# charts

Shared Helm charts for the `huponx` services, published as OCI artifacts to GHCR:

```
oci://ghcr.io/huponx/charts/<chart>
```

| Chart | Purpose | Renders |
|-------|---------|---------|
| `go-application` | Long running Go service (gRPC / HTTP) | Deployment, Service, HPA, PDB, Ingress, ConfigMap, Secret, optional ServiceAccount and `system:auth-delegator` binding |
| `python-application` | Python service (gRPC / ASGI) | same as `go-application` |
| `web-application` | React / Vite frontend | same as `go-application` plus runtime ConfigMap |
| `go-job` | One-off Go job, or CronJob with `cronjob.enabled=true` | Job or CronJob, ConfigMap |
| `migration-job` | Flyway database migration against PostgreSQL | Job, ConfigMap |

## Usage

The image repository and tag are **required**. A chart fails to render with a clear message when they are missing.

```bash
# application
helm install courier oci://ghcr.io/huponx/charts/go-application --version 1.0.1 \
  --set deployment.container.image.repository=huponx/courier \
  --set deployment.container.image.tag=v0.1.0 \
  --set deployment.container.port=9090

# job: values live under `job.`
helm install courier-sync oci://ghcr.io/huponx/charts/go-job --version 1.0.1 \
  --set job.container.image.repository=huponx/courier \
  --set job.container.image.tag=v0.1.0

# migration: values live under `container.`
helm install db-migrate oci://ghcr.io/huponx/charts/migration-job --version 1.0.1 \
  --set container.image.repository=huponx/courier-migrations \
  --set container.image.tag=v0.1.0
```

Useful commands:

```bash
helm show values oci://ghcr.io/huponx/charts/go-application --version 1.0.1
helm pull oci://ghcr.io/huponx/charts/go-application --version 1.0.1 --untar
```

Notes:
- The registry defaults to `ghcr.io` (`global.registry`), the image becomes `ghcr.io/<repository>:<tag>`.
- `replicas` is only rendered when `autoscaling.enabled=false` (or set to `0`); otherwise the HPA owns the count.
- `ingress.paths` defaults to a single `ingress.path` / `ingress.pathType` rule when empty.
- `go-application` only: `serviceAccount.create` creates a ServiceAccount for the pods and `rbac.authDelegator` binds it to the ClusterRole `system:auth-delegator`, which a gRPC service needs to verify the ServiceAccount tokens of its callers (`grpcserver.WithKubeAuth` in `gocommon`). The binding is cluster scoped and named `<name>-<namespace>-auth-delegator`. A caller that sends such tokens mounts a projected `serviceAccountToken` volume through `deployment.volumes` and `deployment.container.volumeMounts` (see `charts/go-application/ci/auth-values.yaml`).

## Layout

```
charts/<chart>/
  Chart.yaml
  values.yaml
  templates/
  ci/*.yaml        values used by CI to lint, render and validate the chart (required)
.github/
  workflows/       ci.yml, pr-title.yml, release.yml
```

## Local development

Requires [Helm 3](https://helm.sh/docs/intro/install/). From the repo root:

```bash
chart=go-application
for f in charts/$chart/ci/*.yaml; do
  helm lint --strict charts/$chart -f "$f"
  helm template test charts/$chart -f "$f" > /tmp/rendered.yaml
done

# optional, same as CI: validate against Kubernetes schemas
kubeconform -strict -summary -ignore-missing-schemas -kubernetes-version 1.31.0 /tmp/rendered.yaml
```

When you add a feature toggle (ingress, cronjob, init containers, ...) add a `ci/<name>-values.yaml` that turns it on so CI renders that path.

## Contributing and versioning

1. Branch from `main`, change a chart.
2. **Bump `version` in that chart's `Chart.yaml`** (semver: patch for fixes, minor for new values, major for breaking value changes). CI fails when a changed chart keeps the same version.
3. Open a PR with a conventional commit title, for example `fix(go-job): quote image tag`. Types: `feat fix perf refactor docs chore ci test build`.
4. Merge with **squash**. The release workflow publishes every chart version that is not in GHCR yet.

Versions are immutable: a published `<chart>:<version>` is never overwritten, only new versions are pushed. Each publish also creates the git tag and GitHub Release `<chart>-<version>`.

## Workflows

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `ci.yml` | PR and push to `main` | `detect` the changed charts (all charts when `.github/` changes), `verify` matrix per chart (`helm lint --strict`, `helm template`, `kubeconform`), `version-check` (PR only) and the aggregate job `ci` |
| `pr-title.yml` | PR opened, edited, pushed | Checks the conventional commit title, job `pr-title` |
| `release.yml` | push to `main` touching `charts/**`, or manual | Packages and pushes new chart versions to GHCR, tags and creates a GitHub Release |

Required status checks for `main`: `ci` and `pr-title`.

## Setup (one time)

Everything below can be done with the `gh` CLI (UI paths in parentheses). Run it from the repo root.

```bash
REPO=huponx/charts
```

1. **Actions permissions** so `GITHUB_TOKEN` can write packages and releases (UI: Settings > Actions > General > Workflow permissions > Read and write). The release job also declares `contents: write` and `packages: write`.
   ```bash
   gh api -X PUT repos/$REPO/actions/permissions/workflow -f default_workflow_permissions=write
   ```
2. **Merge settings**: squash only, so the PR title is the commit subject (UI: Settings > General > Pull Requests).
   ```bash
   gh api -X PATCH repos/$REPO -F allow_squash_merge=true -F allow_merge_commit=false \
     -F allow_rebase_merge=false -F delete_branch_on_merge=true \
     -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
   ```
3. **Branch ruleset** for `main` (PR required, squash only, required checks `ci` and `pr-title`, no force push or deletion). Save as `main-ruleset.json` and apply (the file is only an input, do not commit it):
   ```json
   {
     "name": "main",
     "target": "branch",
     "enforcement": "active",
     "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
     "bypass_actors": [
       { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "pull_request" }
     ],
     "rules": [
       { "type": "deletion" },
       { "type": "non_fast_forward" },
       {
         "type": "pull_request",
         "parameters": {
           "required_approving_review_count": 0,
           "dismiss_stale_reviews_on_push": false,
           "require_code_owner_review": false,
           "require_last_push_approval": false,
           "required_review_thread_resolution": false,
           "allowed_merge_methods": ["squash"]
         }
       },
       {
         "type": "required_status_checks",
         "parameters": {
           "strict_required_status_checks_policy": true,
           "required_status_checks": [
             { "context": "ci" },
             { "context": "pr-title" }
           ]
         }
       }
     ]
   }
   ```
   ```bash
   gh api repos/$REPO/rulesets --method POST --input main-ruleset.json
   gh api repos/$REPO/rulesets --jq '.[] | {id, name, enforcement}'   # verify
   ```
   Or import it in the UI: Settings > Rules > Rulesets > New ruleset > Import a ruleset. To change it later: `gh api repos/$REPO/rulesets/<id> --method PUT --input main-ruleset.json`. Rulesets on a private repo need a paid GitHub plan.
4. **Optional tag ruleset** so published chart tags (`<chart>-<version>`) never move or disappear:
   ```bash
   cat > ./tag-ruleset.json <<'JSON'
   {
     "name": "protect release tags",
     "target": "tag",
     "enforcement": "active",
     "conditions": { "ref_name": { "include": ["refs/tags/*-*.*.*"], "exclude": [] } },
     "rules": [ { "type": "update" }, { "type": "deletion" }, { "type": "non_fast_forward" } ],
     "bypass_actors": []
   }
   JSON
   gh api repos/$REPO/rulesets --method POST --input tag-ruleset.json
   ```
   Do not restrict tag *creation*: `release.yml` creates the tags with `GITHUB_TOKEN`.
5. **First release**: merge a PR that changes a chart. `release.yml` pushes `ghcr.io/huponx/charts/<chart>` for every chart.
6. **Package visibility** (UI only, GitHub has no stable CLI for this): your profile or org > Packages > `charts/<chart>` > Package settings:
   - set visibility to **Public**, or keep it private and use `helm registry login ghcr.io` with a classic PAT that has `read:packages`;
   - under *Manage Actions access* add `huponx/charts` with the **Write** role, otherwise later releases fail with `permission_denied`.
   Repeat for each chart package.

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| `ci` fails in `version-check`: "changed but version is still X" | Bump `version` in `charts/<chart>/Chart.yaml`. |
| `image.repository is required` / `image.tag (or image.digest) is required` | Set the image values, see Usage. In CI add them to `charts/<chart>/ci/*.yaml`. |
| `ci/*.yaml is required` | Every chart needs at least one values file in `ci/` that renders it. |
| `verify` fails in kubeconform | Rendered manifest is invalid for Kubernetes 1.31; run the local commands above and read the error. |
| Release log: `skip <chart> <version>: already published` | The version already exists; bump it to publish new content. |
| `denied: permission_denied` on `helm push` | Package was created by someone else or is not linked to the repo: add the repo under the package's *Manage Actions access* with Write. |
| `helm pull` returns 401 / not found from a cluster or laptop | Package is private: make it public or `helm registry login ghcr.io` with a PAT that has `read:packages`. |
| `403` on `gh release create` | Workflow permissions are read-only: set Read and write permissions (Setup, step 2). |
| PR title check fails | Use `type(scope): subject`, for example `feat(web-application): add runtime config`; editing the title re-runs only `pr-title`. |
