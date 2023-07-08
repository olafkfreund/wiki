# K8sgpt

#### Homebrew <a href="#homebrew" id="homebrew"></a>

Install K8sGPT on your machine with the following commands:

```bash
brew tap k8sgpt-ai/k8sgpt
brew install k8sgpt
```

### Other Installation Options <a href="#other-installation-options" id="other-installation-options"></a>

#### RPM-based installation (RedHat/CentOS/Fedora) <a href="#rpm-based-installation-redhatcentosfedora" id="rpm-based-installation-redhatcentosfedora"></a>

```bash
curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.2.1/k8sgpt_amd64.rpm
sudo rpm -ivh -i k8sgpt_amd64.rpm
```

### Running K8sGPT through a container <a href="#running-k8sgpt-through-a-container" id="running-k8sgpt-through-a-container"></a>

If you are running K8sGPT through a container, the CLI will not be able to open the website for the OpenAI token.

You can find the latest container image for K8sGPT in the packages of the GitHub organisation: [Link](https://github.com/k8sgpt-ai/k8sgpt/pkgs/container/k8sgpt)

A volume can then be mounted to the image through e.g. [Docker Compose](https://docs.docker.com/storage/volumes/). Below is an example:

```bash
version: '2'
services:
 k8sgpt:
   image: ghcr.io/k8sgpt-ai/k8sgpt:dev-202304011623
   volumes:
     -  /home/$(whoami)/.k8sgpt.yaml:/home/root/.k8sgpt.yaml
```

### Installing the K8sGPT Operator Helm Chart <a href="#installing-the-k8sgpt-operator-helm-chart" id="installing-the-k8sgpt-operator-helm-chart"></a>

K8sGPT can be installed as an Operator inside the cluster. For further information, see the [K8sGPT Operator](https://docs.k8sgpt.ai/getting-started/in-cluster-operator/) documentation.

### Using K8sGPT <a href="#using-k8sgpt" id="using-k8sgpt"></a>

You can view the different command options through

```bash
k8sgpt --help
Kubernetes debugging powered by AI

Usage:
  k8sgpt [command]

Available Commands:
  analyze     This command will find problems within your Kubernetes cluster
  auth        Authenticate with your chosen backend
  completion  Generate the autocompletion script for the specified shell
  filters     Manage filters for analyzing Kubernetes resources
  generate    Generate Key for your chosen backend (opens browser)
  help        Help about any command
  integration Integrate another tool into K8sGPT
  serve       Runs k8sgpt as a server
  version     Print the version number of k8sgpt

Flags:
      --config string        config file (default is $HOME/.k8sgpt.yaml)
  -h, --help                 help for k8sgpt
      --kubeconfig string    Path to a kubeconfig. Only required if out-of-cluster.
      --kubecontext string   Kubernetes context to use. Only required if out-of-cluster.

Use "k8sgpt [command] --help" for more information about a command.
```

### Authenticate with OpenAI <a href="#authenticate-with-openai" id="authenticate-with-openai"></a>

First, you will need to authenticate with your chosen backend. The backend is the AI provider such as OpenAI's ChatGPT.

[Ensure that you have created an account.](https://chat.openai.com/auth/login)

Next, generate a token from the backend:

```bash
k8sgpt generate
```

This will provide you with a URL to generate a token, follow the URL from the command line to your browser to then generate the token.

For a more engaging experience and a better understanding of the capabilities of `k8sgpt` and LLMs (Large Language Models), run the following command:

```bash
k8sgpt analyse --explain
```

Congratulations! you have successfully created a local kubernetes cluster, deployed a "broken Pod" and analyzed it using `k8sgpt`.
