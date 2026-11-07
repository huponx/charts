{{- define "common.container.env.CHANGE_CAUSE" }}
- name: CHANGE_CAUSE
  valueFrom:
    fieldRef:
      fieldPath: metadata.annotations['kubernetes.io/change-cause']
{{- end }}

{{- define "common.container.env.POD_NAME" }}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
{{- end }}

{{- define "common.container.env.POD_IP" }}
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- end }}

{{- define "common.container.env.POD_TEMPLATE_HASH" }}
- name: POD_TEMPLATE_HASH
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['pod-template-hash']
{{- end }}

{{- define "common.container.env.NAMESPACE" }}
- name: NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end }}

{{- define "common.container.env.NODE_NAME" }}
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
{{- end }}

{{- define "common.container.env.STATSD_HOST" }}
- name: STATSD_HOST
  value: opentelemetry-collector.monitoring
{{- end }}

{{- define "common.container.env.STATSD_PORT" }}
- name: STATSD_PORT
  value: "8125"
{{- end }}

{{- define "common.container.env.OTLP_HOST" }}
- name: OTLP_HOST
  value: opentelemetry-collector.monitoring
{{- end }}

{{- define "common.container.env.OTLP_PORT" }}
- name: OTLP_PORT
  value: "4317"
{{- end }}

{{- define "common.container.env.DEFAULTS" -}}
{{- include "common.container.env.POD_NAME" . }}
{{- include "common.container.env.POD_IP" . }}
{{- include "common.container.env.POD_TEMPLATE_HASH" . }}
{{- include "common.container.env.NAMESPACE" . }}
{{- include "common.container.env.NODE_NAME" . }}
{{- end -}}