ollama:
  enabled: false

pipelines:
  enabled: false

tika:
  enabled: false

websocket:
  enabled: true
  manager: redis
  redis:
    enabled: true

replicaCount: 1
image:
  repository: ghcr.io/open-webui/open-webui
  tag: "0.6.5"
  pullPolicy: "IfNotPresent"

livenessProbe:
  httpGet:
    path: /health
    port: http
  failureThreshold: 1
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health/db
    port: http
  failureThreshold: 1
  periodSeconds: 10

startupProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 5
  failureThreshold: 20

managedCertificate:
  enabled: false

ingress:
  enabled: false

persistence:
  enabled: true
  provider: s3
  s3:
    accessKey: "${s3_access_key}"
    secretKey: "${s3_secret_key}"
    endpointUrl: "${s3_endpoint_url}"
    region: "${s3_region}"
    bucket: "${s3_bucket}"
    keyPrefix: "${s3_key_prefix}"

enableOpenaiApi: true
openaiBaseApiUrl: "https://api.scaleway.ai/${openwebui_project_id}/v1"
extraEnvVars:
  - name: OPENAI_API_KEY
    value: ${scaleway_generative_api_secret_key}

sso:
  enabled: false

databaseUrl: "postgresql://open-webui:${openwebui_postgres_password}@postgresql:5432/open-webui"

postgresql:
  enabled: true
  fullnameOverride: open-webui-postgres
  architecture: standalone
  auth:
    database: open-webui
    postgresPassword: 0p3n-w3bu!
    username: open-webui
    password: ko2pauTaem
  primary:
    persistence:
      size: 1Gi
    resources:
      requests:
        memory: 256Mi
        cpu: 250m
      limits:
        memory: 512Mi
        cpu: 500m

