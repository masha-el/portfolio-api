#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/infra/demo"

cd "${TF_DIR}"

terraform destroy

echo
echo "Terraform destroy finished. Check GCP for leftover load balancers, IPs, routers, and clusters."

