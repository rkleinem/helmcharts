{{/*
Expand the name of the chart.
*/}}
{{- define "auditor-prometheus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "auditor-prometheus.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "auditor-prometheus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "auditor-prometheus.labels" -}}
helm.sh/chart: {{ include "auditor-prometheus.chart" . }}
{{ include "auditor-prometheus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "auditor-prometheus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "auditor-prometheus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the fully qualified image path
*/}}
{{- define "auditor-prometheus.image" -}}
{{- $img := list .Values.deployment.registry .Values.deployment.repository | join "/" }}
{{- list $img (default .Chart.AppVersion .Values.tag) | join ":" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "auditor-prometheus.serviceAccountName" -}}
{{- default (include "auditor-prometheus.fullname" .) .Values.serviceAccount.nameOverride }}
{{- end }}

{{- define "auditor-prometheus.clusterRoleName" -}}
{{- default (include "auditor-prometheus.fullname" .) .Values.clusterRole.nameOverride }}
{{- end }}

{{- define "auditor-prometheus.serviceName" -}}
{{- default (include "auditor-prometheus.fullname" .) .Values.service.name }}
{{- end }}

