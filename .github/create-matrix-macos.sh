#!/usr/bin/env bash

set -euo pipefail

matrix_file="${1:-.github/matrix.yml}"

yq -o=json -I=0 '[
  .macos_runners
  | to_entries[] as $runner
  | $runner.value.xcode
  | to_entries[] as $xcode
  | $xcode.value.destination[]
  | {
      "runner": $runner.key,
      "xcode": $xcode.key,
      "destination": .
    }
]' "$matrix_file"
