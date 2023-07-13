# Pod security

In Kubernetes, securityContext is a field that allows users to define security-related settings for a pod or container. These settings include things like user and group IDs, SELinux options, and Linux capabilities.

The importance of securityContext lies in its ability to help secure applications running in Kubernetes by enforcing best security practices. For example, setting a non-root user and group ID for a container can help prevent privilege escalation attacks.

Real-life examples of securityContext include:

1. Setting a read-only file system for a container to prevent unauthorized modifications.
2. Defining a specific SELinux context for a container to restrict its access to certain files and directories.
3. Disabling privileged mode for a container to prevent it from accessing host resources.

Overall, securityContext is an essential part of securing Kubernetes applications and should be carefully considered when designing pod manifests.

1. Setting a non-root user ID for a container:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    securityContext:
      runAsUser: 1000
```

In this example, the container is set to run as user ID 1000 instead of the default root user. This can help prevent privilege escalation attacks.

2. Setting a read-only file system for a container:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    securityContext:
      readOnlyRootFilesystem: true
```

In this example, the container is set to have a read-only file system, which can help prevent unauthorized modifications.

3. Restricting a container's access to the host network:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    securityContext:
      hostNetwork: false
```

In this example, the container is set to not use the host network, which can help prevent network attacks.

These are just a few examples of how to use securityContext in a Kubernetes pod manifest. The key is to carefully consider the security implications of each setting and tailor them to the specific needs of your application.
