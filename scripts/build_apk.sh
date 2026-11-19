#!/usr/bin/env bash
# Builds a release APK (uses debug signing if android/key.properties is missing).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS="${BUILD_TOOLS_DIR:-$ROOT/.build-tools}"

export JAVA_HOME="${JAVA_HOME:-$(ls -d "$TOOLS"/jdk-17* 2>/dev/null | head -1)/Contents/Home}"
export ANDROID_HOME="${ANDROID_HOME:-$TOOLS/android-sdk}"
export PATH="$TOOLS/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

if [[ ! -x "$TOOLS/flutter/bin/flutter" ]]; then
  echo "Flutter SDK not found at $TOOLS/flutter — run from a machine with Flutter installed,"
  echo "or let CI install tooling into .build-tools first."
  exit 1
fi

cd "$ROOT"
flutter pub get
flutter build apk --release
echo ""
echo "APK: $ROOT/build/app/outputs/flutter-apk/app-release.apk"
