# Docker

Docker is a leading containerization platform for building, shipping, and running applications. Follow these best practices to ensure secure, efficient, and maintainable Docker images and workflows.

---

## Best Practices for Docker Development

### 1. Use Official Base Images
- Start from trusted, minimal images (e.g., `alpine`, `ubuntu`, `node:slim`).
- Example:
  ```dockerfile
  FROM python:3.11-slim
  ```

### 2. Minimize Image Size
- Remove unnecessary packages and files.
- Use multi-stage builds to keep images lean.
- Example:
  ```dockerfile
  FROM node:20 AS build
  WORKDIR /app
  COPY . .
  RUN npm ci && npm run build

  FROM nginx:alpine
  COPY --from=build /app/dist /usr/share/nginx/html
  ```

### 3. Leverage .dockerignore
- Exclude files and directories not needed in the image (e.g., `.git`, `node_modules`, `tests`).
- Example:
  ```dockerignore
  node_modules
  .git
  tests
  *.md
  ```

### 4. Use Non-Root Users
- Avoid running containers as root for security.
- Example:
  ```dockerfile
  RUN adduser --disabled-password appuser
  USER appuser
  ```

### 5. Pin Versions
- Specify exact versions for base images and dependencies to ensure reproducibility.
- Example:
  ```dockerfile
  FROM nginx:1.25.3-alpine
  ```

### 6. Layer Caching
- Order Dockerfile instructions to maximize build cache efficiency (install dependencies before copying source code).

### 7. Health Checks
- Add `HEALTHCHECK` instructions to monitor container health.
- Example:
  ```dockerfile
  HEALTHCHECK CMD curl --fail http://localhost:8080/health || exit 1
  ```

### 8. Multi-Arch Builds
- Use `docker buildx` for building images for multiple architectures (amd64, arm64).
- Example:
  ```sh
  docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
  ```

### 9. Scan Images for Vulnerabilities
- Use tools like `docker scan`, Trivy, or Snyk to check for vulnerabilities.
- Example:
  ```sh
  trivy image myapp:latest
  ```

### 10. Use Environment Variables for Configuration
- Avoid hardcoding secrets or config in images. Use environment variables and secret managers.

---

## Real-Life Example: Secure, Lean Dockerfile
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

---

## Best Practices for Docker Usage
- Use Docker Compose for local development and multi-container apps.
- Tag images with semantic versions (e.g., `myapp:1.2.3`) and avoid using `latest` in production.
- Clean up unused images and containers regularly (`docker system prune`).
- Store Dockerfiles and Compose files in version control (Git).
- Use CI/CD pipelines (GitHub Actions, Azure Pipelines, GitLab CI) to automate builds, tests, and pushes to registries.
- Push images to secure registries (Docker Hub, AWS ECR, Azure ACR, GCP Artifact Registry).

---

## Common Pitfalls
- Building large images with unnecessary files
- Running containers as root
- Not scanning images for vulnerabilities
- Hardcoding secrets in Dockerfiles
- Using unpinned or outdated base images

---

## References
- [Docker Official Docs](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

