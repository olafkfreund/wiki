# Tekton

## What is Tekton? <a href="#c9f8" id="c9f8"></a>

In the realm of cloud-native development, Continuous Integration and Continuous Delivery (CI/CD) have become critical components for building, testing, and deploying applications seamlessly. With the rise of Kubernetes and containerization, developers need efficient tools to manage their CI/CD pipelines effectively. Enter Tekton, a powerful open-source framework designed specifically for cloud-native CI/CD workflows.

Tekton is a Kubernetes-native framework that focuses on providing a declarative and extensible approach to building CI/CD systems. Born as an open-source project under the umbrella of the Continuous Delivery Foundation (CDF), Tekton leverages the Kubernetes API and utilizes custom resource definitions (CRDs) to define pipeline resources, tasks, and workspaces. It brings the advantages of scalability, portability, and reproducibility to your CI/CD workflows, making it an excellent choice for cloud-native environments.

### Key features of Tekton <a href="#db09" id="db09"></a>

Key Features and Concepts

1. Tasks: The fundamental building blocks of a Tekton pipeline are tasks. Each task represents a specific unit of work, such as building code, running tests, or deploying an application. Tasks can be combined and reused across pipelines, promoting modularity and code sharing.
2. Pipelines: Pipelines provide a way to orchestrate tasks in a specific order to create an end-to-end CI/CD workflow. With Tekton, you can define complex pipelines that include multiple stages, parallel execution, and conditional branching.
3. Resources: Resources represent the inputs and outputs of tasks within a pipeline. They can include source code repositories, container images, or any other artifacts required for the pipeline execution. Tekton enables you to define and manage resources as Kubernetes CRDs.
4. Workspaces: Workspaces allow you to share files between tasks within a pipeline. They provide a mechanism for passing data and artifacts between different stages of the CI/CD workflow. Workspaces ensure isolation and reproducibility, making it easier to manage complex pipelines.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*uhaGRbUhmAbqByolqTrqZQ.jpeg" alt="" height="497" width="700"><figcaption></figcaption></figure>

5\. A task can consist of multiple steps, and pipeline may consist of multiple tasks. The tasks may run in parallel or in sequence



To install Tekton Pipelines on a Kubernetes cluster:

1. Run one of the following commands depending on which version of Tekton Pipelines you want to install:
   *   **Latest official release:**

       ```bash
       kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
       ```
   *   **Nightly release:**

       ```bash
       kubectl apply --filename https://storage.googleapis.com/tekton-releases-nightly/pipeline/latest/release.yaml
       ```
   *   **Specific release:**

       ```bash
        kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/<version_number>/release.yaml
       ```

       Replace `<version_number>` with the numbered version you want to install. For example, `v0.26.0`.
   *   **Untagged release:**

       If your container runtime does not support `image-reference:tag@digest`:

       ```bash
       kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.notags.yaml
       ```
2.  Monitor the installation:

    ```bash
    kubectl get pods --namespace tekton-pipelines --watch
    ```

    When all components show `1/1` under the `READY` column, the installation is complete. Hit _Ctrl + C_ to stop monitoring.

Congratulations! You have successfully installed Tekton Pipelines on your Kubernetes cluster.

## Install and set up Tekton Triggers

### Installation <a href="#installation" id="installation"></a>

1. Log on to your Kubernetes cluster with the same user account that installed Tekton Pipelines.
2.  Depending on which version of Tekton Triggers you want to install, run one of the following commands:

    *   **Latest official release**

        ```bash
        kubectl apply --filename \
        https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
        kubectl apply --filename \
        https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
        ```



