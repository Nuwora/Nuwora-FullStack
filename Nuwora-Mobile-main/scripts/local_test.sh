#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_PATH="${ROOT_DIR}/.derivedData"
DESTINATION="${NUWORA_TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 17}"

mkdir -p "${DERIVED_DATA_PATH}"

xcodebuild \
  -project "${ROOT_DIR}/Nuwora Mobile.xcodeproj" \
  -scheme "Nuwora Mobile" \
  -destination "${DESTINATION}" \
  -parallel-testing-enabled NO \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  test
