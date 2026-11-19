## What and why

<!-- What changes, and why. Link the issue or discussion if there is one. -->

## How to test

<!-- Commands you ran or steps to verify. Paste the relevant output when it helps. -->

## Checklist

- [ ] PR title follows `type(scope): subject`, for example `feat(courier): add retry`
- [ ] `version` bumped in the changed chart's `Chart.yaml`
- [ ] A `ci/<name>-values.yaml` covers each new feature toggle
- [ ] Value changes that break users are a major bump
- [ ] No secrets, tokens or private keys in the diff
- [ ] Docs (`README.md`) updated when behaviour or setup changed