*   `disable-affinity-assistant` - set this flag to `true` to disable the [Affinity Assistant](https://tekton.dev/docs/pipelines/workspaces/#specifying-workspace-order-in-a-pipeline-and-affinity-assistants) that is used to provide Node Affinity for `TaskRun` pods that share workspace volume. The Affinity Assistant is incompatible with other affinity rules configured for `TaskRun` pods.

    **Note:** Affinity Assistant use [Inter-pod affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity) that require substantial amount of processing which can slow down scheduling in large clusters significantly. We do not recommend using them in clusters larger than several hundred nodes

    **Note:** Pod anti-affinity requires nodes to be consistently labelled, in other words every node in the cluster must have an appropriate label matching `topologyKey`. If some or all nodes are missing the specified `topologyKey` label, it can lead to unintended behavior.
* `await-sidecar-readiness`: set this flag to `"false"` to allow the Tekton controller to start a TasksRun’s first step immediately without waiting for sidecar containers to be running first. Using this option should decrease the time it takes for a TaskRun to start running, and will allow TaskRun pods to be scheduled in environments that don’t support [Downward API](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/) volumes (e.g. some virtual kubelet implementations). However, this may lead to unexpected behaviour with Tasks that use sidecars, or in clusters that use injected sidecars (e.g. Istio). Setting this flag to `"false"` will mean the `running-in-environment-with-injected-sidecars` flag has no effect.
* `running-in-environment-with-injected-sidecars`: set this flag to `"false"` to allow the Tekton controller to start a TasksRun’s first step immediately if it has no Sidecars specified. Using this option should decrease the time it takes for a TaskRun to start running. However, for clusters that use injected sidecars (e.g. Istio) this can lead to unexpected behavior.
* `require-git-ssh-secret-known-hosts`: set this flag to `"true"` to require that Git SSH Secrets include a `known_hosts` field. This ensures that a git remote server’s key is validated before data is accepted from it when authenticating over SSH. Secrets that don’t include a `known_hosts` will result in the TaskRun failing validation and not running.
* `enable-tekton-oci-bundles`: set this flag to `"true"` to enable the tekton OCI bundle usage (see [the tekton bundle contract](https://tekton.dev/docs/pipelines/tekton-bundle-contracts/)). Enabling this option allows the use of `bundle` field in `taskRef` and `pipelineRef` for `Pipeline`, `PipelineRun` and `TaskRun`. By default, this option is disabled (`"false"`), which means it is disallowed to use the `bundle` field.
* `disable-creds-init` - set this flag to `"true"` to [disable Tekton’s built-in credential initialization](https://tekton.dev/docs/pipelines/auth/#disabling-tektons-built-in-auth) and use Workspaces to mount credentials from Secrets instead. The default is `false`. For more information, see the [associated issue](https://github.com/tektoncd/pipeline/issues/3399).
* `enable-api-fields`: set this flag to “stable” to allow only the most stable features to be used. Set it to “alpha” to allow [alpha features](https://tekton.dev/docs/installation/additional-configs/#alpha-features) to be used.
* `trusted-resources-verification-no-match-policy`: Setting this flag to `fail` will fail the taskrun/pipelinerun if no matching policies found. Setting to `warn` will skip verification and log a warning if no matching policies are found, but not fail the taskrun/pipelinerun. Setting to `ignore` will skip verification if no matching policies found. Defaults to “ignore”.
* `results-from`: set this flag to “termination-message” to use the container’s termination message to fetch results from. This is the default method of extracting results. Set it to “sidecar-logs” to enable use of a results sidecar logs to extract results instead of termination message.
* `enable-provenance-in-status`: Set this flag to `"true"` to enable populating the `provenance` field in `TaskRun` and `PipelineRun` status. The `provenance` field contains metadata about resources used in the TaskRun/PipelineRun such as the source from where a remote Task/Pipeline definition was fetched. By default, this is set to `true`. To disable populating this field, set this flag to `"false"`.

The flags in this ConfigMap are as follows:

**Note:** Changing feature flags may result in undefined behavior for TaskRuns and PipelineRuns that are running while the change occurs.

To customize the behavior of the Pipelines Controller, modify the ConfigMap `feature-flags` via `kubectl edit configmap feature-flags -n tekton-pipelines`.

#### Customizing the Pipelines Controller behavior <a href="#customizing-the-pipelines-controller-behavior" id="customizing-the-pipelines-controller-behavior"></a>

**Note:** The `_example` key in the provided [config-defaults.yaml](https://github.com/tektoncd/pipeline/tree/release-v0.48.x/config/config-defaults.yaml) file lists the keys you can customize along with their default values.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-defaults
data:
  default-service-account: "tekton"
  default-timeout-minutes: "20"
  default-pod-template: |
    nodeSelector:
      kops.k8s.io/instancegroup: build-instance-group    
  default-managed-by-label-value: "my-tekton-installation"
  default-task-run-workspace-binding: |
        emptyDir: {}
  default-max-matrix-combinations-count: "1024"
  default-resolver-type: "git"
```

* the default service account from `default` to `tekton`.
* the default timeout from 60 minutes to 20 minutes.
* the default `app.kubernetes.io/managed-by` label is applied to all Pods created to execute `TaskRuns`.
* the default Pod template to include a node selector to select the node where the Pod will be scheduled by default. A list of supported fields is available [here](https://github.com/tektoncd/pipeline/blob/main/docs/podtemplates.md#supported-fields). For more information, see [`PodTemplate` in `TaskRuns`](https://tekton.dev/docs/pipelines/taskruns/#specifying-a-pod-template) or [`PodTemplate` in `PipelineRuns`](https://tekton.dev/docs/pipelines/pipelineruns/#specifying-a-pod-template).
* the default `Workspace` configuration can be set for any `Workspaces` that a Task declares but that a TaskRun does not explicitly provide.
* the default maximum combinations of `Parameters` in a `Matrix` that can be used to fan out a `PipelineTask`. For more information, see [`Matrix`](https://tekton.dev/docs/pipelines/matrix/).
* the default resolver type to `git`.

The example below customizes the following:

You can specify your own values that replace the default service account (`ServiceAccount`), timeout (`Timeout`), resolver (`Resolver`), and Pod template (`PodTemplate`) values used by Tekton Pipelines in `TaskRun` and `PipelineRun` definitions. To do so, modify the ConfigMap `config-defaults` with your desired values.

### Customizing basic execution parameters <a href="#customizing-basic-execution-parameters" id="customizing-basic-execution-parameters"></a>

_In the above example the environment variable `TEST_TEKTON` will not be overriden by value specified in podTemplate, because the `config-default` option `default-forbidden-env` is configured with value `TEST_TEKTON`._

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-defaults
  namespace: tekton-pipelines
data:
  default-timeout-minutes: "50"
  default-service-account: "tekton"
  default-forbidden-env: "TEST_TEKTON"
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: mytask
  namespace: default
spec:
  steps:
    - name: echo-env
      image: ubuntu
      command: ["bash", "-c"]
      args: ["echo $TEST_TEKTON "]
      env:
          - name: "TEST_TEKTON"
            value: "true"
---
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: mytaskrun
  namespace: default
spec:
  taskRef:
    name: mytask
  podTemplate:
    env:
        - name: "TEST_TEKTON"
          value: "false"
```

For example:

The environment variables specified by a `PodTemplate` supercedes all other ways of specifying environment variables. However, there exists a configuration i.e. `default-forbidden-env`, the environment variable specified in this list cannot be updated via a `PodTemplate`.

1. Implicit environment variables
2. `Step`/`StepTemplate` environment variables
3. Environment variables specified via a `default` `PodTemplate`.
4. Environment variables specified via a `PodTemplate`.

Environment variables can be configured in the following ways, mentioned in order of precedence from lowest to highest.

### Configuring environment variables <a href="#configuring-environment-variables" id="configuring-environment-variables"></a>

The `SSL_CERT_DIR` is set to `/etc/ssl/certs` as the default cert directory. If you are using a self-signed cert for private registry and the cert file is not under the default cert directory, configure your registry cert in the `config-registry-cert` `ConfigMap` with the key `cert`.

### Configuring self-signed cert for private registry <a href="#configuring-self-signed-cert-for-private-registry" id="configuring-self-signed-cert-for-private-registry"></a>

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
  namespace: tekton-pipelines
  labels:
    app.kubernetes.io/instance: default
    app.kubernetes.io/part-of: tekton-pipelines
data:
  send-cloudevents-for-runs: true
```

Additionally, CloudEvents for `Runs` require an extra configuration to be enabled. This setting exists to avoid collisions with CloudEvents that might be sent by custom task controllers:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-defaults
  namespace: tekton-pipelines
  labels:
    app.kubernetes.io/instance: default
    app.kubernetes.io/part-of: tekton-pipelines
data:
  default-cloud-events-sink: https://my-sink-url
```

When configured so, Tekton can generate `CloudEvents` for `TaskRun`, `PipelineRun` and `Run`lifecycle events. The main configuration parameter is the URL of the sink. When not set, no notification is generated.

### Configuring CloudEvents notifications <a href="#configuring-cloudevents-notifications" id="configuring-cloudevents-notifications"></a>

1. [The `bundles` resolver](https://tekton.dev/docs/pipelines/bundle-resolver/), disabled by setting the `enable-bundles-resolver` feature flag to `false`.
2. [The `git` resolver](https://tekton.dev/docs/pipelines/git-resolver/), disabled by setting the `enable-git-resolver` feature flag to `false`.
3. [The `hub` resolver](https://tekton.dev/docs/pipelines/hub-resolver/), disabled by setting the `enable-hub-resolver` feature flag to `false`.
4. [The `cluster` resolver](https://tekton.dev/docs/pipelines/cluster-resolver/), disabled by setting the `enable-cluster-resolver` feature flag to `false`.

Four remote resolvers are currently provided as part of the Tekton Pipelines installation. By default, these remote resolvers are enabled. Each resolver can be disabled by setting the appropriate feature flag in the `resolvers-feature-flags` ConfigMap in the `tekton-pipelines-resolvers` namespace:

### Configuring built-in remote Task and Pipeline resolution <a href="#configuring-built-in-remote-task-and-pipeline-resolution" id="configuring-built-in-remote-task-and-pipeline-resolution"></a>

\
