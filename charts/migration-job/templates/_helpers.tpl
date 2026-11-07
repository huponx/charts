{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.labels" -}}
{{- $defaultLabels := dict "app" (include "common.name" .context) "helm.sh/chart" (include "common.chart" .context) }}
{{- if (.context.Values.global).commonLabels }}
{{- include "common.tplvalues.render" (dict "value" (deepCopy (.context.Values.global).commonLabels | mergeOverwrite $defaultLabels) "context" .context) }}
{{- else }}
{{- include "common.tplvalues.render" (dict "value" $defaultLabels "context" .context) }}
{{- end }}
{{- end }}

{{- define "common.annotations.merge" }}
{{- $top := first . }}
{{- $commonAnnotations := default dict (($top.Values.global).commonAnnotations) }}
{{- $secondAnnotations := default dict (index . 1) }}
{{- if or $commonAnnotations $secondAnnotations }}
annotations:
  {{- (deepCopy $commonAnnotations | merge $secondAnnotations) | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{- define "common.selectorLabels" -}}
app: {{ include "common.name" . }}
{{- end }}

{{- define "common.container.image" -}}
{{- $registryName := .registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := default .context.Chart.AppVersion .imageRoot.tag | toString -}}
{{- if not $repositoryName }}{{- fail "image.repository is required" }}{{- end -}}
{{- if not (or $termination .imageRoot.digest) }}{{- fail "image.tag (or image.digest) is required" }}{{- end -}}
{{- if .imageRoot.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .imageRoot.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}