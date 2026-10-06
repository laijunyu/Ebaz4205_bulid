#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-ebaz4205_buildroot}"
UPSTREAM="https://github.com/embed-me/ebaz4205_buildroot.git"

if [[ ! -d "${REPO_DIR}/.git" ]]; then
  git clone "${UPSTREAM}" "${REPO_DIR}"
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${ROOT_DIR}/configs/zynq_ebaz4205_defconfig" "${REPO_DIR}/configs/zynq_ebaz4205_defconfig"
mkdir -p "${REPO_DIR}/ebaz4205/fs-overlay/etc/network"
cp "${ROOT_DIR}/ebaz4205/fs-overlay/etc/network/interfaces" "${REPO_DIR}/ebaz4205/fs-overlay/etc/network/interfaces"
mkdir -p "${REPO_DIR}/.github/workflows"
cp "${ROOT_DIR}/.github/workflows/build-ebaz4205.yml" "${REPO_DIR}/.github/workflows/build-ebaz4205.yml"
cp "${ROOT_DIR}/README.md" "${REPO_DIR}/README.md"

echo "Prepared ${REPO_DIR}. Build with the repository's BR2_EXTERNAL workflow."
