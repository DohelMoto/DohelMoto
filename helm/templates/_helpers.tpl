{{/*
Expand the name of the chart.
*/}}
{{- define "dohelmoto.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dohelmoto.fullname" -}}
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
{{- define "dohelmoto.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dohelmoto.labels" -}}
helm.sh/chart: {{ include "dohelmoto.chart" . }}
{{ include "dohelmoto.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dohelmoto.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dohelmoto.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dohelmoto.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dohelmoto.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image name
*/}}
{{- define "dohelmoto.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry .Values.image.repository .Values.image.tag -}}
{{- else }}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end }}
{{- end }}

{{/*
Create the frontend image name
*/}}
{{- define "dohelmoto.frontend.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry .Values.frontend.image.repository .Values.frontend.image.tag -}}
{{- else }}
{{- printf "%s:%s" .Values.frontend.image.repository .Values.frontend.image.tag -}}
{{- end }}
{{- end }}

{{/*
Create the backend image name
*/}}
{{- define "dohelmoto.backend.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry .Values.backend.image.repository .Values.backend.image.tag -}}
{{- else }}
{{- printf "%s:%s" .Values.backend.image.repository .Values.backend.image.tag -}}
{{- end }}
{{- end }}

{{/*
Create the postgres image name
*/}}
{{- define "dohelmoto.postgres.image" -}}
{{- printf "%s:%s" .Values.postgresql.image.repository .Values.postgresql.image.tag -}}
{{- end }}

{{/*
Create the redis image name
*/}}
{{- define "dohelmoto.redis.image" -}}
{{- printf "%s:%s" .Values.redis.image.repository .Values.redis.image.tag -}}
{{- end }}

{{/*
Create the namespace name - always use the release namespace
*/}}
{{- define "dohelmoto.namespace" -}}
{{- .Release.Namespace }}
{{- end }}

{{/*
Create the storage class name
*/}}
{{- define "dohelmoto.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else if .Values.postgresql.persistence.storageClass }}
{{- .Values.postgresql.persistence.storageClass }}
{{- else if .Values.redis.persistence.storageClass }}
{{- .Values.redis.persistence.storageClass }}
{{- else }}
{{- "local-path" }}
{{- end }}
{{- end }}

{{/*
Create the database URL
*/}}
{{- define "dohelmoto.databaseUrl" -}}
{{- printf "postgresql://%s:%s@%s:%d/%s" .Values.postgresql.env.POSTGRES_USER "password" "postgres-service" (.Values.postgresql.service.port | int) .Values.postgresql.env.POSTGRES_DB -}}
{{- end }}

{{/*
Create the Redis URL
*/}}
{{- define "dohelmoto.redisUrl" -}}
{{- printf "redis://%s:%d" "redis-service" (.Values.redis.service.port | int) -}}
{{- end }}

{{/*
Create the allowed origins
*/}}
{{- define "dohelmoto.allowedOrigins" -}}
{{- printf "%s,http://%s:%d" .Values.configMap.data.ALLOWED_ORIGINS "frontend-service" (.Values.frontend.service.port | int) -}}
{{- end }}
