package org.promsnmp.promsnmp.services.prometheus;

import org.promsnmp.promsnmp.repositories.PrometheusDiscoveryRepository;
import org.promsnmp.promsnmp.repositories.PrometheusMetricsRepository;
import org.promsnmp.promsnmp.services.PrometheusDiscoveryService;
import org.promsnmp.promsnmp.services.PrometheusMetricsService;
import org.promsnmp.promsnmp.services.cache.CachedMetricsService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service("ResSvc")
public class ResourceBasedService implements PrometheusMetricsService, PrometheusDiscoveryService {

    private final PrometheusMetricsRepository metricsRepository;
    private final PrometheusDiscoveryRepository discoveryRepository;
    private final CachedMetricsService cachedMetrics;

    public ResourceBasedService(
            @Qualifier("ClassPathRepo") PrometheusMetricsRepository metricsRepository,
            @Qualifier("ClassPathRepo") PrometheusDiscoveryRepository prometheusDiscoveryRepository,
            CachedMetricsService cachedMetricsService) {
        this.metricsRepository = metricsRepository;
        this.discoveryRepository = prometheusDiscoveryRepository;
        this.cachedMetrics = cachedMetricsService;
    }

    @Override
    public Optional<String> getServices() {
        return discoveryRepository.readServices();
    }

    @Override
    public Optional<String> getMetrics(String instance, boolean regex) {
        return cachedMetrics.getRawMetrics(instance)
                .map(this::formatMetrics)
                .map(metrics -> filterByInstance(metrics, instance, regex));
    }

    // This one is cached — just returns the raw metrics text
    @Cacheable(value = "metrics", key = "#instance")
    public Optional<String> getRawMetrics(String instance) {
        return metricsRepository.readMetrics(instance);
    }

    private String formatMetrics(String rawMetrics) {
        return Stream.of(rawMetrics.split("\n"))
                .map(line -> line.matches("# (HELP|TYPE).*") ? "\n" + line : line)
                .collect(Collectors.joining("\n"));
    }

    private String filterByInstance(String metrics, String instance, boolean regex) {
        if (instance == null || instance.isBlank()) {
            return metrics;
        }

        StringBuilder filtered = new StringBuilder();
        String[] lines = metrics.split("\n");

        Pattern pattern = null;
        if (regex) {
            try {
                pattern = Pattern.compile(instance);
            } catch (PatternSyntaxException e) {
                return "Invalid regex pattern: " + instance;
            }
        }

        for (String line : lines) {
            if (line.isBlank() || line.startsWith("# HELP") || line.startsWith("# TYPE")) {
                filtered.append(line).append("\n");
            } else {
                boolean match = regex
                        ? pattern.matcher(line).find()
                        : line.contains("instance=\"" + instance + "\"");

                if (match) {
                    filtered.append(line).append("\n");
                }
            }
        }

        return filtered.toString();
    }
}
