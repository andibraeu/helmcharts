# AGENTS.md

This file provides context and conventions for AI coding agents working on this repository.

## Project Overview

This is a monorepo containing Helm charts for various applications. All charts are located under the `charts/` directory.

### Directory Structure

```
charts/
├── cert-manager-webhook-inwx/
├── music-assistant-server/
└── ohcloud/
```

## Language and Comments

- **All code comments MUST be written in English**
- README files should be written in English
- Commit messages should be in English

## Helm Chart Conventions

### Chart Structure

Each chart must be placed in its own directory under `charts/<chart-name>/` with the following structure:

**Required files:**
- `Chart.yaml` - Chart metadata (see format below)
- `values.yaml` - Default configuration values with explanatory comments
- `README.md` - Documentation for the chart
- `templates/` - Directory containing Kubernetes manifest templates

**Optional files:**
- `.helmignore` - Patterns to ignore when packaging
- `Chart.lock` - Lock file for dependencies

### Chart.yaml Format

Use Helm API version 2 with the following fields:

```yaml
apiVersion: v2
name: <chart-name>
version: "1.0.0"           # Semantic version of the chart
description: <description>
type: application
appVersion: "<app-version>" # Version of the packaged application
kubeVersion: ">=1.16.0-0"   # Optional: supported Kubernetes versions
icon: <url>                 # Optional: URL to an icon
home: <url>                 # Optional: URL to the project home
keywords: []                # Optional: list of keywords
sources: []                 # Optional: list of source URLs
maintainers: []             # Optional: list of maintainers
dependencies: []            # Optional: list of chart dependencies
```

### Template Conventions

- Use `_helpers.tpl` for reusable template definitions (chart name, fullname, labels, etc.)
- Apply standard Kubernetes labels:
  - `helm.sh/chart`
  - `app.kubernetes.io/name`
  - `app.kubernetes.io/instance`
  - `app.kubernetes.io/version`
  - `app.kubernetes.io/managed-by`

### Values.yaml

- Include descriptive comments for all configuration options
- Use sensible defaults
- Group related settings together

## Versioning

- Use **Semantic Versioning** for the `version` field in Chart.yaml
- The `appVersion` field reflects the version of the application being packaged
- When updating `appVersion`, the chart `version` should also be incremented

### Automatic Version Bumping

The script `.github/scripts/bump-chart-version.sh` can be used to increment the patch version:

```bash
.github/scripts/bump-chart-version.sh charts/<chart-name>
```

## Release Process

Releases are automated via GitHub Actions.

### Release Workflow

**Trigger:** Push to `main` branch (excluding README.md changes)

**Action:** The workflow at `.github/workflows/release-helmchart.yaml` uses the `helm/chart-releaser-action` to:
1. Package changed charts
2. Create GitHub releases
3. Update the Helm repository index

### Automatic Chart Version Updates

For Renovate bot PRs that update `appVersion` in `charts/music-assistant-server/Chart.yaml`:
- The workflow at `.github/workflows/update-chart-version.yaml` automatically bumps the chart version
- This ensures chart versions are incremented when the packaged application version changes

## Testing

Before committing changes to a chart, run:

```bash
# Lint the chart
helm lint charts/<chart-name>

# Render templates locally to verify output
helm template <release-name> charts/<chart-name>

# Optionally validate against a Kubernetes cluster
helm template <release-name> charts/<chart-name> | kubectl apply --dry-run=client -f -
```

## Dependencies

- Charts may declare dependencies in `Chart.yaml`
- Run `helm dependency update charts/<chart-name>` after modifying dependencies
- Commit both `Chart.yaml` and `Chart.lock` when dependencies change
