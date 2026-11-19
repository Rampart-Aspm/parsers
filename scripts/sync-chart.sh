#!/usr/bin/env bash
# The chart's manifests/ holds a copy of each parser's parser.yaml (the one next to its code, which is the source of truth),
# named after the resource. `sync-chart.sh` writes the copies; `sync-chart.sh --check` fails if a copy is stale, missing or
# left over, or if values.yaml does not list exactly these parsers.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
dest="$here/charts/rampart-parsers/manifests"
check=0; [[ "${1:-}" == "--check" ]] && check=1
want=$(mktemp -d); trap 'rm -rf "$want"' EXIT
for f in "$here"/wasm/*/parser.yaml "$here"/lua/*/parser.yaml; do
  [[ -f "$f" ]] || continue
  name=$(awk '/^metadata:/{m=1;next} m && /^  name:/{print $2; exit}' "$f")
  [[ -n "$name" ]] || { echo "no metadata.name in $f" >&2; exit 1; }
  [[ ! -e "$want/$name.yaml" ]] || { echo "two parsers are named $name" >&2; exit 1; }
  cp "$f" "$want/$name.yaml"
done
if (( check )); then
  diff -r "$want" "$dest" || { echo "charts/rampart-parsers/manifests is out of date: run scripts/sync-chart.sh" >&2; exit 1; }
  listed=$(python3 -I -c "import sys,yaml; d=yaml.safe_load(open(sys.argv[1]))['defaultParsers']; print('\n'.join(sorted(k for k in d if k!='enabled')))" "$here/charts/rampart-parsers/values.yaml")
  have=$(ls "$want" | sed 's/\.yaml$//' | sort)
  [[ "$listed" == "$have" ]] || { echo "values.yaml defaultParsers does not list exactly the parsers:" >&2; diff <(echo "$listed") <(echo "$have") >&2 || true; exit 1; }
  echo "chart manifests are in sync ($(ls "$want" | wc -l) parsers)"
else
  rm -rf "$dest"; mkdir -p "$dest"; cp "$want"/*.yaml "$dest"/
  echo "wrote $(ls "$dest" | wc -l) manifests"
fi
