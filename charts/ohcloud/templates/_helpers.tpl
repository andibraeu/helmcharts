{{/*
Expand the name of the chart.
*/}}
{{- define "ohcloud.name" -}}
{{- default .Chart.Name .Values.openhabcloudApp.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ohcloud.fullname" -}}
{{- if .Values.openhabcloudApp.fullnameOverride }}
{{- .Values.openhabcloudApp.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.openhabcloudApp.nameOverride }}
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
{{- define "ohcloud.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ohcloud.labels" -}}
helm.sh/chart: {{ include "ohcloud.chart" . }}
{{ include "ohcloud.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ohcloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ohcloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ohcloud.serviceAccountName" -}}
{{- if .Values.openhabcloudApp.serviceAccount.create }}
{{- default (include "ohcloud.fullname" .) .Values.openhabcloudApp.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.openhabcloudApp.serviceAccount.name }}
{{- end }}
{{- end }}
