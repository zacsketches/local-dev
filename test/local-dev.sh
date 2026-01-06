#!/bin/bash
# Wrapper to run the root local-dev.sh against the test fixtures
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC_DIR="${SRC_DIR:-${SCRIPT_DIR}/src}"
OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/site}"

cd "$ROOT_DIR"
SRC_DIR="$SRC_DIR" OUT_DIR="$OUT_DIR" ./local-dev.sh "$@"
