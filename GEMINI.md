# PromSNMP

## Project Overview

**PromSNMP** is a Spring Boot application designed to bridge the gap between SNMP-enabled network devices and Prometheus monitoring. It acts as an exporter, querying devices via SNMP and exposing the metrics in a format that Prometheus can scrape.

**Key Features:**
*   **Protocol Support:** Supports SNMP v1, v2c, and v3.
*   **Metric Exposure:**
    *   `/snmp`: Standard Prometheus time series and classic histograms.
    *   `/metrics`: OpenMetrics format with support for native histograms.
*   **Service Discovery:** Provides a `/targets` endpoint for Prometheus HTTP Service Discovery.
*   **Caching:** specific caching mechanisms (Caffeine) for efficiency.
*   **Storage:** Uses an in-memory H2 database for internal configuration and state.

## Architecture & Technologies

*   **Language:** Java 21
*   **Framework:** Spring Boot 3.5.0
*   **Build Tool:** Maven (Wrapper `mvnw` included)
*   **Key Libraries:**
    *   `snmp4j`: For underlying SNMP communication.
    *   `micrometer-registry-prometheus`: For metrics exposition.
    *   `spring-shell`: For CLI capabilities (interactive mode disabled by default).
    *   `spring-boot-starter-data-jpa` & `h2`: Persistence.

## Building and Running

### Prerequisites
*   Java 21
*   Maven (or use provided `./mvnw`)
*   Docker (optional, for containerized run/dev stack)

### Build Commands

The project includes a `Makefile` to simplify common tasks.

*   **Compile and Assemble (skips tests):**
    ```bash
    make promsnmp
    # Or using Maven directly (runs tests):
    ./mvnw clean install
    ```

*   **Build Docker Image:**
    ```bash
    make oci
    ```

### Running the Application

*   **Local JAR:**
    ```bash
    java -jar target/promsnmp-*.jar
    ```
    The application will start on port `8080` (default).

*   **Docker:**
    ```bash
    docker run -it --init --rm -p "8080:8080/tcp" local/promsnmp:<version>
    ```

### Development Environment

A pre-configured Docker Compose stack with Prometheus and Grafana is available in the `deployment` directory.

1.  **Start the stack:**
    ```bash
    cd deployment
    docker compose up -d
    ```
2.  **Access Services:**
    *   **PromSNMP:** [http://localhost:8080](http://localhost:8080)
    *   **Prometheus:** [http://localhost:9090](http://localhost:9090)
    *   **Grafana:** [http://localhost:3000](http://localhost:3000) (admin/admin)

## Key Files & Directories

*   `src/main/java/org/promsnmp/promsnmp/PromSnmp.java`: Main application entry point.
*   `src/main/resources/application.properties`: Core configuration (ports, DB settings, etc.).
*   `pom.xml`: Maven dependency and build configuration.
*   `Makefile`: Shortcuts for building, releasing, and containerizing.
*   `deployment/`: Docker Compose setup for local testing/playground.
*   `Dockerfile`: Definition for the production container image.

## Conventions

*   **Code Style:** Follows standard Spring Boot and Java conventions.
*   **Branching:** `main` is the primary development branch.
*   **Releasing:** Uses `make release RELEASE_VERSION=x.y.z` to handle version bumping, tagging, and committing.
*   **Logging:** Uses standard SLF4J/Logback (implied by Spring Boot).
