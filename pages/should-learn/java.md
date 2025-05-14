# Java

Java is a high-level, class-based, object-oriented programming language designed to be platform-independent through its "Write Once, Run Anywhere" philosophy.

## Overview

Java runs on the Java Virtual Machine (JVM), which allows code to run on any device that has a JVM installed, regardless of the underlying architecture.

## Pros

- Platform independence
- Strong ecosystem and libraries
- Excellent documentation
- Large community support
- Enterprise-grade security
- Automatic memory management
- Rich set of development tools
- Strong typing and compile-time checking

## Cons

- Verbose syntax compared to modern languages
- Higher memory consumption
- Slower startup time compared to native applications
- Complex build systems for beginners
- Can be overly complex for simple tasks

## Setup Guide

### Linux (Ubuntu/Debian)

```bash
# Install OpenJDK
sudo apt update
sudo apt install openjdk-17-jdk
```

### WSL

```bash
# Same as Linux installation
sudo apt update
sudo apt install openjdk-17-jdk
```

### NixOS 

```nix
# Add to configuration.nix
environment.systemPackages = with pkgs; [
  jdk17
  maven
  gradle
];
```

## Development Tools

1. **Build Tools:**
   - Maven
   - Gradle
   - Ant (legacy)

2. **IDEs:**
   - IntelliJ IDEA
   - Eclipse
   - VS Code with Java extensions

## Real-Life Example

Here's a simple Spring Boot REST API example:

```java
// filepath: HelloWorldController.java
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
public class HelloWorldController {
    
    @GetMapping("/hello")
    public String hello() {
        return "Hello, DevOps World!";
    }
}
```

### Project Structure Example

```plaintext
my-java-project/
├── src/
│   ├── main/
│   │   └── java/
│   │       └── com/
│   │           └── example/
│   │               └── Application.java
│   └── test/
│       └── java/
├── pom.xml
└── README.md
```

### Maven Build File Example

```xml
// filepath: pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>demo-project</artifactId>
    <version>1.0-SNAPSHOT</version>
    
    <properties>
        <java.version>17</java.version>
        <spring-boot.version>3.1.0</spring-boot.version>
    </properties>
</project>
```

## Building and Running

### Command Line Compilation

```bash
# Compile a single file
javac HelloWorld.java

# Run the compiled class
java HelloWorld

# Build with Maven
mvn clean install

# Run Spring Boot application
mvn spring-boot:run
```

## Best Practices

1. **Code Organization:**
   - Follow package naming conventions
   - Use meaningful class and method names
   - Implement proper exception handling

2. **Performance:**
   - Use StringBuilder for string concatenation
   - Implement proper resource cleanup
   - Use collection frameworks appropriately

3. **Testing:**
   - Write unit tests using JUnit
   - Implement integration tests
   - Use mocking frameworks when needed

## Common Tools for DevOps

1. **Containerization:**
```dockerfile
FROM openjdk:17-slim
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

2. **CI/CD Pipeline Example (GitHub Actions):**
```yaml
name: Java CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          java-version: '17'
      - name: Build with Maven
        run: mvn clean install
```

## Monitoring and Observability

- Use Spring Actuator for health checks
- Implement logging with SLF4J/Logback
- Use Prometheus and Grafana for metrics
- Implement distributed tracing with Jaeger or Zipkin

Remember to update the SUMMARY.md file to include this new Java guide in your wiki structure.

