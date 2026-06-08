{{/* Name */}}
{{- define "auditor.name" -}}
{{- (default .Chart.Name .Values.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "auditor.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := ( include "auditor.name" . ) }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{- define "auditor.httpPort" -}}
8000
{{- end }}
{{- define "auditor.httpsPort" -}}
8443
{{- end }}


{{/* Port that is to be used on the container (HTTP vs HTTPS) */}}
{{- define "auditor.exposedPort" -}}
{{- if .Values.auditor.config.tls_config.use_tls }}
{{- include "auditor.httpsPort" . }}
{{- else }}
{{- include "auditor.httpPort" . }}
{{- end }}
{{- end }}



{{/* Common annotations for whole chart + auditor */}}
{{- define "auditor.commonAnnotations" -}}
{{- merge (deepCopy .Values.global.commonAnnotations) .Values.auditor.commonAnnotations | toYaml }}
{{- end }}



{{/* Common labels */}}
{{- define "auditor.labels" -}}
helm.sh/chart: {{ include "base.chart" . }}
{{ include "auditor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/* Selector labels */}}
{{- define "auditor.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ include "auditor.name" . }}
{{- end }}


