# Build and Push Container Images with Tekton (2025)

This comprehensive guide demonstrates modern container image building and deployment with Tekton, including:

1. **Source Code Management**: Clone repositories with security scanning
2. **Container Building**: Build multi-architecture images with Kaniko
3. **Security Integration**: Image signing and SLSA provenance generation
4. **Registry Management**: Push to multiple cloud registries with authentication
5. **Supply Chain Security**: Implement modern DevSecOps practices

If you're already familiar with Tekton and want to see the complete examples, you can [jump to the full code samples](#full-code-samples-2025).

## Prerequisites

1. **Kubernetes Cluster**: You must have a Kubernetes cluster 1.28+ running and [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) properly configured to issue commands to your cluster.

2. **Install Tekton Pipelines (v0.55.0+)**:

```bash
# Install latest Tekton Pipelines
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Verify installation
kubectl get pods --namespace tekton-pipelines
```

See the [Pipelines installation documentation](../README.md#installation-guide-2025) for other installation options and vendor specific instructions.

3. **Install Tekton CLI**: Install the [Tekton CLI, `tkn`](https://tekton.dev/docs/cli/), on your machine:

```bash
# Linux (x86_64)
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn

# macOS
brew install tektoncd-cli

# Verify installation
tkn version
```

If this is your first time using Tekton Pipelines, we recommend that you complete the [Getting Started tutorials](https://tekton.dev/docs/getting-started/) before proceeding with this guide.

## Clone the Repository

Create a new Pipeline, `pipeline.yaml`, that uses the _git clone_ Task to [clone the source code from a git repository](https://tekton.dev/docs/how-to-guides/clone-repository/):

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-build-push-secure
  annotations:
    tekton.dev/description: "Secure pipeline for cloning, building, and pushing container images"
spec:
  description: | 
    This pipeline clones a git repo, performs security scanning, builds a Docker image with Kaniko,
    signs the image, generates SLSA provenance, and pushes it to a registry with security attestations
  params:
  - name: repo-url
    type: string
    description: Git repository URL
  - name: git-revision
    type: string
    description: Git revision to checkout
    default: main
  - name: image-reference
    type: string
    description: Container image reference
  - name: dockerfile-path
    type: string
    description: Path to Dockerfile
    default: "./Dockerfile"
  workspaces:
  - name: shared-data
    description: Workspace for sharing data between tasks
  - name: docker-credentials
    description: Docker registry credentials
  - name: signing-secrets
    description: Image signing secrets
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
      kind: ClusterTask
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url)
    - name: revision
      value: $(params.git-revision)
    - name: depth
      value: "1"
    - name: sslVerify
      value: "true"
  - name: security-scan
    runAfter: ["fetch-source"]
    taskRef:
      name: trivy-scanner
      kind: ClusterTask
    workspaces:
    - name: manifest-dir
      workspace: shared-data
    params:
    - name: ARGS
      value: ["fs", "--security-checks", "vuln,secret,config", "--severity", "HIGH,CRITICAL"]
    - name: IMAGE
      value: "aquasec/trivy:latest"
  - name: build-push
    runAfter: ["security-scan"]
    taskRef:
      name: kaniko
      kind: ClusterTask
    workspaces:
    - name: source
      workspace: shared-data
    - name: dockerconfig
      workspace: docker-credentials
    params:
    - name: IMAGE
      value: $(params.image-reference)
    - name: DOCKERFILE
      value: $(params.dockerfile-path)
    - name: CONTEXT
      value: "."
    - name: EXTRA_ARGS
      value: 
      - "--build-arg=BUILDKIT_INLINE_CACHE=1"
      - "--cache=true"
      - "--cache-ttl=24h"
      - "--skip-tls-verify"
      - "--reproducible"
      - "--single-snapshot"
    - name: BUILDER_IMAGE
      value: "gcr.io/kaniko-project/executor:v1.19.2"
  - name: sign-image
    runAfter: ["build-push"]
    taskRef:
      name: cosign-sign
    workspaces:
    - name: source
      workspace: shared-data
    - name: cosign-keys
      workspace: signing-secrets
    params:
    - name: image
      value: $(params.image-reference)
    - name: cosign-experimental
      value: "true"
  - name: generate-provenance
    runAfter: ["sign-image"]
    taskRef:
      name: slsa-provenance
    workspaces:
    - name: source
      workspace: shared-data
    params:
    - name: image
      value: $(params.image-reference)
    - name: git-url
      value: $(params.repo-url)
    - name: git-revision
      value: $(params.git-revision)
```

Then create the corresponding `pipelinerun.yaml` file:

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-build-push-secure-run-
  labels:
    tekton.dev/pipeline: clone-build-push-secure
spec:
  pipelineRef:
    name: clone-build-push-secure
  podTemplate:
    securityContext:
      fsGroup: 65532
      runAsNonRoot: true
      runAsUser: 65532
  workspaces:
  - name: shared-data
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 2Gi
        storageClassName: fast-ssd
  - name: docker-credentials
    secret:
      secretName: docker-credentials
  - name: signing-secrets
    secret:
      secretName: cosign-keys
  params:
  - name: repo-url
    value: https://github.com/your-org/your-app.git
  - name: git-revision
    value: main
  - name: image-reference
    value: your-registry.com/your-org/your-app:latest
  - name: dockerfile-path
    value: "./Dockerfile"
```

For this how-to we are using a public repository as an example. You can also [use _git clone_ with private repositories, using SSH authentication](https://tekton.dev/docs/how-to-guides/clone-repository/#git-authentication).

### Security Scanning and Vulnerability Assessment

Add security scanning to your pipeline before building the image:

```yaml
tasks:
# ...existing tasks...
- name: security-scan
  runAfter: ["fetch-source"]
  taskRef:
    name: trivy-scanner
    kind: ClusterTask
  workspaces:
  - name: manifest-dir
    workspace: shared-data
  params:
  - name: ARGS
    value: ["fs", "--security-checks", "vuln,secret,config", "--severity", "HIGH,CRITICAL"]
  - name: IMAGE
    value: "aquasec/trivy:latest"
```

Install the Trivy scanner task:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/trivy-scanner/0.1/trivy-scanner.yaml
```

### Build the container image with Kaniko <a href="#build-the-container-image-with-kaniko" id="build-the-container-image-with-kaniko"></a>

To build the image use the enhanced [Kaniko](https://hub.tekton.dev/tekton/task/kaniko) Task with multi-architecture support:

```yaml
tasks:
# ...existing tasks...
- name: build-push
  runAfter: ["security-scan"]
  taskRef:
    name: kaniko
    kind: ClusterTask
  workspaces:
  - name: source
    workspace: shared-data
  - name: dockerconfig
    workspace: docker-credentials
  params:
  - name: IMAGE
    value: $(params.image-reference)
  - name: DOCKERFILE
    value: $(params.dockerfile-path)
  - name: CONTEXT
    value: "."
  - name: EXTRA_ARGS
    value: 
    - "--build-arg=BUILDKIT_INLINE_CACHE=1"
    - "--cache=true"
    - "--cache-ttl=24h"
    - "--skip-tls-verify"
    - "--reproducible"
    - "--single-snapshot"
  - name: BUILDER_IMAGE
    value: "gcr.io/kaniko-project/executor:v1.19.2"
```

### Image Signing with Cosign

Add image signing to ensure supply chain security:

```yaml
tasks:
# ...existing tasks...
- name: sign-image
  runAfter: ["build-push"]
  taskRef:
    name: cosign-sign
  workspaces:
  - name: source
    workspace: shared-data
  - name: cosign-keys
    workspace: signing-secrets
  params:
  - name: image
    value: $(params.image-reference)
  - name: cosign-experimental
    value: "true"
```

Create the Cosign signing task:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: cosign-sign
spec:
  params:
  - name: image
    type: string
    description: Image to sign
  - name: cosign-experimental
    type: string
    default: "false"
  workspaces:
  - name: source
  - name: cosign-keys
  steps:
  - name: sign
    image: gcr.io/projectsigstore/cosign:v2.2.2
    env:
    - name: COSIGN_EXPERIMENTAL
      value: $(params.cosign-experimental)
    script: |
      #!/bin/sh
      set -e
      
      # Sign the image
      cosign sign --key $(workspaces.cosign-keys.path)/cosign.key $(params.image)
      
      echo "Image $(params.image) signed successfully"
```

### SLSA Provenance Generation

Generate SLSA provenance for supply chain attestation:

```yaml
tasks:
# ...existing tasks...
- name: generate-provenance
  runAfter: ["sign-image"]
  taskRef:
    name: slsa-provenance
  workspaces:
  - name: source
    workspace: shared-data
  params:
  - name: image
    value: $(params.image-reference)
  - name: git-url
    value: $(params.repo-url)
  - name: git-revision
    value: $(params.git-revision)
```

Create the SLSA provenance task:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: slsa-provenance
spec:
  params:
  - name: image
    type: string
  - name: git-url
    type: string
  - name: git-revision
    type: string
  workspaces:
  - name: source
  steps:
  - name: generate-provenance
    image: gcr.io/projectsigstore/cosign:v2.2.2
    script: |
      #!/bin/sh
      set -e
      
      # Generate SLSA provenance
      cat > /tmp/provenance.json << EOF
      {
        "builder": {
          "id": "https://tekton.dev/tekton-pipelines"
        },
        "buildType": "tekton.dev/v1beta1.PipelineRun",
        "invocation": {
          "configSource": {
            "uri": "$(params.git-url)",
            "digest": {
              "sha1": "$(params.git-revision)"
            }
          }
        },
        "metadata": {
          "buildInvocationId": "$(context.pipelineRun.name)",
          "buildStartedOn": "$(context.pipelineRun.start-time)",
          "reproducible": true
        },
        "materials": [
          {
            "uri": "$(params.git-url)",
            "digest": {
              "sha1": "$(params.git-revision)"
            }
          }
        ]
      }
      EOF
      
      # Attach provenance to image
      cosign attest --predicate /tmp/provenance.json $(params.image)
      
      echo "SLSA provenance generated and attached to $(params.image)"
```

### Run your Pipeline <a href="#run-your-pipeline" id="run-your-pipeline"></a>

You are ready to install the Tasks and run the pipeline.

1.  Install the `git-clone`, `trivy-scanner`, `kaniko`, `cosign-sign`, and `slsa-provenance` Tasks:

    ```bash
    tkn hub install task git-clone
    kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/trivy-scanner/0.1/trivy-scanner.yaml
    tkn hub install task kaniko
    kubectl apply -f cosign-sign.yaml
    kubectl apply -f slsa-provenance.yaml
    ```
2.  Apply the Secret with your Docker credentials.

    ```bash
    kubectl apply -f docker-credentials.yaml
    ```
3.  Apply the Pipeline:

    ```bash
    kubectl apply -f pipeline.yaml
    ```
4.  Create the PipelineRun:

    ```bash
    kubectl create -f pipelinerun.yaml
    ```

    This creates a PipelineRun with a unique name each time:

    ```plaintext
    pipelinerun.tekton.dev/clone-build-push-run-4kgjr created
    ```
5.  Use the PipelineRun name from the output of the previous step to monitor the Pipeline execution:

    ```bash
    tkn pipelinerun logs  clone-build-push-run-4kgjr -f
    ```

    After a few seconds, the output confirms that the image was built and pushed successfully:

    ```plaintext
    [fetch-source : clone] + '[' false '=' true ]
    [fetch-source : clone] + '[' false '=' true ]
    [fetch-source : clone] + '[' false '=' true ]
    [fetch-source : clone] + CHECKOUT_DIR=/workspace/output/
    [fetch-source : clone] + '[' true '=' true ]
    [fetch-source : clone] + cleandir
    [fetch-source : clone] + '[' -d /workspace/output/ ]
    [fetch-source : clone] + rm -rf '/workspace/output//*'
    [fetch-source : clone] + rm -rf '/workspace/output//.[!.]*'
    [fetch-source : clone] + rm -rf '/workspace/output//..?*'
    [fetch-source : clone] + test -z 
    [fetch-source : clone] + test -z 
    [fetch-source : clone] + test -z 
    [fetch-source : clone] + /ko-app/git-init '-url=https://github.com/google/docsy-example.git' '-revision=' '-refspec=' '-path=/workspace/output/' '-sslVerify=true' '-submodules=true' '-depth=1' '-sparseCheckoutDirectories='
    [fetch-source : clone] {"level":"info","ts":1654637310.4419358,"caller":"git/git.go:170","msg":"Successfully cloned https://github.com/google/docsy-example.git @ 1c7f7e300c90cd690ca5be66b43fe58713bb21c9 (grafted, HEAD) in path /workspace/output/"}
    [fetch-source : clone] {"level":"info","ts":1654637320.384655,"caller":"git/git.go:208","msg":"Successfully initialized and updated submodules in path /workspace/output/"}
    [fetch-source : clone] + cd /workspace/output/
    [fetch-source : clone] + git rev-parse HEAD
    [fetch-source : clone] + RESULT_SHA=1c7f7e300c90cd690ca5be66b43fe58713bb21c9
    [fetch-source : clone] + EXIT_CODE=0
    [fetch-source : clone] + '[' 0 '!=' 0 ]
    [fetch-source : clone] + printf '%s' 1c7f7e300c90cd690ca5be66b43fe58713bb21c9
    [fetch-source : clone] + printf '%s' https://github.com/google/docsy-example.git

    [build-push : build-and-push] WARN
    [build-push : build-and-push] User provided docker configuration exists at /kaniko/.docker/config.json 
    [build-push : build-and-push] INFO Retrieving image manifest klakegg/hugo:ext-alpine 
    [build-push : build-and-push] INFO Retrieving image klakegg/hugo:ext-alpine from registry index.docker.io 
    [build-push : build-and-push] INFO Built cross stage deps: map[]                
    [build-push : build-and-push] INFO Retrieving image manifest klakegg/hugo:ext-alpine 
    [build-push : build-and-push] INFO Returning cached image manifest              
    [build-push : build-and-push] INFO Executing 0 build triggers                   
    [build-push : build-and-push] INFO Unpacking rootfs as cmd RUN apk add git requires it. 
    [build-push : build-and-push] INFO RUN apk add git                              
    [build-push : build-and-push] INFO Taking snapshot of full filesystem...        
    [build-push : build-and-push] INFO cmd: /bin/sh                                 
    [build-push : build-and-push] INFO args: [-c apk add git]                       
    [build-push : build-and-push] INFO Running: [/bin/sh -c apk add git]            
    [build-push : build-and-push] fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
    [build-push : build-and-push] fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
    [build-push : build-and-push] OK: 76 MiB in 41 packages
    [build-push : build-and-push] INFO[0012] Taking snapshot of full filesystem...        
    [build-push : build-and-push] INFO[0013] Pushing image to us-east1-docker.pkg.dev/tekton-tests/tektonstuff/docsy:v1 
    [build-push : build-and-push] INFO[0029] Pushed image to 1 destinations               

    [build-push : write-url] us-east1-docker.pkg.dev/my-tekton-tests/tekton-samples/docsy:v1
    ```

## Full Code Samples (2025)

### Complete Secure Pipeline

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-build-push-secure
  annotations:
    tekton.dev/description: "Secure CI/CD pipeline with supply chain security"
spec:
  description: |
    This pipeline clones a git repo, performs security scanning, builds a Docker image with Kaniko,
    signs the image, generates SLSA provenance, and pushes it to a registry with security attestations
  params:
  - name: repo-url
    type: string
    description: Git repository URL
  - name: git-revision
    type: string
    description: Git revision to checkout
    default: main
  - name: image-reference
    type: string
    description: Container image reference
  - name: dockerfile-path
    type: string
    description: Path to Dockerfile
    default: "./Dockerfile"
  workspaces:
  - name: shared-data
    description: Workspace for sharing data between tasks
  - name: docker-credentials
    description: Docker registry credentials
  - name: signing-secrets
    description: Image signing secrets
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
      kind: ClusterTask
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url)
    - name: revision
      value: $(params.git-revision)
    - name: depth
      value: "1"
    - name: sslVerify
      value: "true"
  - name: security-scan
    runAfter: ["fetch-source"]
    taskRef:
      name: trivy-scanner
      kind: ClusterTask
    workspaces:
    - name: manifest-dir
      workspace: shared-data
    params:
    - name: ARGS
      value: ["fs", "--security-checks", "vuln,secret,config", "--severity", "HIGH,CRITICAL"]
    - name: IMAGE
      value: "aquasec/trivy:latest"
  - name: build-push
    runAfter: ["security-scan"]
    taskRef:
      name: kaniko
      kind: ClusterTask
    workspaces:
    - name: source
      workspace: shared-data
    - name: dockerconfig
      workspace: docker-credentials
    params:
    - name: IMAGE
      value: $(params.image-reference)
    - name: DOCKERFILE
      value: $(params.dockerfile-path)
    - name: CONTEXT
      value: "."
    - name: EXTRA_ARGS
      value: 
      - "--build-arg=BUILDKIT_INLINE_CACHE=1"
      - "--cache=true"
      - "--cache-ttl=24h"
      - "--reproducible"
      - "--single-snapshot"
    - name: BUILDER_IMAGE
      value: "gcr.io/kaniko-project/executor:v1.19.2"
  - name: sign-image
    runAfter: ["build-push"]
    taskRef:
      name: cosign-sign
    workspaces:
    - name: source
      workspace: shared-data
    - name: cosign-keys
      workspace: signing-secrets
    params:
    - name: image
      value: $(params.image-reference)
    - name: cosign-experimental
      value: "true"
  - name: generate-provenance
    runAfter: ["sign-image"]
    taskRef:
      name: slsa-provenance
    workspaces:
    - name: source
      workspace: shared-data
    params:
    - name: image
      value: $(params.image-reference)
    - name: git-url
      value: $(params.repo-url)
    - name: git-revision
      value: $(params.git-revision)
```

