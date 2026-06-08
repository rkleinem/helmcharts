{{- define "base.chart" -}}
{{- printf "%s-%s" .Chart.Name (.Chart.Version | replace "+" "_") -}}
{{- end }}


{{/* Common selector labels */}}
{{- define "base.selectorLabels" -}}
app.kubernetes.io/name: {{ include "auditor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*********** Test Stuff ***********/}}

{{- define "auditor.loadCACert" -}}
{{- $.Files.Get .Values.global.certs.ca_cert | b64enc -}}
{{- end }}


{{/*}}
{{- printf "fooo" | b64enc -}}
{{- $.Files.Get (printf "%s" .Values.global.certs.ca_cert) | b64enc -}}


{{- define "process" -}}
{{- if .global.certs.ca_cert -}}
{{- $_ := set .global.certs "ca_cert" ($.Files.Get .global.certs.ca_cert | b64enc) -}}
{{- end -}}
{{- end -}}
{{*/}}


{{- define "auditor.prepareChildTlsValues" -}}

{{- if .Values.global.certs.useFiles -}}

    {{- $_ := set .Values.global.certs "ca_cert" ($.Files.Get .Values.global.certs.ca_cert | b64enc) -}}
    
    {{- with .Values.auditor -}}
    {{- $_ := set .certs "auditor_cert" ($.Files.Get .certs.auditor_cert | b64enc) -}}
    {{- $_ := set .certs "auditor_key" ($.Files.Get .certs.auditor_key | b64enc) -}}
    {{- end -}}

    {{- with index .Values "auditor-prometheus" -}}
    {{- $_ := set .certs "prom_cert" ($.Files.Get .certs.prom_cert | b64enc) -}}
    {{- $_ := set .certs "prom_key" ($.Files.Get .certs.prom_key | b64enc) -}}
    {{- end -}}

    {{- with index .Values "auditor-collector" -}}
    {{- $_ := set .certs "collector_cert" ($.Files.Get .certs.collector_cert | b64enc) -}}
    {{- $_ := set .certs "collector_key" ($.Files.Get .certs.collector_key | b64enc) -}}
    {{- end -}}

    {{- with index .Values "auditor-apel" -}}
    {{- $_ := set .auditorcerts "reporter_cert" ($.Files.Get .auditorcerts.reporter_cert | b64enc) -}}
    {{- $_ := set .auditorcerts "reporter_key" ($.Files.Get .auditorcerts.reporter_key | b64enc) -}}
    {{- $_ := set .apelcerts "apelclient_ca" ($.Files.Get .apelcerts.apelclient_ca | b64enc) -}}
    {{- $_ := set .apelcerts "apelclient_cert" ($.Files.Get .apelcerts.apelclient_cert | b64enc) -}}
    {{- $_ := set .apelcerts "apelclient_key" ($.Files.Get .apelcerts.apelclient_key | b64enc) -}}
    {{- end -}}

{{- end -}}

{{- end -}}

