{{/*
Expand the name of the chart.
*/}}
{{- define "ziplinee-ci-api.name" -}}
{{- default .Chart.Name $.Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ziplinee-ci-api.fullname" -}}
{{- if $.Values.fullnameOverride }}
{{- $.Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name $.Values.nameOverride }}
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
{{- define "ziplinee-ci-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ziplinee-ci-api.labels" -}}
helm.sh/chart: {{ include "ziplinee-ci-api.chart" . }}
{{ include "ziplinee-ci-api.selectorLabels" . }}
{{- if .Chart.Version }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $key, $value := $.Values.extraLabels }}
{{ $key }}: {{ $value }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ziplinee-ci-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ziplinee-ci-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ziplinee-ci-api.serviceAccountName" -}}
{{- if $.Values.serviceAccount.create }}
{{- default (include "ziplinee-ci-api.fullname" .) $.Values.serviceAccount.name }}
{{- else }}
{{- default "default" $.Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the namespace for build/release jobs
*/}}
{{- define "ziplinee-ci-api.jobNamespace" -}}
{{- if $.Values.jobNamespaceOverride }}
{{- $.Values.jobNamespaceOverride }}
{{- else }}
{{- .Release.Namespace }}-jobs
{{- end }}
{{- end }}
