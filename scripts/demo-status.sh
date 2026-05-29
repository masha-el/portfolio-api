#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/infra/demo"

cd "${TF_DIR}"

$(terraform output -raw get_credentials_command)
kubectl get pods
kubectl get svc portfolio-api

