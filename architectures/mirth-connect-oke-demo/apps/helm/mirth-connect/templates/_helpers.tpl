{{- define "mirth-connect.name" -}}
mirth-connect
{{- end -}}

{{- define "mirth-connect.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
