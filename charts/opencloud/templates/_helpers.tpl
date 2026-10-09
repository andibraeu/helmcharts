{{/* Expand the name of the chart. */}}
{{- define "opencloud.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default fully qualified app name. */}}
{{- define "opencloud.fullname" -}}
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

{{- define "opencloud.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "opencloud.labels" -}}
helm.sh/chart: {{ include "opencloud.chart" . }}
{{ include "opencloud.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "opencloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opencloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "opencloud.yjs.labels" -}}
helm.sh/chart: {{ include "opencloud.chart" . }}
{{ include "opencloud.yjs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: yjs
{{- end -}}

{{- define "opencloud.yjs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opencloud.name" . }}-yjs
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "opencloud.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/* Public OpenCloud URL used for OC_URL and WOPI source. */}}
{{- define "opencloud.externalUrl" -}}
{{- if .Values.externalUrl -}}
{{- trimSuffix "/" .Values.externalUrl -}}
{{- else if and .Values.ingress.enabled .Values.ingress.hostname -}}
{{- printf "https://%s" .Values.ingress.hostname -}}
{{- else -}}
{{- printf "https://localhost:%v" .Values.service.port -}}
{{- end -}}
{{- end -}}

{{- define "opencloud.hostname" -}}
{{- $url := include "opencloud.externalUrl" . -}}
{{- $withoutScheme := regexReplaceAll "^https?://" $url "" -}}
{{- regexReplaceAll "/.*$" $withoutScheme "" -}}
{{- end -}}

{{- define "opencloud.adminSecretName" -}}
{{- if .Values.existingSecret -}}
{{- .Values.existingSecret -}}
{{- else -}}
{{- printf "%s-secrets" (include "opencloud.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "opencloud.configPvcName" -}}
{{- if .Values.persistence.config.existingClaim -}}
{{- .Values.persistence.config.existingClaim -}}
{{- else -}}
{{- printf "%s-config" (include "opencloud.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "opencloud.dataPvcName" -}}
{{- if .Values.persistence.data.existingClaim -}}
{{- .Values.persistence.data.existingClaim -}}
{{- else -}}
{{- printf "%s-data" (include "opencloud.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "opencloud.yjs.opencloudUrl" -}}
{{- if .Values.yjs.opencloudUrl -}}
{{- .Values.yjs.opencloudUrl -}}
{{- else -}}
{{- printf "http://%s:%v" (include "opencloud.fullname" .) .Values.service.port -}}
{{- end -}}
{{- end -}}

{{- define "opencloud.needsProxyConfig" -}}
{{- if or .Values.yjs.enabled .Values.radicale.enabled -}}
true
{{- end -}}
{{- end -}}

{{- define "opencloud.validate" -}}
{{- if and (gt (int .Values.replicaCount) 1) (eq .Values.persistence.data.accessMode "ReadWriteOnce") -}}
{{- fail "opencloud: replicaCount > 1 requires persistence.data.accessMode ReadWriteMany (NFS 4.2+ or CephFS)" -}}
{{- end -}}
{{- if and .Values.collaboration.enabled (not .Values.collaboration.appAddr) -}}
{{- fail "opencloud: collaboration.enabled requires collaboration.appAddr" -}}
{{- end -}}
{{- if and .Values.radicale.enabled (not .Values.radicale.url) -}}
{{- fail "opencloud: radicale.enabled requires radicale.url" -}}
{{- end -}}
{{- if and .Values.oidc.external.enabled (not .Values.oidc.external.issuer) -}}
{{- fail "opencloud: oidc.external.enabled requires oidc.external.issuer" -}}
{{- end -}}
{{- if and .Values.smtp.enabled (not .Values.smtp.host) -}}
{{- fail "opencloud: smtp.enabled requires smtp.host" -}}
{{- end -}}
{{- end -}}
