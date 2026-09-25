#!/usr/bin/env bash
# Captures the store screenshots from the real app by running the full-mission
# integration test on a simulator/emulator, then copies them into raw/.
# Usage: tools/capture.sh <simulator-id> <ios-iphone69|ios-ipad13> <ar|en> "<device description>"
# Store screenshots come only from the iPhone 6.9" and iPad 13" simulators; frame.py reuses them for Play.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
app="$(cd "$here/../.." && pwd)"
device="$1" target="$2" locale="$3" desc="$4"
cd "$app"
defines=(--dart-define=LANG="$locale" --dart-define=DEVICE="$target" --dart-define=BRAINLAND_NO_ADS=true)
binary=()
if [[ "$target" == android-* ]]; then
  # Build first: flutter drive's own Gradle step has hung on this machine under load.
  flutter build apk --debug -t integration_test/app_test.dart "${defines[@]}"
  binary=(--use-application-binary build/app/outputs/flutter-apk/app-debug.apk)
fi
flutter drive --driver test_driver/integration_test.dart --target integration_test/app_test.dart \
  -d "$device" "${defines[@]}" "${binary[@]}"
out="$here/raw/$target-$locale"
rm -rf "$out" && mkdir -p "$out"
for f in build/shots/"${target}_${locale}"_*.png; do
  cp "$f" "$out/${f##*/${target}_${locale}_}"
done
python3 - "$here/raw/runs.json" "$target-$locale" "$desc" "$(git rev-parse --short HEAD)" <<'PY'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1]); runs = json.loads(p.read_text()) if p.exists() else {}
runs[sys.argv[2]] = {"device": sys.argv[3], "build": f"git {sys.argv[4]} + working tree; Brain Land 1.1.0 (2) debug build via flutter drive (integration_test/app_test.dart), ads off for capture (BRAINLAND_NO_ADS)"}
p.write_text(json.dumps(runs, indent=2) + "\n")
PY
echo "captured $(ls "$out" | wc -l) screens into $out"
