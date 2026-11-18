#!/usr/bin/env bash
# Compatibility entry point; Make owns the build and deployment workflow.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec make -C "$ROOT" deploy "$@"
