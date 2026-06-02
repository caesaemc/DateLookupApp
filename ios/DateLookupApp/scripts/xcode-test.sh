#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

xcodebuild test \
  -project DateLookupApp.xcodeproj \
  -scheme DateLookupApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
