# Changelog

## [0.2.0]

- feat: dynamic scanner evidence extraction. All 13 WASM and 4 Lua security parsers unmarshal scanner-specific payloads into `domain.RawFinding.Attributes` and `RawPayload` without hardcoding, supporting dynamic inspection, smart data-type formatting, and interactive raw JSON viewing in the Rampart UI.

## [0.1.0]

First release. The default report parsers of Rampart as one chart: 13 WASM parsers (checkov, dependencycheck, gitlab, gitleaks, grype, kubebench, openvex, prowler, sarif, semgrep, snyk, trivy, trufflehog) and 4 Lua parsers (bandit, genericjson, nuclei, zap), each a `ClusterParser`. They were part of Rampart's own chart; their detection is the scored `detect` that Rampart tests, and the module of each is `ghcr.io/rampart-aspm/parsers/<name>:v1`.
