#!/bin/bash

APP_NAME="mp-test-app"
mkdir -p helm/templates

# Chart.yaml
cat > helm/Chart.yaml <<EOF
apiVersion: v2
name: $APP_NAME
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

# 기본 values.yaml (dev용 복사본도 같이 생성)
cat > helm/values.yaml <<EOF
env: dev
namespace: mp-dev
image:
  repository: <ECR_REPO_URL>
  tag: latest
replicaCount: 2
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
EOF

cp helm/values.yaml helm/dev-values.yaml
cp helm/values.yaml helm/stg-values.yaml
cp helm/values.yaml helm/prd-values.yaml

# templates/deployment.yaml
cat > helm/templates/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          resources:
            limits:
              memory: {{ .Values.resources.limits.memory }}
              cpu: {{ .Values.resources.limits.cpu }}
            requests:
              memory: {{ .Values.resources.requests.memory }}
              cpu: {{ .Values.resources.requests.cpu }}
EOF

# templates/service.yaml
cat > helm/templates/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}
  namespace: {{ .Values.namespace }}
spec:
  type: ClusterIP
  selector:
    app: {{ .Chart.Name }}
  ports:
    - port: 80
      targetPort: 8080
EOF

# templates/ingress.yaml
cat > helm/templates/ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Chart.Name }}
  namespace: {{ .Values.namespace }}
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: {{ .Values.env }}.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Chart.Name }}
                port:
                  number: 80
EOF

echo "✅ Helm 구조가 생성되었습니다: helm/"