### Production PipelineRun

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-build-push-secure-run-
  labels:
    tekton.dev/pipeline: clone-build-push-secure
    app.kubernetes.io/version: "2025.1"
spec:
  pipelineRef:
    name: clone-build-push-secure
  podTemplate:
    securityContext:
      fsGroup: 65532
      runAsNonRoot: true
      runAsUser: 65532
      seccompProfile:
        type: RuntimeDefault
  workspaces:
  - name: shared-data
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 5Gi
        storageClassName: fast-ssd
  - name: docker-credentials
    secret:
      secretName: docker-credentials
  - name: signing-secrets
    secret:
      secretName: cosign-keys
  params:
  - name: repo-url
    value: https://github.com/your-org/your-app.git
  - name: git-revision
    value: main
  - name: image-reference
    value: your-registry.com/your-org/your-app:$(context.pipelineRun.uid)
  - name: dockerfile-path
    value: "./Dockerfile"
```

### Docker Credentials Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-credentials
  annotations:
    tekton.dev/docker-0: https://your-registry.com
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ewogICJhdXRocyI6IHsKICAgICJodHRwczovL3lvdXItcmVnaXN0cnkuY29tIjogewogICAgICAidXNlcm5hbWUiOiAieW91ci11c2VybmFtZSIsCiAgICAgICJwYXNzd29yZCI6ICJ5b3VyLXBhc3N3b3JkIiwKICAgICAgImVtYWlsIjogInlvdXItZW1haWxAZXhhbXBsZS5jb20iLAogICAgICAiYXV0aCI6ICJiV0Y2ZFdKMWJubGlZWHA9IgogICAgfQogIH0KfQ==
```

