---
description: A comprehensive guide to Kubernetes concepts, tools, and best practices for DevOps engineers.
keywords: kubernetes, k8s, containers, orchestration, pods, deployments, services, devops
tags: [kubernetes, containers, orchestration, devops]
---

# Kubernetes

{% include "/_snippets/kubernetes-prerequisites.md" %}

Kubernetes is an open-source platform for automating deployment, scaling, and operations of application containers across clusters of hosts. It groups containers that make up an application into logical units for easy management and discovery.

## Key Features

- **Automated rollouts and rollbacks**: Kubernetes progressively rolls out changes to your application or its configuration, while monitoring application health to ensure it doesn't kill all your instances at the same time.
- **Service discovery and load balancing**: No need to modify your application to use an unfamiliar service discovery mechanism.
- **Storage orchestration**: Automatically mount the storage system of your choice, whether from local storage, or cloud providers.
- **Self-healing**: Restarts containers that fail, replaces and reschedules containers when nodes die.
- **Secret and configuration management**: Deploy and update secrets and application configuration without rebuilding your image.

## What You'll Learn

This section covers:

- Kubernetes architecture and components
- How to deploy applications using Kubernetes
- Troubleshooting common issues
- Advanced Kubernetes features and patterns
