# Containers

Container technologies have revolutionized software development, deployment, and operations by providing consistent, isolated environments across different platforms. This section covers various container technologies and related tools.

## What Are Containers?

Containers are lightweight, standalone executable packages that include everything needed to run an application:
- Code
- Runtime
- System tools
- System libraries
- Settings

Containers isolate software from its surroundings and help ensure consistent operation regardless of differences in development and staging environments.

## Container Technologies

### [Docker](./docker/README.md)
The most widely adopted container platform that standardized the container ecosystem.

### [Kubernetes](./kubernetes/README.md)
An open-source container orchestration platform for automating deployment, scaling, and management of containerized applications.

### [Podman](./podman/README.md)
A daemonless container engine for developing, managing, and running OCI containers. Podman can run containers as root or in rootless mode.

### [NixOS Containers](./nixos-containers/README.md)
Lightweight containers that leverage the Nix package manager to provide declarative, reproducible system configurations.

### [OpenShift](./openshift.md)
Red Hat's Kubernetes distribution with added features for enterprise use.

## Container Orchestration

Container orchestration tools help manage containerized applications at scale:

- **Kubernetes**: The de facto standard for container orchestration
- **Docker Swarm**: Docker's native clustering and scheduling tool
- **Nomad**: HashiCorp's flexible workload orchestrator for containers and non-containerized applications
- **OpenShift**: Kubernetes with enterprise features and developer-friendly tools

## Container Best Practices

- Use minimal base images
- Follow the principle of least privilege
- Scan images for vulnerabilities
- Use multi-stage builds to reduce image size
- Implement proper health checks
- Leverage container registries with security features
- Avoid running containers as root when possible

For more detailed best practices, see the [Container Best Practices](../best-practises/containers/README.md) section.

