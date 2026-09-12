{{/* Expand the name of the chart. */}}
{{- define "spliit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default fully qualified app name. */}}
{{- define "spliit.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "spliit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spliit.labels" -}}
helm.sh/chart: {{ include "spliit.chart" . }}
{{ include "spliit.selectorLabels" . }}
app.kubernetes.io/version: {{ include "spliit.imageTag" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "spliit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spliit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "spliit.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "spliit.postgresSecretName" -}}
{{- if .Values.postgresql.existingSecret -}}
{{- .Values.postgresql.existingSecret -}}
{{- else -}}
{{- printf "%s-postgresql" (include "spliit.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "spliit.postgresUrl" -}}
{{- printf "postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@%s:%v/%s" .Values.postgresql.host .Values.postgresql.port .Values.postgresql.database -}}
{{- end -}}
