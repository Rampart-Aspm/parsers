{{/* A manifest from manifests/, with the labels Helm puts on what it installs. Its spec is untouched. */}}
{{- define "rampart-parsers.render" -}}
{{- $m := .m -}}
{{- $labels := dict "app.kubernetes.io/name" "rampart-parsers" "app.kubernetes.io/part-of" "rampart" "app.kubernetes.io/managed-by" .root.Release.Service "app.kubernetes.io/instance" .root.Release.Name "helm.sh/chart" (printf "%s-%s" .root.Chart.Name .root.Chart.Version) -}}
{{- $_ := set $m.metadata "labels" (merge (default dict $m.metadata.labels) $labels) -}}
{{- toYaml $m -}}
{{- end -}}
