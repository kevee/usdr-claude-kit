#!/usr/bin/env bash
#
# Read-only scan of the current repo for the stack signals used to match secure-
# coding rules. Prints a compact report; the security-rules-sync skill interprets
# it against the rule catalog. Makes no changes.
#
# Best-effort by design: individual probes may find nothing without aborting the
# report, so it does not use `set -e` / `pipefail`.
set -u

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root" || exit 1

echo "# Stack assessment for: $root"
echo

echo "## Source file counts by extension (top 40)"
find . \
  -type d \( -name node_modules -o -name .git -o -name dist -o -name build \
             -o -name .next -o -name .venv -o -name venv -o -name __pycache__ \
             -o -name vendor -o -name target \) -prune -o -type f -print 2>/dev/null \
  | sed -n 's/.*\.\([A-Za-z0-9][A-Za-z0-9]\{0,7\}\)$/\1/p' \
  | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -40
echo

echo "## Marker / manifest files present"
markers="package.json requirements.txt pyproject.toml Pipfile setup.py setup.cfg
  environment.yml go.mod Cargo.toml pom.xml build.gradle build.gradle.kts Gemfile
  composer.json DESCRIPTION Project.toml Dockerfile docker-compose.yml
  docker-compose.yaml compose.yaml Chart.yaml Pulumi.yaml .gitlab-ci.yml"
for f in $markers; do
  hits=$(find . -maxdepth 3 -name "$f" -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -5)
  if [ -n "$hits" ]; then
    printf '  [x] %s\n' "$f"
    printf '        %s\n' $hits
  fi
done
tf=$(find . -maxdepth 4 -name '*.tf' -not -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' ')
[ "${tf:-0}" -gt 0 ] && echo "  [x] *.tf (Terraform): $tf files"
cs=$(find . -maxdepth 4 -name '*.csproj' -not -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' ')
[ "${cs:-0}" -gt 0 ] && echo "  [x] *.csproj (.NET): $cs files"
gha=$(find .github/workflows -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null | head -5)
if [ -n "$gha" ]; then
  echo "  [x] GitHub Actions workflows:"
  printf '        %s\n' $gha
fi
k8s=$(grep -rslE '^kind:[[:space:]]*(Deployment|Service|Pod|StatefulSet|DaemonSet|Ingress|ConfigMap)' \
  --include='*.yaml' --include='*.yml' . 2>/dev/null | grep -viE '\.github/|gitlab-ci' | head -5)
if [ -n "$k8s" ]; then
  echo "  [x] Kubernetes-like manifests:"
  printf '        %s\n' $k8s
fi
echo

echo "## Dependency manifest contents (for framework / library detection)"
echo "# The skill reads these to detect frameworks (django, react, langchain, ...),"
echo "# vector stores (pinecone, qdrant, ...), and other tools present."
for f in package.json requirements.txt pyproject.toml Pipfile go.mod Cargo.toml \
         pom.xml Gemfile composer.json DESCRIPTION Project.toml environment.yml; do
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    echo "----- $path -----"
    sed -n '1,150p' "$path"
    echo
  done < <(find . -maxdepth 3 -name "$f" -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -3)
done

echo "## Notes"
echo "- No application manifests above means a config/docs-only repo; still offer the"
echo "  always-on core rules (OWASP) plus any CI/CD or container rules that match."
