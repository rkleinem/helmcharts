{{/* Name */}}
{{- define "prometheus.name" -}}
{{- $_default := printf "prometheus-%s" .Chart.Name -}}
{{- (default $_default .Values.prometheus.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus.fullname" -}}
{{- if .Values.prometheus.fullnameOverride -}}
{{- .Values.prometheus.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := ( include "prometheus.name" . ) }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}



{{/* Common annotations for whole chart + prom */}}
{{- define "prometheus.commonAnnotations" -}}
{{- merge (deepCopy .Values.global.commonAnnotations) .Values.prometheus.commonAnnotations | toYaml }}
{{- end }}



{{/* Common labels */}}
{{- define "prometheus.labels" -}}
helm.sh/chart: {{ include "base.chart" . }}
{{ include "prometheus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "prometheus.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ include "prometheus.name" . }}
{{- end }}



{{/*
Create the fully qualified image path
*/}}
{{- define "prometheus.image" -}}
{{- $img := list .Values.prometheus.deployment.registry .Values.prometheus.deployment.repository | join "/" }}
{{- list $img (default "latest" .Values.prometheus.deployment.tag) | join ":" }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount -}}
{{- default (include "prometheus.fullname" .) .Values.prometheus.serviceAccount.nameOverride }}
{{- else }}
{{- include "prometheus.fullname" . }}
{{- end }}
{{- end }}
