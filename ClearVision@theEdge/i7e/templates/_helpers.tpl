{{- define "artifactRegistryDockerSecret" }}
{{- $registry := "us-east4-docker.pkg.dev" -}}
{{- $username := "_json_key_base64" -}}
{{- $password := .Values.i7e.serviceAccountJSON | b64enc }}
{{- with .Values.i7e.serviceAccountJSON }}
{{- printf "{\"auths\":{\"%s\":{\"auth\":\"%s\"}}}" $registry (printf "%s:%s" $username $password | b64enc) | b64enc }}
{{- end }}
{{- end }}