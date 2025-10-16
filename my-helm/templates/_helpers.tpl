{{- define "chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.deployment.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

