{{- define "common.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.job.name" -}}
{{- printf "%s-job" (include "common.name" .) -}}
{{- end -}}

{{- define "common.cronjob.name" -}}
{{- printf "%s-cronjob" (include "common.name" .) -}}
{{- end -}}

{{- define "common.container.securityContext" -}}
{{- if . }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

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

{{- define "common.annotations.merge" }}
{{- $context := first . }}
{{- $globalAnnotations := default dict (($context.Values.global).commonAnnotations) }}
{{- $secondAnnotations := default dict (index . 1) }}
{{- if or $globalAnnotations $secondAnnotations }}
annotations:
  {{- (deepCopy $globalAnnotations | merge $secondAnnotations) | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{- define "common.labels" }}
{{- include "common.selector.matchLabels" (dict "context" .context "component" .component) }}
helm.sh/chart: {{ include "common.chart" .context }}
{{- if (.context.Values.global).commonLabels }}
{{- .context.Values.global.commonLabels | toYaml | nindent 0 }}
{{- end }}
{{- end }}

{{- define "common.selector.matchLabels" -}}
app: {{ include "common.name" .context }}
{{- if .component }}
component: {{ .component }}
{{- end }}
{{- end }}

{{- define "common.labels.merge" }}
{{- $context := first . }}
{{- $globalLabels := default dict (($context.Values.global).commonLabels) }}
{{- $secondLabels := default dict (index . 1) }}
labels:
  app: {{ include "common.name" $context }}
  helm.sh/chart: {{ include "common.chart" $context }}
  {{- if or $globalLabels $secondLabels }}
  {{- (deepCopy $globalLabels | merge $secondLabels) | toYaml | nindent 2 }}
  {{- end }}
{{- end }}

{{- define "common.container.resources" -}}
{{- if or .requests .limits }}
resources:
  {{- if .requests }}
  requests:
    {{- toYaml .requests | nindent 4 }}
  {{- end }}
  {{- if .limits }}
  limits:
    {{- toYaml .limits | nindent 4 }}
  {{- end }}
{{- else }}
resources: {}
{{- end }}
{{- end -}}
