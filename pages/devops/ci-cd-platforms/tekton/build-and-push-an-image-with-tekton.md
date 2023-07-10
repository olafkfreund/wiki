# Build and push an image with Tekton

This guide shows you how to:

1. Create a Task to clone source code from a git repository.
2. Create a second Task to use the cloned code to build a Docker image and push it to a registry.

If you are already familiar with Tekton and just want to see the example, you can [skip to the full code samples](https://tekton.dev/docs/how-to-guides/kaniko-build-push/#full-code-samples).

### Prerequisites <a href="#prerequisites" id="prerequisites"></a>

1. To follow this How-to you must have a Kubernetes cluster up and running and [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) properly configured to issue commands to your cluster.
2.  Install Tekton Pipelines:

    ```bash
    kubectl apply --filename \
    https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    ```

    See the [Pipelines installation documentation](https://tekton.dev/docs/pipelines/install/) for other installation options and vendor specific instructions.
3. Install the [Tekton CLI, `tkn`](https://tekton.dev/docs/cli/), on your machine.

If this is your first time using Tekton Pipelines, we recommend that you complete the [Getting Started tutorials](https://tekton.dev/docs/getting-started/) before proceeding with this guide.

### Clone the repository <a href="#clone-the-repository" id="clone-the-repository"></a>

Create a new Pipeline, `pipeline.yaml`, that uses the _git clone_ Task to [clone the source code from a git repository](https://tekton.dev/docs/how-to-guides/clone-repository/):

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-build-push
spec:
  description: | 
    This pipeline clones a git repo, builds a Docker image with Kaniko and
    pushes it to a registry
  params:
  - name: repo-url
    type: string
  workspaces:
  - name: shared-data
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url)
```

Then create the corresponding `pipelinerun.yaml` file:

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-build-push-run-
spec:
  pipelineRef:
    name: clone-build-push
  podTemplate:
    securityContext:
      fsGroup: 65532
  workspaces:
  - name: shared-data
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
  params:
  - name: repo-url
    value: https://github.com/google/docsy-example.git
```

For this how-to we are using a public repository as an example. You can also [use _git clone_ with private repositories, using SSH authentication](https://tekton.dev/docs/how-to-guides/clone-repository/#git-authentication).

### Build the container image with Kaniko <a href="#build-the-container-image-with-kaniko" id="build-the-container-image-with-kaniko"></a>

To build the image use the [Kaniko](https://hub.tekton.dev/tekton/task/kaniko) Task from the [community hub](https://hub.tekton.dev/).

1.  Add the image reference to the `params` section in `pipeline.yaml`:

    ```yaml
    params: 
    - name: image-reference
      type: string
    ```

    This parameter is used to add the tag corresponding the container registry where you are going to push the image.
2.  Create the new `build-push` Task in the same `pipeline.yaml` file:

    ```yaml
    tasks:
    ...
      - name: build-push
        runAfter: ["fetch-source"]
        taskRef:
          name: kaniko
        workspaces:
        - name: source
          workspace: shared-data
        params:
        - name: IMAGE
          value: $(params.image-reference)
    ```

    This new Task refers to `kaniko`, which is going to be installed from the [community hub](https://hub.tekton.dev/). A Task has its own set of `workspaces` and `params` passed down from the parameters and Workspaces defined at Pipeline level. In this case, the Workspace `source` and the value of `IMAGE`. Check the [kaniko Task documentation](https://hub.tekton.dev/tekton/task/kaniko) to see all the available options.
3.  Instantiate the `build-push` Task. Add the value of `image-reference` to the `params` section in `pipelinerun.yaml`:

    ```yaml
    params:
    - name: image-reference
      value: container.registry.com/sublocation/my_app:version
    ```

    Replace `container.registry.com/sublocation/my_app:version` with the actual tag for your registry. You can [set up a local registry](https://gist.github.com/trisberg/37c97b6cc53def9a3e38be6143786589) for testing purposes.

Check the [full code samples](https://tekton.dev/docs/how-to-guides/kaniko-build-push/#full-code-samples) to see how all the pieces fit together.

#### Container registry authentication <a href="#container-registry-authentication" id="container-registry-authentication"></a>

In most cases, to push the image to a container registry you must provide authentication credentials first.

* [General Authentication](https://tekton.dev/docs/how-to-guides/kaniko-build-push/#tabs-1-0)
* [Google Cloud](https://tekton.dev/docs/how-to-guides/kaniko-build-push/#tabs-1-1)

1.  Set up authentication with the Docker credential helper and generate the Docker configuration file, `$HOME/.docker/config.json`, for your registry. This step is different depending on your registry.

    * [Red Hat Quay](https://access.redhat.com/documentation/en-us/red\_hat\_quay/3.4/html-single/use\_red\_hat\_quay/index#allow-robot-access-user-repo)
    * [Docker Hub](https://docs.docker.com/engine/reference/commandline/login/#credentials-store)
    * [Azure container registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli#individual-login-with-azure-ad)
    * [Amazon ECR](https://aws.amazon.com/blogs/compute/authenticating-amazon-ecr-repositories-for-docker-cli-with-credential-helper/)
    * [Jfrog Artifactory](https://www.jfrog.com/confluence/display/JFROG/Using+Docker+V1#UsingDockerV1-3.SettingUpAuthentication)

    Check your cloud provider documentation to complete this step.
2.  Create a [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/), `docker-credentials.yaml` with your credentials:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: docker-credentials
    data:
      config.json: efuJAmF1...
    ```

    The value of `config.json` is the base64-encoded `~/.docker/config.json` file. You can get this data with the following command:

    ```bash
    cat ~/.docker/config.json | base64 -w0
    ```
3.  Update `pipeline.yaml` and add a Workspace to mount the credentials directory:

    At the Pipeline level:

    ```yaml
    workspaces:
    - name: docker-credentials
    ```

    And under the `build-push` Task:

    ```yaml
    workspaces:
    - name: dockerconfig
      workspace: docker-credentials
    ```
4.  Instantiate the new `docker-credentials` Workspace in your `pipelinerun.yaml` file by adding a new entry under `workspaces`:

    ```yaml
    - name: docker-credentials
      secret:
        secretName: docker-credentials
    ```

See the complete files in the [full code samples section](https://tekton.dev/docs/how-to-guides/kaniko-build-push/#full-code-samples).

### Run your Pipeline <a href="#run-your-pipeline" id="run-your-pipeline"></a>

You are ready to install the Tasks and run the pipeline.

1.  Install the `git-clone` and `kaniko` Tasks:

    ```bash
    tkn hub install task git-clone
    tkn hub install task kaniko
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

    ```
    pipelinerun.tekton.dev/clone-build-push-run-4kgjr created
    ```
5.  Use the PipelineRun name from the output of the previous step to monitor the Pipeline execution:

    ```bash
    tkn pipelinerun logs  clone-build-push-run-4kgjr -f
    ```

    After a few seconds, the output confirms that the image was built and pushed successfully:

    ```
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

### Full code samples <a href="#full-code-samples" id="full-code-samples"></a>

The Pipeline:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-build-push
spec:
  description: |
    This pipeline clones a git repo, builds a Docker image with Kaniko and
    pushes it to a registry    
  params:
  - name: repo-url
    type: string
  - name: image-reference
    type: string
  workspaces:
  - name: shared-data
  - name: docker-credentials
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url)
  - name: build-push
    runAfter: ["fetch-source"]
    taskRef:
      name: kaniko
    workspaces:
    - name: source
      workspace: shared-data
    - name: dockerconfig
      workspace: docker-credentials
    params:
    - name: IMAGE
      value: $(params.image-reference)
```

The PipelineRun:

```yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-build-push-run-
spec:
  pipelineRef:
    name: clone-build-push
  podTemplate:
    securityContext:
      fsGroup: 65532
  workspaces:
  - name: shared-data
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
  - name: docker-credentials
    secret:
      secretName: docker-credentials
  params:
  - name: repo-url
    value: https://github.com/google/docsy-example.git
  - name: image-reference
    value: container.registry.com/sublocation/my_app:version 
```

The Docker credentials Kubernetes Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-credentials
data:
  config.json: efuJAmF1...
```

Use your credentials as the value of the `data` field. Check the [registry authentication section](https://tekton.dev/docs/how-to-guides/kaniko-build-push/#container-registry-authentication) for more information
