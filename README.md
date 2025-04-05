# PromSNMP [![promsnmp-build](https://github.com/pbrane/PromSNMP/actions/workflows/promsnmp-build.yaml/badge.svg)](https://github.com/pbrane/PromSNMP/actions/workflows/promsnmp-build.yaml)

![promSnmpCast](https://github.com/user-attachments/assets/13e0b6a7-6fe7-49f0-9e98-726e736e1370)

## 👩‍🏭 Build from source

Check out the source code with

```shell
git clone https://github.com/pbrane/PromSNMP.git
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
docker run -it --init --rm -p "8082:8080/tcp" local/promsnmp:$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
```
## 🔌 API Endpoints

The application exposes the following endpoints:

| Endpoint                     | Method | Description                                                          |
|------------------------------|--------|----------------------------------------------------------------------|
| `/promSnmp/hello`            | GET    | Returns a simple "Hello World" response                              |
| `/promSnmp/metrics`          | GET    | Returns Prometheus metrics from available devices                    |
| `/promSnmp/metrics?instance=router-1.example.com` | GET | Returns metrics for a specific instance            |
| `/promSnmp/services`         | GET    | Returns available services in JSON format                            |
| `/promSnmp/evictCache`       | GET    | Clears the metrics cache                                             |
| `/actuator`                  | GET    | Spring Boot Actuator endpoints                                       |

## 🎢 Deployment playground

You can find in the deployment folder a stack with Prometheus and Grafana. Jaeger is optional for OpenTelemetry tracing.

### Basic Deployment

Start the stack with Prometheus and Grafana:

```shell
cd deployment
docker compose up -d
```

Endpoints:
* Grafana: http://localhost:3000 (login: admin, password: admin)
* Prometheus: http://localhost:9090
* PromSNMP: http://localhost:8080/promSnmp

### With OpenTelemetry Tracing (Optional)

To enable distributed tracing with Jaeger:

```shell
cd deployment
OTEL_ENABLED=http://jaeger:4317 docker compose --profile tracing up -d
```

Additional endpoints when tracing is enabled:
* Jaeger UI: http://localhost:16686

### OpenTelemetry Configuration

The application supports distributed tracing with OpenTelemetry. The following environment variables are configured:

```
OTEL_EXPORTER_OTLP_ENDPOINT: http://jaeger:4317  # Set to 'false' when Jaeger is not used
OTEL_EXPORTER_OTLP_PROTOCOL: grpc
OTEL_LOGS_EXPORTER: none                         # Logs exporting disabled by default
OTEL_SERVICE_NAME: promsnmp
OTEL_TRACES_SAMPLER: parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG: 1.0
OTEL_PROPAGATORS: tracecontext,baggage
```

The Docker Compose configuration uses profiles to make Jaeger optional, allowing you to run the stack with or without tracing capabilities.

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
