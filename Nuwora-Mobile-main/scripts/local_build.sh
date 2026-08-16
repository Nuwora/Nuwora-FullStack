#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_PATH="${ROOT_DIR}/.derivedData"

mkdir -p "${DERIVED_DATA_PATH}"

xcodebuild \
  -project "${ROOT_DIR}/Nuwora Mobile.xcodeproj" \
  -scheme "Nuwora Mobile" \
  -configuration Debug \
  -sdk iphoneos \
  CODE_SIGNING_ALLOWED=NO \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  build
