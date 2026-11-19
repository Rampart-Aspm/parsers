# Changelog

## [0.1.0]

First release. The default report parsers of Rampart as one chart: 13 WASM parsers (checkov, dependencycheck, gitlab, gitleaks, grype, kubebench, openvex, prowler, sarif, semgrep, snyk, trivy, trufflehog) and 4 Lua parsers (bandit, genericjson, nuclei, zap), each a `ClusterParser`. They were part of Rampart's own chart; their detection is the scored `detect` that Rampart tests, and the module of each is `ghcr.io/rampart-aspm/parsers/<name>:v1`.
