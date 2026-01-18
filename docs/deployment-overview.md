# PromSNMP Deployment Overview

This guide helps you choose the right deployment strategy for your PromSNMP installation based on your infrastructure, scale, and operational requirements.

---

## Deployment Options

```mermaid
flowchart TB
    subgraph Decision["Choose Your Deployment"]
        START["PromSNMP<br/>Deployment"] --> Q1{"Multiple<br/>Sites?"}

        Q1 -->|Yes| CLOUD["Cloud Manager<br/>(Recommended)"]
        Q1 -->|No| Q2{"Container<br/>Orchestration?"}

        Q2 -->|Kubernetes| K8S["Kubernetes<br/>Deployment"]
        Q2 -->|Docker/Swarm| DOCKER["Docker Compose<br/>Deployment"]
        Q2 -->|None| SINGLE["Single Instance<br/>(Dev/Test)"]
    end

    CLOUD --> CLOUD_DOC["cloud-manager-architecture.md"]
    K8S --> K8S_DOC["deployment-kubernetes.md"]
    DOCKER --> DOCKER_DOC["deployment-docker.md"]

    style CLOUD fill:#c8e6c9,stroke:#2e7d32
    style K8S fill:#e3f2fd,stroke:#1565c0
    style DOCKER fill:#fff3e0,stroke:#ef6c00
```

---

## Comparison Matrix

| Feature | Docker Compose | Kubernetes | Cloud Manager |
|---------|----------------|------------|---------------|
| **Complexity** | Low | Medium | High |
| **Setup Time** | Minutes | Hours | Days |
| **Sites Supported** | Single | Single | Multiple |
| **Auto-scaling** | Manual | HPA | HPA + Fleet |
| **Leader Election** | Static config | K8s native / Redis | Built-in |
| **Inventory Storage** | Shared volume | PVC (NFS/EFS) | Central database |
| **Upgrades** | Rolling (manual) | Rolling (auto) | Rolling + Fleet |
| **Monitoring** | Basic | Prometheus | Fleet dashboard |
| **Offline Operation** | N/A | N/A | Graceful degradation |
| **Best For** | Dev, Small prod | Single site prod | Enterprise, MSP |

---

## Architecture Comparison

### Docker Compose

![Docker Compose Deployment](images/docker-deployment.jpg)

<details>
<summary>View Mermaid Diagram</summary>

```mermaid
flowchart TB
    subgraph Host["Single Docker Host"]
        LB["HAProxy / Traefik"]
        P1["PromSNMP 1<br/>(Leader)"]
        P2["PromSNMP 2"]
        P3["PromSNMP 3"]
        VOL[("Shared Volume<br/>inventory.json")]

        LB --> P1 & P2 & P3
        P1 & P2 & P3 --> VOL
    end

    PROM["Prometheus"] --> LB
    P1 & P2 & P3 --> SNMP["SNMP Devices"]

    style Host fill:#fff3e0,stroke:#ef6c00
```
</details>

**Characteristics:**
- All containers on single host (or Swarm cluster)
- Shared Docker volume for inventory
- Static leader assignment via environment variable
- Simple health checks
- Manual scaling

**Documentation:** [deployment-docker.md](deployment-docker.md)

---

### Kubernetes

![Kubernetes Deployment](images/kubernetes-deployment.jpg)

<details>
<summary>View Mermaid Diagram</summary>

```mermaid
flowchart TB
    subgraph K8S["Kubernetes Cluster"]
        SVC["Service<br/>(ClusterIP)"]

        subgraph Pods["Deployment (3 replicas)"]
            P1["Pod 1<br/>(Leader)"]
            P2["Pod 2"]
            P3["Pod 3"]
        end

        PVC[("PersistentVolumeClaim<br/>NFS / EFS")]
        REDIS[("Redis<br/>Leader Election")]

        SVC --> P1 & P2 & P3
        P1 & P2 & P3 --> PVC
        P1 & P2 & P3 --> REDIS
    end

    ING["Ingress"] --> SVC
    PROM["Prometheus"] --> SVC
    P1 & P2 & P3 --> SNMP["SNMP Devices"]

    style K8S fill:#e3f2fd,stroke:#1565c0
```
</details>

