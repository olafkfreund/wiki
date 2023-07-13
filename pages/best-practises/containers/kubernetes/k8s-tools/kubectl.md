# Kubectl

Kubectl is a command-line utility tool that is used to interact with Kubernetes clusters. It allows users to deploy, manage, and troubleshoot Kubernetes applications and resources. Kubectl can be used to perform a wide range of operations, including creating and scaling deployments, updating configurations, and inspecting resource states.

Advanced Example Usage:

1. To create a deployment: `kubectl create deployment <deployment-name> --image=<image-name>`
2. To view the status of a deployment: `kubectl rollout status deployment/<deployment-name>`
3. To scale a deployment: `kubectl scale deployment/<deployment-name> --replicas=<replica-count>`
4. To update the image of a deployment: `kubectl set image deployment/<deployment-name> <container-name>=<new-image>`
5. To create a service: `kubectl create service <service-type> <service-name> --tcp=<port-number>:<target-port>`
6. To view logs for a pod: `kubectl logs <pod-name>`
7. To create a secret: `kubectl create secret <secret-type> <secret-name> --from-literal=<key>=<value>`
8. To create a ConfigMap: `kubectl create configmap <configmap-name> --from-literal=<key>=<value>`

Overall, kubectl is a powerful tool for managing Kubernetes clusters and resources. Its extensive functionality and flexibility make it an essential tool for developers and operators working with Kubernetes.
