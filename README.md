# Rampart Finding & Security Scanners Parsers

This repository contains the official security report parsers for the **Rampart ASPM** platform. Parsers translate scanner-specific outputs (SAST, DAST, Secrets, Container Scanning, IaC, Compliance) into canonical, deduplicated `RawFinding` events streamed over standard output.

---

## Architecture

Rampart uses out-of-process, sandboxed parsing engines decoupled from the core host:

1. **WebAssembly (WASM / WASI):**
   - High-throughput parsers written in Go and compiled targeting `GOOS=wasip1 GOARCH=wasm`.
   - Executed inside Rampart using the memory-safe [Wazero](https://wazero.io/) WebAssembly runtime without cgo.
   - Zero network egress capabilities and strictly bounded memory limits.
   - Packaged and distributed as minimal scratch OCI artifacts on GitHub Packages (`ghcr.io/rampart-aspm/parsers/<name>`).

2. **Lua 5.1 Scripted Parsers:**
   - Interpreted using an embedded Gopher-Lua runtime.
   - Ideal for rapid scripting and lightweight transformations without a compilation toolchain.

3. **Streaming JSONL Protocol:**
   - Parsers stream newline-delimited JSON (`domain.RawFinding`) to `stdout`:
     ```json
     {"finding_key":"...","title":"SQL Injection","severity":"high","category":"sast", ...}
     ```
   - Errors, diagnostics, and recovery hints are logged to `stderr`.

---

## Parsers Directory

### WASM Modules (`wasm/`)

| Parser | Category | Target Format / Tool | Description |
|---|---|---|---|
| `checkov` | `iac` | Checkov JSON (`results.failed_checks`) | Terraform, CloudFormation, Kubernetes, and Dockerfile misconfigurations |
| `dependencycheck` | `sca` | OWASP Dependency-Check JSON | Vulnerabilities in project dependencies |
| `gitlab` | `sast`/`secret`/`sca` | GitLab Security Reports v15+ | Multi-discipline GitLab CI security scans |
| `gitleaks` | `secret` | Gitleaks JSON v8+ | Leaked credentials and API tokens (hashed, secrets never stored) |
| `grype` | `sca`/`container` | Anchore Grype JSON | Vulnerability scanner for container images and filesystems |
| `kubebench` | `compliance` | CIS Kubernetes Benchmark JSON | Node and cluster CIS benchmark compliance controls |
| `openvex` | `vex` | OpenVEX JSON decisions | Machine-readable vulnerability assertions and exploitability statements |
| `prowler` | `cloud` | Prowler AWS / Azure / GCP JSON | Cloud infrastructure posture and compliance audit |
| `sarif` | `sast`/`iac` | OASIS SARIF v2.1.0 | Industry standard SARIF logs (Semgrep, Trivy, CodeQL, ESLint) |
| `semgrep` | `sast` | Semgrep JSON v1.x+ | Static analysis findings with line-range code snippets |
| `snyk` | `sca` | Snyk JSON v1.x+ | Open-source dependency vulnerabilities and remediation advice |
| `trivy` | `sca`/`secret` | Aqua Security Trivy JSON schema v2 | Comprehensive vulnerability, secret, and license scan |
| `trufflehog` | `secret` | Trufflehog v3 JSONL | High-entropy secrets and verified credential detection |

### Lua Parsers (`lua/`)

| Parser | Category | Target Format / Tool | Description |
|---|---|---|---|
| `bandit` | `sast` | PyCQA Bandit JSON | Python security linter and AST analysis |
| `genericjson` | `sast`/`sca` | Rampart Generic v1 & DefectDojo Generic | Universal finding schema for custom in-house tools |
| `nuclei` | `dast` | ProjectDiscovery Nuclei JSONL | Fast and customizable vulnerability scanner |
| `zap` | `dast` | OWASP ZAP Alert JSON / XML | Dynamic web application vulnerability assessments |

---

## Building & Compiling WASM Modules

### Prerequisites
- Go 1.23+ with `wasip1` support

### Compile a WASM Parser
```bash
cd wasm/trivy
GOOS=wasip1 GOARCH=wasm go build -trimpath -ldflags="-s -w" -o parser.wasm main.go
```

### Run Tests
Every parser includes equivalence unit tests using test payloads under `testdata/`:
```bash
# Run all parser tests (WASM, Lua, and Core utilities)
go test ./...

# Test a specific WASM parser
go test -v ./wasm/trivy/...
```

---

## Kubernetes `ClusterParser` Manifest Example

```yaml
apiVersion: rampart.aspm.dev/v1alpha1
kind: ClusterParser
metadata:
  name: trivy
spec:
  category: sca
  runtime: wasm
  description: "Trivy JSON schema 2: package vulnerabilities, secrets, misconfigurations"
  detect:
    filenames:
      - "*trivy*.json"
    probes:
      - jsonHasKeys:
          - SchemaVersion
          - Results
  source:
    oci: ghcr.io/rampart-aspm/parsers/trivy:latest
  limits:
    maxMemoryMB: 256
    timeoutSeconds: 60
```

---

## License

Apache-2.0. Copyright (c) 2026 Rampart-Aspm.
