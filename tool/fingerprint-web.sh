#!/bin/sh
# Fingerprint dependencies before their callers so a CDN cannot mix releases.
set -eu
for asset in main.dart.js flutter_bootstrap.js site.js landing.css; do
  digest=$(sha256sum "build/web/$asset" | cut -c1-16)
  versioned="${asset%.*}.$digest.${asset##*.}"
  pattern=$(printf '%s' "$asset" | sed 's/\./\\./g')
  mv "build/web/$asset" "build/web/$versioned"
  find build/web -type f \( -name '*.html' -o -name site.js -o -name flutter_bootstrap.js \) \
    -exec sed -i "s|$pattern|$versioned|g" {} +
done
