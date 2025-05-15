---
description: 'Documentation:'
---

# Dockerfile

Here: [https://docs.docker.com/develop/develop-images/dockerfile\_best-practices/](https://docs.docker.com/develop/develop-images/dockerfile\_best-practices/)

```docker
# syntax=docker/dockerfile:1
FROM golang:1.16-alpine AS build

# Install tools required for project
# Run `docker build --no-cache .` to update dependencies
RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

# List project dependencies with Gopkg.toml and Gopkg.lock
# These layers are only re-built when Gopkg files are updated
COPY Gopkg.lock Gopkg.toml /go/src/project/
WORKDIR /go/src/project/
# Install library dependencies
RUN dep ensure -vendor-only

# Copy the entire project and build it
# This layer is rebuilt when a file changes in the project directory
COPY . /go/src/project/
RUN go build -o /bin/project

# This results in a single layer image
FROM scratch
COPY --from=build /bin/project /bin/project
ENTRYPOINT ["/bin/project"]
CMD ["--help"]
```

# Best Practices for Writing Dockerfiles

- **Use official, minimal base images** (e.g., `alpine`, `scratch`) to reduce attack surface and image size.
- **Pin versions** for base images and dependencies to ensure reproducibility.
- **Leverage multi-stage builds** to keep final images lean and free of build tools.
- **Order instructions for cache efficiency**: copy dependency files and install dependencies before copying the rest of the source code.
- **Use .dockerignore** to exclude unnecessary files (e.g., `.git`, `node_modules`, `tests`).
- **Avoid running as root**: create and use a non-root user for your application.
- **Set explicit ENTRYPOINT and CMD** for clarity and flexibility.
- **Add HEALTHCHECK** to monitor container health.
- **Scan images for vulnerabilities** (e.g., with Trivy, Snyk, or `docker scan`).
- **Do not store secrets in Dockerfiles**; use environment variables or secret managers.

## Example: Secure, Efficient Go Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /bin/project

FROM scratch
COPY --from=build /bin/project /bin/project
USER 1000:1000
ENTRYPOINT ["/bin/project"]
CMD ["--help"]
```

## Real-Life Usage Tips
- Use semantic version tags for images (e.g., `myapp:1.2.3`), not `latest` in production.
- Store Dockerfiles in version control and automate builds with CI/CD (GitHub Actions, Azure Pipelines, GitLab CI).
- Clean up unused images and containers regularly (`docker system prune`).

## Common Pitfalls
- Large images due to unnecessary files or lack of multi-stage builds
- Running as root (security risk)
- Not pinning versions (leads to unpredictable builds)
- Hardcoding secrets in Dockerfiles
- Not using `.dockerignore`, causing slow builds

## References
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
