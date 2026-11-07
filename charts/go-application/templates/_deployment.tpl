{{- define "common.container" -}}
{{- $top := first . }}
{{- $container := index . 1 }}
- name: {{ $container.name }}
  image: {{ include "common.container.image" (dict "imageRoot" $container.image "registry" $top.Values.global.registry "context" $top) }}
  {{- if $container.image.pullPolicy }}
  imagePullPolicy: {{ $container.image.pullPolicy }}
  {{- end }}
  {{- if $container.ports }}
  ports:
    {{- toYaml $container.ports | nindent 4 }}
  {{- end }}
  {{- if $container.resources }}
  resources:
    {{- toYaml $container.resources | nindent 4 }}
  {{- end }}
  {{- if $container.command }}
  command:
    {{- toYaml $container.command | nindent 4 }}
  {{- end }}
  {{- if $container.args }}
  args:
    {{- toYaml $container.args | nindent 4 }}
  {{- end }}
  {{- if $container.env }}
  env:
    {{- toYaml $container.env | nindent 4 }}
  {{- end }}
  {{- if $container.envFrom }}
  envFrom:
    {{- tpl (toYaml $container.envFrom) $top | nindent 4 }}
  {{- end }}
  {{- if $container.securityContext }}
  securityContext:
    {{- toYaml $container.securityContext | nindent 4 }}
  {{- end }}
  {{- if $container.lifecycle }}
  lifecycle:
    {{- toYaml $container.lifecycle | nindent 4 }}
  {{- end }}
  {{- if $container.startupProbe }}
  startupProbe:
    {{- toYaml $container.startupProbe | nindent 4 }}
  {{- end }}
  {{- if $container.livenessProbe }}
  livenessProbe:
    {{- toYaml $container.livenessProbe | nindent 4 }}
  {{- end }}
  {{- if $container.readinessProbe }}
  readinessProbe:
    {{- toYaml $container.readinessProbe | nindent 4 }}
  {{- end }}
  {{- if $container.volumeMounts }}
  volumeMounts:
    {{- toYaml $container.volumeMounts | nindent 4 }}
  {{- end }}
  {{- if $container.volumeDevices }}
  volumeDevices:
    {{- toYaml $container.volumeDevices | nindent 4 }}
  {{- end }}
  {{- if $container.terminationMessagePath }}
  terminationMessagePath: {{ $container.terminationMessagePath }}
  {{- end }}
  {{- if $container.terminationMessagePolicy }}
  terminationMessagePolicy: {{ $container.terminationMessagePolicy }}
  {{- end }}
  {{- if $container.workingDir }}
  workingDir: {{ $container.workingDir }}
  {{- end }}
{{- end -}}