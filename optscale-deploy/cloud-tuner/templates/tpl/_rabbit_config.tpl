{{- define "rabbitmq.conf" -}}
## RabbitMQ configuration
## Ref: https://github.com/rabbitmq/rabbitmq-server/blob/master/docs/rabbitmq.conf.example

## Clustering
cluster_formation.peer_discovery_backend  = rabbit_peer_discovery_k8s
cluster_formation.k8s.host = kubernetes.default.svc.{{ .Values.clusterDomain }}
cluster_formation.k8s.address_type = hostname
cluster_formation.node_cleanup.interval = 10
# Set to false if automatic cleanup of absent nodes is desired.
# This can be dangerous, see http://www.rabbitmq.com/cluster-formation.html#node-health-checks-and-cleanup.
cluster_formation.node_cleanup.only_log_warning = true
cluster_partition_handling = autoheal

## Management API
management.listener.port = 15672
management.listener.ssl = false

management.load_definitions = /etc/definitions/definitions.json

## Memory-based Flow Control threshold
vm_memory_high_watermark.absolute = {{ .Values.rabbitmq.memory_limit }}MB
{{- end }}

{{- define "rabbit-plugins" -}}
[
  rabbitmq_shovel,
  rabbitmq_shovel_management,
  rabbitmq_federation,
  rabbitmq_federation_management,
  rabbitmq_consistent_hash_exchange,
  rabbitmq_management,
  rabbitmq_peer_discovery_k8s
].
{{- end }}

{{- define "definitions.json" -}}
{
  "users": [
    {
      "name": "{{ .Values.rabbitmq.credentials.username }}",
      "password": "{{ .Values.rabbitmq.credentials.password }}",
      "tags": "administrator"
    }
  ],
  "vhosts": [
    {
      "name": "/"
    }
  ],
  "permissions": [
    {
      "user": "{{ .Values.rabbitmq.credentials.username }}",
      "vhost": "/",
      "configure": ".*",
      "write": ".*",
      "read": ".*"
    }
  ],
  "policies": [
    {
      "name": "ha-all",
      "pattern": ".*",
      "vhost": "/",
      "definition": {
        "ha-mode": "all",
        "ha-sync-mode": "automatic",
        "ha-sync-batch-size": 1
      }
    }
  ]
}
{{- end }}