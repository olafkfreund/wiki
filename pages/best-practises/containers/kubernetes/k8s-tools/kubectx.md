# Kubectx

Kubectx is a command-line utility tool that simplifies the management of Kubernetes contexts and clusters. It allows users to switch between Kubernetes contexts easily and quickly, eliminating the need to remember and type long context and cluster names.

Example Usage:

1. To list all available contexts: `kubectx`
2. To switch to a particular context: `kubectx <context>`
3. To add a new context: `kubectx <context> --cluster=<cluster-name> --user=<user-name>`
4. To delete a context: `kubectx <context> --delete`

Overall, kubectx provides a convenient way for users to manage and work with different Kubernetes contexts and clusters. It can be especially useful for users who work with multiple Kubernetes clusters or environments.
