{{- define "common.configmap-generator" -}}
  {{- if kindIs "string" .value }}
  {{ .key }}: {{- .value | toYaml | indent 1 }}
  {{- else if kindIs "map" .value }}
  {{ .key }}: {{- .value | toJson | squote | indent 1 }}
  {{- else if and (kindIs "slice" .value) (gt (len .value) 0) (include "common.configmap-scalar-list" .value | eq "true") }}
  {{ .key }}: {{- .value | join "," | toYaml | indent 1 }}
  {{- else if eq nil .value }}
  {{ .key }}: ""
  {{- else }}
  {{ .key }}: {{- .value | toJson | squote | indent 1 }}
  {{- end }}
{{- end -}}

{{/*
"true" when every item of the list is a scalar (string, number, bool). Such a list is rendered as a
comma separated string (for example COURIER_AUTH_ALLOWED), any other list as JSON.
*/}}
{{- define "common.configmap-scalar-list" -}}
  {{- $scalar := true -}}
  {{- range . -}}
    {{- if or (kindIs "map" .) (kindIs "slice" .) (eq nil .) -}}{{- $scalar = false -}}{{- end -}}
  {{- end -}}
  {{- $scalar -}}
{{- end -}}
