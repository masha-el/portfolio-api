#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/infra/demo"

cd "${TF_DIR}"

if [[ ! -f terraform.tfvars ]]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created infra/demo/terraform.tfvars from the example file."
  echo "Review it, then run this script again."
  exit 0
fi

terraform init
terraform apply

echo
echo "Demo infrastructure is ready."
echo "Next step: GitHub -> Actions -> Build and Deploy -> Run workflow"

