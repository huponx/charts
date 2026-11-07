{{- define "common.configmap-generator" -}}
  {{- if kindIs "string" .value }}
  {{ .key }}: {{- .value | toYaml | indent 1 }}
  {{- else if kindIs "map" .value }}
  {{ .key }}: {{- .value | toJson | squote | indent 1 }}
  {{- else if eq nil .value }}
  {{ .key }}: ""
  {{- else }}
  {{ .key }}: {{- .value | toJson | squote | indent 1 }}
  {{- end }}
{{- end -}}