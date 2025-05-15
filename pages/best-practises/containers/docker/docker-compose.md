# Docker-compose

```yaml
services:
  web:
    build: .
    ports:
      - "8000:5000"
    volumes:
      - .:/code
      - logvolume01:/var/log
    depends_on:
      - redis
  redis:
    image: redis
volumes:
  logvolume01: {}
```

---

# Docker Compose Best Practices

Docker Compose is a tool for defining and running multi-container Docker applications. Use these best practices to ensure efficient, secure, and maintainable Compose files for real-world DevOps workflows.

---

## Best Practices for Docker Compose
- **Pin image versions** (avoid `latest`) for reproducibility and stability.
- **Use environment variables** for secrets and configuration (never hardcode credentials).
- **Leverage named volumes** for persistent data and easier backups.
- **Use healthchecks** to monitor service health and enable automated recovery.
- **Limit container privileges** (avoid privileged mode, use `read_only` where possible).
- **Define resource limits** (`mem_limit`, `cpus`) to prevent resource contention.
- **Use `.dockerignore`** to exclude unnecessary files from build context.
- **Document service dependencies** with `depends_on` and comments.
- **Store Compose files in version control** and automate deployments with CI/CD (GitHub Actions, Azure Pipelines, GitLab CI).

---

## Example: Production-Ready Compose File
```yaml
version: '3.8'
services:
  web:
    build: .
    image: myapp/web:1.0.0
    ports:
      - "8000:5000"
    volumes:
      - .:/code
      - logvolume01:/var/log
    depends_on:
      - redis
    environment:
      - APP_ENV=production
      - REDIS_URL=redis://redis:6379
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
  redis:
    image: redis:7.2.4
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
volumes:
  logvolume01: {}
  redisdata: {}
```

---

## Real-Life Usage Tips
- Use `.env` files to manage environment variables and secrets.
- Use `docker compose --env-file` to specify different environments (dev, staging, prod).
- Integrate Compose with CI/CD for automated testing and deployment.
- Use `docker compose logs -f` and `docker compose ps` for troubleshooting.
- Clean up unused resources with `docker system prune` and `docker volume prune`.

---

## Common Pitfalls
- Using `latest` image tags (can cause unexpected updates)
- Hardcoding secrets in Compose files
- Not defining healthchecks (harder to detect failing services)
- Not setting resource limits (can lead to resource exhaustion)
- Forgetting to persist data with named volumes

---

## References
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

---
