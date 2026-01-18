# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build (compiles, skips tests)
make

# Build and run tests
make tests

# Build Docker image
make oci

# Clean build artifacts
make clean

# Run application locally
java -jar target/promsnmp-*.jar

# Create a release (from main branch only)
make release RELEASE_VERSION=x.y.z
```

## Prerequisites

- Java 21
- Maven (wrapper `./mvnw` included)
- Docker (for container builds)

## Architecture Overview

PromSNMP is a Spring Boot 3.5 application that bridges SNMP network devices to Prometheus. It acts as an SNMP exporter with dynamic inventory management.

### Key Packages

- `controllers/` - REST endpoints: `MetricsController` (/snmp, /metrics), `PromSnmpController` (/promsnmp/*), `DiscoveryController`, `InventoryController`
- `services/` - Business logic: `PrometheusMetricsService`, `InventoryService`, `DiscoverySeedService`, `PrometheusHistogramService`
- `services/prometheus/` - SNMP-to-Prometheus metric conversion and scheduling
- `repositories/jpa/` - H2 database persistence for agents, devices, discovery seeds
- `inventory/` - Device inventory management and encrypted JSON persistence
- `inventory/discovery/` - Network discovery engine (`SnmpAgentDiscovery`, `SnmpDiscoveryScheduler`)
- `snmp/` - SNMP protocol handling with snmp4j (v1/v2c/v3 support)
- `model/` - JPA entities: `Agent`, `NetworkDevice`, `DiscoverySeed`, `CommunityAgent`, `UserAgent`

### Data Flow

1. Discovery: Network scans find SNMP devices → stored in H2 + encrypted JSON file
2. Exposure: `/targets` exposes devices for Prometheus HTTP Service Discovery
3. Scraping: `/snmp?target=X` or `/metrics?target=X` triggers SNMP queries → returns Prometheus metrics
4. Caching: Caffeine cache reduces device polling load

### Key Configuration

- `PROM_ENCRYPT_KEY` - Encryption key for inventory file
- `DISCOVERY_CRON` - Cron expression for scheduled discovery (default: 2 AM)
- `DISCOVERY_ON_START` - Run discovery on application start
- Default port: 8080

## Development Stack

A Docker Compose playground with Prometheus and Grafana is available:

```bash
cd deployment
docker compose up -d
```

Access: Grafana (localhost:3000, admin/admin), Prometheus (localhost:9090), PromSNMP (localhost:8080)
