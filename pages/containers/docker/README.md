# Docker

Docker is an open-source platform that automates the deployment, scaling, and management of applications using containerization technology.

## Core Concepts

### Docker Engine
The runtime that enables building and running Docker containers, consisting of:
- The Docker daemon (`dockerd`)
- REST API for interacting with the daemon
- Command-line interface (CLI) client (`docker`)

### Docker Images
Read-only templates used to create containers. Images are built using instructions in a Dockerfile.

### Docker Containers
Runnable instances of Docker images with added writable layer.

### Docker Registry
A service for storing and distributing Docker images. Docker Hub is the default public registry.

## Key Components

### Dockerfile
A text file containing instructions to build a Docker image. Example:

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx
COPY ./app /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose
A tool for defining and running multi-container Docker applications with a YAML file.

### Docker Volumes
Persistent data storage mechanism for containers.

## Common Commands

```bash
# Build an image
docker build -t my-image:tag .

# Run a container
docker run -d -p 8080:80 --name my-container my-image:tag

# List running containers
docker ps

# Stop a container
docker stop my-container

# Remove a container
docker rm my-container

# List images
docker images

# Remove an image
docker rmi my-image:tag

# View container logs
docker logs my-container

# Execute commands in a running container
docker exec -it my-container bash
```

## Recent Updates (as of May 2025)

- **Docker Desktop 5.x**: Enhanced resource utilization and faster startup times
- **Docker Engine 26.x**: Improved security features and better ARM support
- **Docker Compose v3**: Enhanced networking capabilities and resource controls
- **Docker BuildKit**: Default build engine with advanced caching and parallel processing
- **Docker Scout**: Enhanced security scanning integrated into the build process
- **OCI Distribution Spec v2**: Expanded distribution capabilities

## Best Practices

- Use specific image tags rather than `latest`
- Employ multi-stage builds to reduce image size
- Minimize the number of layers
- Use .dockerignore files
- Follow the principle of least privilege
- Scan images for vulnerabilities

## Related Tools

- [Docker Compose](./docker-compose.md): Defining and running multi-container applications
- [Dockerfile](./dockerfile.md): Docker image specifications
- [Docker with Terraform](./terraform.md): Infrastructure as code with Docker
- [Docker with Bicep](./bicep.md): Azure infrastructure for Docker deployments

## Related Resources
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Best Practices](../../best-practises/containers/docker/README.md)

