#!/usr/bin/env bash

set -eou pipefail

kubectl -n argocd get cm argocd-cm -o yaml \
| sed '/data:/a \
  accounts.alice: login \
' \