**Characteristics:**
- Native K8s deployment with replicas
- PersistentVolumeClaim for shared storage
- Redis or K8s lease for leader election
- Rolling updates with PodDisruptionBudget
- HorizontalPodAutoscaler support
- Full observability stack integration

**Documentation:** [deployment-kubernetes.md](deployment-kubernetes.md)

---

### Cloud Manager

![Cloud Manager Deployment](images/cloud-manager-deployment.jpg)

<details>
<summary>View Mermaid Diagram</summary>

```mermaid
flowchart TB
    subgraph Cloud["Cloud Manager"]
        API["REST API"]
        WS["WebSocket"]
        DB[("PostgreSQL")]
        API <--> DB
        WS <--> DB
    end

    subgraph SiteA["Site A"]
        A1["PromSNMP"] & A2["PromSNMP"] & A3["PromSNMP"]
    end

    subgraph SiteB["Site B"]
        B1["PromSNMP"] & B2["PromSNMP"]
    end

    subgraph SiteC["Site C"]
        C1["PromSNMP"] & C2["PromSNMP"]
    end

    A1 & A2 & A3 <-->|"HTTPS/WSS"| API & WS
    B1 & B2 <-->|"HTTPS/WSS"| API & WS
    C1 & C2 <-->|"HTTPS/WSS"| API & WS

    style Cloud fill:#c8e6c9,stroke:#2e7d32
```
</details>

**Characteristics:**
- Centralized management across sites
- Real-time sync via WebSocket
- Built-in leader election per site
- Fleet-wide visibility and control
- Offline resilience with local cache
- Full audit trail

**Documentation:** [cloud-manager-architecture.md](cloud-manager-architecture.md)

---

## Quick Start by Deployment Type

### Docker Compose (Fastest)

```bash
# Clone and start
git clone https://github.com/pbrane/promsnmp-metrics.git
cd promsnmp-metrics/deployment

# Start the stack
docker compose up -d

# Access
# - PromSNMP: http://localhost:8080
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000 (admin/admin)
```

### Kubernetes

```bash
# Apply manifests
kubectl apply -f https://raw.githubusercontent.com/pbrane/promsnmp-metrics/main/deploy/kubernetes/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/pbrane/promsnmp-metrics/main/deploy/kubernetes/promsnmp.yaml

# Check status
kubectl get pods -n promsnmp -w
```

### Cloud Manager

```bash
# Deploy manager (Helm)
helm repo add promsnmp https://charts.promsnmp.io
helm install promsnmp-manager promsnmp/manager -n promsnmp-system

# Register a site
curl -X POST https://manager.example.com/api/v1/sites \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"id": "site-01", "label": "Primary DC"}'

# Deploy instances at site
export MANAGER_URL=https://manager.example.com
export SITE_ID=site-01
docker compose -f docker-compose.managed.yml up -d
```

---

## Choosing the Right Option

### Use Docker Compose when:
- Running a single site with < 500 devices
- Limited Kubernetes expertise
- Development or testing environments
- Quick proof-of-concept needed
- Single host is sufficient

### Use Kubernetes when:
- Running a single site with 500+ devices
- Already have K8s infrastructure
- Need auto-scaling capabilities
- Want native rolling updates
- Require pod disruption budgets
- Integrating with existing K8s monitoring

### Use Cloud Manager when:
- Managing multiple geographic sites
- Need centralized fleet visibility
- Require audit trails for compliance
- Want automatic leader election across sites
- Building a managed service (MSP)
- Need offline resilience at sites

---

## Common Components

All deployment options share these core concepts:

### Leader Election

```mermaid
stateDiagram-v2
    [*] --> Follower
    Follower --> Leader: Elected
    Leader --> Follower: Lost election
    Leader --> Leader: Heartbeat OK

    note right of Leader
        Only leader runs:
        • SNMP discovery
        • Inventory writes
    end note

    note right of Follower
        All instances:
        • Serve /metrics
        • Serve /snmp
        • Read inventory
    end note
```

