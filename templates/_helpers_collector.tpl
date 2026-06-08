{{/* Name */}}
{{- define "collector.name" -}}
{{- $_default := printf "collector-%s" .Chart.Name -}}
{{- (default $_default .Values.collector.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "collector.fullname" -}}
{{- if .Values.collector.fullnameOverride -}}
{{- .Values.collector.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := ( include "collector.name" . ) }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}



{{/* Common annotations for whole chart + collector */}}
{{- define "collector.commonAnnotations" -}}
{{- merge (deepCopy .Values.global.commonAnnotations) .Values.collector.commonAnnotations | toYaml }}
{{- end }}



{{/* Common labels */}}
{{- define "collector.labels" -}}
helm.sh/chart: {{ include "base.chart" . }}
{{ include "collector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "collector.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ include "collector.name" . }}
{{- end }}



{{/*
Create the fully qualified image path
*/}}
{{- define "collector.image" -}}
{{- $img := list .Values.collector.deployment.registry .Values.collector.deployment.repository | join "/" }}
{{- $tag := default .Chart.AppVersion .Values.collector.deployment.tag -}}
{{- if $tag -}}
{{- list $img $tag | join ":" }}
{{- end }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "collector.serviceAccountName" -}}
{{- if .Values.collector.serviceAccount -}}
{{- default (include "collector.fullname" .) .Values.collector.serviceAccount.nameOverride }}
{{- else }}
{{- include "collector.fullname" . }}
{{- end }}
{{- end }}


{{/*
Create the name of the ClusterRole to use
*/}}
{{- define "collector.clusterRoleName" -}}
{{- if .Values.collector.clusterRole -}}
{{- default (include "collector.fullname" .) .Values.collector.clusterRole.nameOverride }}
{{- else }}
{{- include "collector.fullname" . }}
{{- end }}
{{- end }}
