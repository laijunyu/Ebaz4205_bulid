#!/usr/bin/env bash
set -euo pipefail

BUILDROOT_VERSION="2020.11.4"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDROOT_DIR="${ROOT_DIR}/buildroot-${BUILDROOT_VERSION}"
TARBALL="${ROOT_DIR}/buildroot-${BUILDROOT_VERSION}.tar.gz"

if [[ ! -d "${BUILDROOT_DIR}" ]]; then
  if [[ ! -f "${TARBALL}" ]]; then
    echo "Downloading Buildroot ${BUILDROOT_VERSION}..."
    wget "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz" -O "${TARBALL}"
  fi
  tar -xzf "${TARBALL}" -C "${ROOT_DIR}"
fi

make -C "${BUILDROOT_DIR}" \
  BR2_EXTERNAL="${ROOT_DIR}" \
  zynq_ebaz4205_defconfig

make -C "${BUILDROOT_DIR}" -j"$(nproc)" 2>&1 | tee "${ROOT_DIR}/build.log"

echo
printf '%s\n' 'Build finished. Images are in:'
printf '  %s\n' "${BUILDROOT_DIR}/output/images/"