### Inventory Synchronization

```mermaid
sequenceDiagram
    participant Leader
    participant Storage as Shared Storage
    participant Follower

    Leader->>Leader: Run SNMP discovery
    Leader->>Storage: Write inventory
    Storage-->>Follower: Read on startup
    Storage-->>Follower: Watch for changes
    Follower->>Follower: Reload H2 database
```

### Health Checks

All deployments should implement:

| Check | Endpoint | Purpose |
|-------|----------|---------|
| Liveness | `/actuator/health/liveness` | Restart if unhealthy |
| Readiness | `/actuator/health/readiness` | Traffic routing |
| Startup | `/actuator/health` | Initial boot |

---

## Upgrade Strategies

### Rolling Update (All Options)

```mermaid
flowchart LR
    subgraph Before
        B1["v1"] & B2["v1"] & B3["v1"]
    end

    subgraph During
        D1["v1"] & D2["v1"] & D3["v2"]
    end

    subgraph After
        A1["v2"] & A2["v2"] & A3["v2"]
    end

    Before --> During --> After
```

### Blue-Green (K8s & Cloud Manager)

```mermaid
flowchart LR
    subgraph Before
        BLUE1["Blue: v1 x3"]
        GREEN1["Green: —"]
        SVC1["Service"] --> BLUE1
    end

    subgraph During
        BLUE2["Blue: v1 x3"]
        GREEN2["Green: v2 x3"]
        SVC2["Service"] --> BLUE2
    end

    subgraph After
        BLUE3["Blue: —"]
        GREEN3["Green: v2 x3"]
        SVC3["Service"] --> GREEN3
    end

    Before --> During --> After
```

---

## Monitoring Integration

### Prometheus Configuration

All deployments expose metrics that Prometheus can scrape:

```yaml
scrape_configs:
  - job_name: 'promsnmp'
    # For Docker Compose
    static_configs:
      - targets: ['promsnmp-1:8080', 'promsnmp-2:8080', 'promsnmp-3:8080']

    # For Kubernetes (service discovery)
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names: ['promsnmp']

    # For Cloud Manager (HTTP SD)
    http_sd_configs:
      - url: 'http://promsnmp:8080/targets'
```

### Key Metrics

```promql
# Instance health
up{job="promsnmp"}

# Cache efficiency
rate(cache_gets_total{cache="metrics",result="hit"}[5m]) /
rate(cache_gets_total{cache="metrics"}[5m])

# SNMP query latency
histogram_quantile(0.99, rate(snmp_query_duration_seconds_bucket[5m]))

# Device count
promsnmp_inventory_device_count
```

---

## Security Considerations

| Aspect | Docker | Kubernetes | Cloud Manager |
|--------|--------|------------|---------------|
| **Network** | Docker network | NetworkPolicy | TLS + WAF |
| **Secrets** | .env file | K8s Secrets | Vault / KMS |
| **RBAC** | N/A | K8s RBAC | API tokens |
| **Encryption** | Volume encryption | PVC encryption | At-rest + in-transit |

---

## Next Steps

1. **Choose your deployment type** based on the comparison above
2. **Read the detailed guide** for your chosen option:
   - [Docker Compose Deployment](deployment-docker.md)
   - [Kubernetes Deployment](deployment-kubernetes.md)
   - [Cloud Manager Architecture](cloud-manager-architecture.md)
3. **Set up monitoring** using the Prometheus configuration
4. **Configure alerting** for critical metrics

---

## Document Index

| Document | Description |
|----------|-------------|
| [deployment-docker.md](deployment-docker.md) | Docker Compose deployment guide |
| [deployment-kubernetes.md](deployment-kubernetes.md) | Kubernetes deployment guide |
| [cloud-manager-architecture.md](cloud-manager-architecture.md) | Cloud Manager specification |
| [deployment-plan-fault-tolerant.md](deployment-plan-fault-tolerant.md) | Original comprehensive plan |
