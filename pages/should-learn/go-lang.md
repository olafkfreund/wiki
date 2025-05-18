# Go for DevOps & SRE (2025)

Go (Golang) is a modern, statically typed language designed for simplicity, performance, and scalability. It's a top choice for DevOps and SRE engineers working with AWS, Azure, GCP, Kubernetes, and cloud-native tooling.

## Why DevOps & SREs Should Learn Go

- **Cloud Native**: Go powers Kubernetes, Docker, Prometheus, and many cloud SDKs (AWS, Azure, GCP).
- **Performance**: Compiled binaries, fast startup, and low memory usage make Go ideal for microservices and CLI tools.
- **Concurrency**: Goroutines and channels enable efficient parallel processing for automation and monitoring.
- **DevOps Ecosystem**: Many DevOps tools (Terraform, Helm, Vault, etc.) are written in Go, making it easy to extend or contribute.
- **Cross-Platform**: Build for Linux, NixOS, WSL, and all major clouds with a single codebase.

## Real-Life DevOps & SRE Examples

### 1. Build & Deploy a Go App on Kubernetes

**Dockerfile:**

```dockerfile
FROM golang:1.21-alpine as builder
WORKDIR /app
COPY . .
RUN go build -o app

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/app .
CMD ["./app"]
```

**deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myrepo/myapp:v1
        ports:
        - containerPort: 8080
```

### 2. Kubernetes Operator with Go (kubebuilder)

```go
// ...existing code for imports...
func (r *MyResourceReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // Custom reconciliation logic
    // ...
    return ctrl.Result{}, nil
}
```

### 3. Custom Kubernetes Controller

```go
// ...existing code for imports...
func main() {
    // Setup manager, scheme, and controller
    // Watch for resource changes and automate tasks
    // ...
}
```

### 4. Prometheus Exporter in Go

```go
package main
import (
    "net/http"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)
func main() {
    myMetric := prometheus.NewGauge(prometheus.GaugeOpts{
        Name: "my_custom_metric",
        Help: "A custom metric for SREs",
    })
    prometheus.MustRegister(myMetric)
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":2112", nil)
}
```

### 5. CI/CD Pipeline Step (GitHub Actions)

```yaml
- name: Build Go binary
  run: go build -o app
- name: Run tests
  run: go test ./...
```

## Best Practices (2025)

- Use Go modules for dependency management
- Write unit and integration tests (use `testing` and `testify`)
- Lint and format code with `golangci-lint` and `gofmt`
- Use context for cancellation/timeouts in automation
- Pin dependencies in `go.mod`
- Document code and APIs

## Common Pitfalls

- Not handling errors (always check returned errors)
- Hardcoding credentials (use env vars or secret managers)
- Ignoring context cancellation in long-running tasks
- Not using modules (avoid GOPATH for new projects)

## References

- [Go Official Docs](https://go.dev/doc/)
- [Kubernetes Go Client](https://github.com/kubernetes/client-go)
- [Kubebuilder](https://book.kubebuilder.io/)
- [Prometheus Go Client](https://github.com/prometheus/client_golang)

---

> **Go Joke:**
> Why did the SRE love Go? Because handling errors is a feature, not a bug!
