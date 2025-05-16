# Modern Build Patterns (2024+)

## Supply Chain Security

### SLSA Implementation
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: slsa-build
spec:
  workspaces:
    - name: source
  params:
    - name: image-reference
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: source
      
    - name: verify-provenance
      runAfter: ["fetch-source"]
      taskRef:
        name: sigstore-verify
      params:
        - name: artifact-path
          value: $(workspaces.source.path)

    - name: build-container
      runAfter: ["verify-provenance"]
      taskRef:
        name: kaniko
      params:
        - name: IMAGE
          value: $(params.image-reference)
        - name: DOCKERFILE
          value: ./Dockerfile
```

## Build Optimization

### BuildKit Configuration
```dockerfile
# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM golang:1.22-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
COPY . .
ARG TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOARCH=$TARGETARCH go build -o /bin/app

FROM cgr.dev/chainguard/static
COPY --from=builder /bin/app /bin/
ENTRYPOINT ["/bin/app"]
```

## Multi-Stage Builds

### Distroless Base
```dockerfile
# Build stage
FROM golang:1.22 as builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o server

# Security scan
FROM aquasec/trivy:latest as security
COPY --from=builder /app/server /app/server
RUN trivy fs --severity HIGH,CRITICAL --exit-code 1 /app

# Final stage
FROM gcr.io/distroless/static-debian11
COPY --from=builder /app/server /
USER nonroot:nonroot
ENTRYPOINT ["/server"]
```

## Best Practices

1. **Build Security**
   - Vulnerability scanning
   - SBOM generation
   - Binary signing
   - Chain validation

2. **Performance**
   - Layer optimization
   - Cache utilization
   - Multi-stage builds
   - Parallel execution

3. **Standardization**
   - Base images
   - Build tooling
   - Quality gates
   - Version control

4. **Automation**
   - Pipeline integration
   - Testing automation
   - Release workflow
   - Image promotion