### Cosign Keys Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cosign-keys
type: Opaque
data:
  cosign.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t...
  cosign.pub: LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0...
```

### Container Registry Authentication

For different registry providers, configure your Docker credentials accordingly:

#### Docker Hub

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-credentials
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ewogICJhdXRocyI6IHsKICAgICJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOiB7CiAgICAgICJ1c2VybmFtZSI6ICJ5b3VyLXVzZXJuYW1lIiwKICAgICAgInBhc3N3b3JkIjogInlvdXItcGFzc3dvcmQiLAogICAgICAiZW1haWwiOiAieW91ci1lbWFpbEBleGFtcGxlLmNvbSIsCiAgICAgICJhdXRoIjogImJXRjZkV0oxYm5saVlYcD0iCiAgICB9CiAgfQp9
```

#### AWS ECR

```bash
# Create ECR credentials
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Create secret from Docker config
kubectl create secret generic docker-credentials \
  --from-file=config.json=$HOME/.docker/config.json
```

#### Google Container Registry

```bash
# Create GCR credentials
cat key.json | docker login -u _json_key --password-stdin https://gcr.io

# Create secret
kubectl create secret generic docker-credentials \
  --from-file=config.json=$HOME/.docker/config.json
```

#### Azure Container Registry

```bash
# Create ACR credentials
az acr login --name your-registry

# Create secret
kubectl create secret generic docker-credentials \
  --from-file=config.json=$HOME/.docker/config.json
```

### Advanced Features

#### Multi-Architecture Builds

For building multi-platform images, update the Kaniko task:

```yaml
- name: build-push-multiarch
  taskRef:
    name: kaniko
    kind: ClusterTask
  params:
  - name: IMAGE
    value: $(params.image-reference)
  - name: EXTRA_ARGS
    value:
    - "--customPlatform=linux/amd64"
    - "--customPlatform=linux/arm64"
    - "--cache=true"
    - "--reproducible"
```

#### Cache Optimization

Enable advanced caching for faster builds:

```yaml
- name: EXTRA_ARGS
  value:
  - "--cache=true"
  - "--cache-repo=$(params.image-reference)-cache"
  - "--cache-ttl=168h"  # 1 week
  - "--use-new-run"
  - "--compressed-caching=false"
```

This guide provides a complete, production-ready pipeline with modern security practices, including vulnerability scanning, image signing, and SLSA provenance generation that meets 2025 DevSecOps standards.
