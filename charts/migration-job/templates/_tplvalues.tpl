{{- define "common.tplvalues.render" -}}
{{- if .scope }}
  {{- if typeIs "string" .value }}
    {{- tpl (cat "{{- with $.RelativeScope -}}" .value  "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl (cat "{{- with $.RelativeScope -}}" (.value | toYaml)  "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- end }}
{{- else }}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}
{{- end -}}