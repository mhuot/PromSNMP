# PromSNMP Metrics [![promsnmp-build](https://github.com/pbrane/promsnmp-metrics/actions/workflows/promsnmp-build.yaml/badge.svg)](https://github.com/pbrane/promsnmp-metrics/actions/workflows/promsnmp-build.yaml)

![promSnmpCast](https://github.com/user-attachments/assets/13e0b6a7-6fe7-49f0-9e98-726e736e1370)

## Key Features & Differentiators

*   **Dynamic Inventory & Discovery:** Unlike the standard `snmp_exporter` which relies on static configuration files, PromSNMP Metrics allows you to dynamically add targets via a REST API. It then exposes these targets to Prometheus via HTTP Service Discovery (`/targets`).
*   **Native Histograms:** Generates high-fidelity Native Histograms for interface utilization, providing far better insight into bandwidth usage patterns than classic buckets alone.
*   **Persistent State:** The inventory is persisted to an encrypted JSON file (`promsnmp-inventory.json`), ensuring your configuration survives restarts without needing an external database.
*   **Protocol Support:** Full support for SNMP v1, v2c, and v3 (Auth/Priv).
*   **Metric Exposure:**
    *   `/snmp`: Standard Prometheus time series and classic histograms.
    *   `/metrics`: OpenMetrics format with native histograms.
*   **Efficiency:** Built-in caching (Caffeine) to reduce load on network devices while serving frequent scrapes.

## 🔭 Network Discovery

PromSNMP features an automated discovery engine that scans your network for SNMP-enabled devices and automatically adds them to the inventory.

### 1. Seeding Discovery
You can initiate a discovery scan by providing a list of IP addresses (targets) and the SNMP credentials to try against them.

**Endpoint:** `POST /promsnmp/discovery`

**Example Request:**
```json
{
  "snmpConfig": {
    "version": 1,
    "readCommunity": "public"
  },
  "targets": ["192.168.1.1", "192.168.1.2"]
}
```

**Query Parameters:**
*   `scheduleNow` (boolean, default: `true`): If true, starts the scan immediately.
*   `saveSeed` (boolean, default: `false`): If true, saves these credentials and targets for the periodic scheduled scan.

### 2. Scheduled Scans
The application can run discovery scans periodically based on a Cron expression.
*   **Config:** `DISCOVERY_CRON` (default: `0 0 2 * * *` - nightly at 2 AM).
*   Any devices found during these scans are automatically added to the inventory and exposed via `/targets`.

### 3. Managing Seeds
Use the discovery API to manage what parts of your network are being scanned:
*   `GET /promsnmp/discovery`: List all saved discovery seeds.
*   `DELETE /promsnmp/discovery/{id}`: Remove a specific discovery seed.

### 4. Persistence & Startup
Discovery seeds and the resulting device inventory are persisted across application restarts (default: `promsnmp-inventory.json`).
*   **Startup Scans:** By setting `DISCOVERY_ON_START=true`, the application will immediately trigger a discovery scan for all saved seeds upon booting.
*   **Encrypted Storage:** The inventory is stored in an encrypted format using the key provided via `PROM_ENCRYPT_KEY`.

## 👩‍🏭 Build from source

Check out the source code with

```shell
git clone https://github.com/pbrane/promsnmp-metrics.git
```

Compile and assemble the JAR file including the test suite

```shell
make
```

Build a Docker container image in your local registry

```shell
make oci
```

## 🕹️ Run the application

Start the application locally

```shell
java -jar target/promsnmp-*.jar
```

Start the application using Docker

```shell
docker run -it --init --rm -p "8082:8080/tcp" local/promsnmp-metrics:$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
```
## 🔌 API Endpoints

The application exposes the following endpoints:

| Endpoint                     | Method | Description                                                          |
|------------------------------|--------|----------------------------------------------------------------------|
| `/promsnmp/hello`            | GET    | Returns a simple "Hello World" response                              |
| `/promsnmp/evictCache`       | GET    | Clears the cache of metrics in memory                                |
| `/promsnmp/authProtocols`    | GET    | Lists the supported SNMP Authorization Protocols                     |
| `/promsnmp/privProtocols`    | GET    | Lists the supported SNMP Privacy Protocols                           |
| `/promsnmp/threadPools`      | GET    | Lists the current status of the PromSNMP Threadpools                 |
| `/promsnmp/inventory`        | GET    | Export current PromSNMP Inventory as JSON                            |
| `/promsnmp/inventory`        | POST   | Import PromSNMP Inventory from JSON                                  |
| `/promsnmp/discovery`        | GET    | Lists all saved discovery seeds                                      |
| `/promsnmp/discovery`        | POST   | Create a new discovery seed / trigger a scan                         |
| `/promsnmp/discovery`        | DELETE | Delete all discovery seeds                                           |
| `/promsnmp/discovery/{id}`   | GET    | Details for a specific discovery seed                                |
| `/promsnmp/discovery/{id}`   | DELETE | Delete a specific discovery seed                                     |
| `/targets`                   | GET    | Prometheus HTTP Service Discovery endpoint                           |
| `/snmp`                      | GET    | Scrapes SNMP metrics for a specified target (param: `target`)        |
| `/metrics`                   | GET    | OpenMetrics format with native histograms (optional param: `target`) |

## Histogram Support

![Histogram Explainer](docs/images/histogram-explainer.png)

PromSNMP supports both classic Prometheus histograms and native histograms:

- The `/snmp` endpoint provides standard Prometheus time series and classic histograms
- The `/metrics` endpoint provides time series, classic histograms, and native histograms using OpenMetrics format
- Interface utilization metrics are available as histograms, showing bandwidth usage as a percentage

## 🎢 Deployment playground

You can find in the development folder a stack with Prometheus and Grafana.

```shell
cd deployment
docker compose up -d
```
Endpoints:
* Grafana: http://localhost:3000, login admin, password admin
* Prometheus: http://localhost:9090
* PromSNMP: http://localhost:8080

## Create and publish a new release

To make a release the following steps are required:

1. Set the Maven project version without -SNAPSHOT
2. Make a version tag with git
3. Set a new SNAPSHOT version in the main branch
4. Publish a release 

To help you with these steps you can run a make goal `make release`.
It requires a version number you want to release.
As an example the current main branch has 0.0.2-SNAPSHOT and you want to release 0.0.2 you need to run

```shell
make release RELEASE_VERSION=0.0.2
```

The 0.0.2 version is set with the git tag v0.0.2.
It will automatically set the main branch to 0.0.3-SNAPSHOT for the next iteration.
All changes stay in your local repository.
When you want to publish the new released version you need to run

```shell
git push                # Push the main branch with the new -SNAPSHOT version
git push origin v0.0.2  # Push the release tag which triggers the build which publishes artifacts.
```
