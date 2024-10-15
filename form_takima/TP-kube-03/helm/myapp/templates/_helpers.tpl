{{- define "AppCtx.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "AppCtxWithEnv.name" -}}
{{- printf "%s-%s" .Chart.Name .Values.env }}
{{- end }}

{{- define "frontSelector.name" -}}
{{- printf "%s-%s-%s" .Chart.Name .Values.env "front" }}
{{- end }}

{{- define "apiSelector.name" -}}
{{- printf "%s-%s-%s" .Chart.Name .Values.env "api" }}
{{- end }}

{{- define "dbSelector.name" -}}
{{- printf "%s-%s-%s" .Chart.Name .Values.env "db" }}
{{- end }}

{{- define "ApiUrl" -}}
  {{- if .Values.api.ingress.tlsEnabled }}  
    {{- printf "https://%s.%s.%s" .Values.api.ingress.prefix .Values.env .Values.url_suffix | quote }}  
  {{- else }}  
    {{- printf "http://%s.%s.%s" .Values.api.ingress.prefix .Values.env .Values.url_suffix | quote }}  
  {{- end }}
{{- end }}

{{- define "FrontUrl" -}}
  {{- if .Values.front.ingress.tlsEnabled }}  
    {{- printf "https://%s.%s.%s" .Values.front.ingress.prefix .Values.env .Values.url_suffix | quote }}  
  {{- else }}  
    {{- printf "http://%s.%s.%s" .Values.front.ingress.prefix .Values.env .Values.url_suffix | quote }}  
  {{- end }}
{{- end }}