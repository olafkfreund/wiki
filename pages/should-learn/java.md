# Java for DevOps & SRE (2025)

Java remains a core language for enterprise DevOps and SRE teams, powering cloud-native microservices, automation tools, and CI/CD pipelines across AWS, Azure, and GCP. Its mature ecosystem, JVM portability, and robust frameworks make it ideal for building scalable, observable, and secure applications.

## Why DevOps & SREs Should Learn Java

- **Cloud-Native**: Java frameworks (Spring Boot, Quarkus, Micronaut) are optimized for Kubernetes, Docker, and serverless deployments.
- **Observability**: Strong support for metrics (Micrometer, Prometheus), distributed tracing (OpenTelemetry, Jaeger), and logging (SLF4J, Logback).
- **CI/CD Integration**: Java projects integrate seamlessly with GitHub Actions, Azure Pipelines, and GitLab CI/CD.
- **Cross-Platform**: JVM runs on Linux, NixOS, WSL, and all major clouds.
- **LLM Integration**: Java can call LLM APIs (OpenAI, Azure OpenAI) for automation, code review, and incident summarization.

## Real-Life DevOps & SRE Examples

### 1. Spring Boot REST API with Health Checks

```java
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
public class HealthController {
    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
```

### 2. Dockerfile for Cloud-Native Java App

```dockerfile
FROM eclipse-temurin:17-jre-alpine
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

### 3. Prometheus Metrics with Micrometer

```java
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
public class MetricsController {
    private final MeterRegistry registry;
    public MetricsController(MeterRegistry registry) {
        this.registry = registry;
    }
    @GetMapping("/custom-metric")
    public String customMetric() {
        registry.counter("custom_requests_total").increment();
        return "Metric incremented!";
    }
}
```

### 4. CI/CD Pipeline (GitHub Actions)

```yaml
name: Java CI/CD
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      - name: Build with Maven
        run: mvn clean install
      - name: Run Tests
        run: mvn test
      - name: Build Docker Image
        run: docker build -t myorg/myapp:${{ github.sha }} .
```

### 5. LLM Integration for Incident Summaries

```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class LLMIntegration {
    public static void main(String[] args) throws Exception {
        String logContents = "Example incident log contents";
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.openai.com/v1/chat/completions"))
            .header("Authorization", "Bearer sk-...")
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString("{" +
                "\"model\":\"gpt-4\"," +
                "\"messages\":[{" +
                    "\"role\":\"system\",\"content\":\"Summarize this incident log for SREs.\"},{" +
                    "\"role\":\"user\",\"content\":\"" + logContents + "\"}]}"))
            .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.body());
    }
}
```

## Best Practices (2025)

- Use Spring Boot or Quarkus for cloud-native microservices
- Containerize apps with multi-stage Dockerfiles
- Expose health and metrics endpoints for observability
- Integrate with CI/CD for automated testing and deployment
- Store secrets in environment variables or secret managers
- Use OpenTelemetry for distributed tracing
- Write unit and integration tests (JUnit, Testcontainers)

## Common Pitfalls

- Hardcoding credentials in code or configs
- Not exposing health/metrics endpoints
- Ignoring JVM resource limits in containers
- Overlooking dependency updates (use Dependabot or Renovate)
- Not monitoring application logs and metrics

## References

- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Micrometer Metrics](https://micrometer.io/)
- [OpenTelemetry Java](https://opentelemetry.io/docs/instrumentation/java/)
- [GitHub Actions for Java](https://github.com/actions/setup-java)
- [OpenAI Java SDK](https://github.com/TheoKanning/openai-java)

---

> **Java Joke:**
> Why did the SRE refuse to use Java for their scripts? Too many exceptions in production!
