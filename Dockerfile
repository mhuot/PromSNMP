# Final image
FROM eclipse-temurin:21-jdk-noble

# Install handy utilites and clean up apt cache
RUN apt-get update && \
    apt-get install -y \
      bind9-utils \
      dnsutils \
      iproute2 \
      iputils-ping \
      iputils-tracepath \
      ncat \
      net-tools \
      reptyr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Invalidate build cache only when we have changed the code
ARG VERSION
ARG GIT_SHORT_HASH

COPY target/promsnmp-*.jar /app/promsnmp.jar

# Set the working directory
WORKDIR /app

ENTRYPOINT ["java"]

# Add OpenTelemetry Java agent
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar
RUN chmod 644 /app/opentelemetry-javaagent.jar

CMD ["-XX:+PrintCommandLineFlags", "-Xlog:os,class,gc*=debug:file=/tmp/jvm-startup.log:time,level,tags", "-javaagent:/app/opentelemetry-javaagent.jar", "-jar", "promsnmp.jar"]

# Invalidate only the cache for the layer with labels when we rebuild the same code
ARG DATE="1970-01-01T00:00:00Z"

LABEL org.opencontainers.image.created="${DATE}" \
      org.opencontainers.image.authors="TBD" \
      org.opencontainers.image.url="TBD" \
      org.opencontainers.image.source="https://github.com/pbrane/PromSNMP" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${GIT_SHORT_HASH}" \
      org.opencontainers.image.vendor="pbrane" \
      org.opencontainers.image.licenses="TBD"

## Runtime information for exposing metrics on port 8080/tcp by default

EXPOSE 8080/tcp
