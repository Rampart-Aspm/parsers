#!/usr/bin/env bash
# Tests the chart: the manifests are in sync with the parsers, helm lint is clean, every resource it renders has exactly the
# spec of the manifest (the chart changes labels and nothing else), and the switches work.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
chart="$here/charts/rampart-parsers"
"$here/scripts/sync-chart.sh" --check
helm lint --strict "$chart" >/dev/null
out=$(mktemp -d); trap 'rm -rf "$out"' EXIT
helm template r "$chart" > "$out/all.yaml"
helm template r "$chart" --set defaultParsers.enabled=false > "$out/none.yaml"
helm template r "$chart" --set defaultParsers.trivy.enabled=false --set defaultParsers.zap.enabled=false > "$out/two-off.yaml"
python3 -I - "$chart/manifests" "$out" <<'PY'
import sys, glob, yaml, os
manifests, out = sys.argv[1], sys.argv[2]
want = {}
for f in glob.glob(manifests + '/*.yaml'):
    d = yaml.safe_load(open(f)); want[d['metadata']['name']] = d
def docs(name): return [d for d in yaml.safe_load_all(open(os.path.join(out, name))) if d]
got = {d['metadata']['name']: d for d in docs('all.yaml')}
assert set(got) == set(want), f"rendered {sorted(set(got) ^ set(want))} differ from the manifests"
for n, d in got.items():
    assert d['kind'] == want[n]['kind'] == 'ClusterParser', n
    assert d['apiVersion'] == want[n]['apiVersion'], n
    assert d['spec'] == want[n]['spec'], f"{n}: the rendered spec is not the manifest's spec"
    assert d['metadata']['labels']['app.kubernetes.io/part-of'] == 'rampart', n
assert docs('none.yaml') == [], "defaultParsers.enabled=false must install nothing"
off = {d['metadata']['name'] for d in docs('two-off.yaml')}
assert set(want) - off == {'trivy', 'zap'}, f"turning off trivy and zap left {sorted(set(want) - off)} out"
print(f"chart ok: {len(got)} parsers render with their manifest's spec; both switches work")
PY
