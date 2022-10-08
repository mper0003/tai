#!/usr/bin/env bash

set -eou pipefail

usage(){
  cat << EOF
Usage: cat <path to secret> | $(basename "${0}") OR  $(basename "${0} secret_string")

Generates an Kubernetes secret used by ArgoCD to authenticate with
GitHub as an Application.

Reads the secret from stdin or expects a secret_string argument, a JSON string containing the secret.
The secret has a specific format, please refer to "docs/argocd-github-app.md" to find out how to get this secret.

EOF
    exit 1
}

if [ -p /dev/stdin ]; then
  secret_string=$(cat /dev/stdin)
else
  (( $# != 1 )) && usage
  secret_string="${1}"
fi

github_app_id="$(echo "${secret_string}" | jq .AppId | base64)"
github_app_installation_id="$(echo "${secret_string}" | jq .InstallationId | base64)"
github_app_private_key="$(echo "${secret_string}" | jq .privateKey | base64)"
credential_url="$(echo "${secret_string}" | jq .orgURL | base64)"
credential_type="$(echo "git" | base64)"

cat << EOF
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: argocd-github-credentials
  namespace: argocd
data:
  githubAppID: "${github_app_id}"
  githubAppInstallationID: "${github_app_installation_id}"
  githubAppPrivateKey: "${github_app_private_key}"
  type: "${credential_type}"
  url: "${credential_url}"
EOF
