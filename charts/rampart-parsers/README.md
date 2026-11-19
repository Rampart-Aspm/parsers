# rampart-parsers

The default report parsers of [Rampart](https://github.com/taha2samy-3/Rampart), one `ClusterParser` resource per scanner
format. Rampart's server knows no parser by name: this chart is how a cluster gets them.

```sh
helm install parsers oci://ghcr.io/rampart-aspm/charts/rampart-parsers --version 0.1.0
```

Rampart's own chart includes it as `parsers`, on by default, so `parsers.defaultParsers.enabled` and
`parsers.defaultParsers.<name>.enabled` there are the switches below.

| Value | Default | Meaning |
|---|---|---|
| `defaultParsers.enabled` | `true` | `false` installs no parser |
| `defaultParsers.<name>.enabled` | `true` | `false` leaves that parser out |

## Where the manifests come from

Each parser's manifest is the `parser.yaml` next to its code (`wasm/<name>/` or `lua/<name>/`). `manifests/` holds a copy of
each, written by `scripts/sync-chart.sh`; CI (`scripts/check-chart.sh`) fails when a copy is stale and checks that every
resource the chart renders has exactly the spec of its manifest. The template names no parser.

The WASM module a manifest names (`source.oci`) is not installed by this chart. It reaches the Rampart pods as an image volume
or an init container, by digest (Rampart's chart, `parsers.modules`).

SBOM readers are another chart: [rampart-sbom-parsers](https://github.com/Rampart-Aspm/sbom-parsers).
