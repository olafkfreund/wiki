# YAML for DevOps & SRE (2025)

YAML ("Yet Another Markup Language") is the de facto standard for configuration in Kubernetes, cloud-native deployments, and DevOps automation. Mastery of YAML is essential for engineers working with AWS, Azure, GCP, Linux, NixOS, and WSL environments.

## Why YAML Matters in DevOps & SRE
- **Declarative Infrastructure**: Define desired state for Kubernetes, Terraform, Ansible, and CI/CD pipelines.
- **Cloud-Native**: All major cloud providers and tools (Helm, Kustomize, ArgoCD) use YAML for configuration.
- **Human-Readable**: Easier to read and write than JSON or XML, but indentation is critical.

## Declarative vs Imperative <a href="#43b6" id="43b6"></a>

The YAML language used by K8s has a very key feature called “**Declarative**”, which corresponds to another word: “**Imperative**”. So before we get to know YAML in detail, we must look at the two ways of working, “declarative“ vs “imperative“. Their relationship in the computer world is a bit like the “sword” and “aircraft” in the novel.

<figure><img src="https://miro.medium.com/v2/resize:fit:698/1*PscYUzkXq8zBD9XRFU3wyQ.png" alt="" height="311" width="698"><figcaption></figcaption></figure>

These two concepts are relatively abstract and not easy to understand, and they are also one of the obstacles that K8s beginners often encounter. The K8s official website deliberately uses air conditioning as an example to explain the principle of “declarative”, but I still feel that it is not too clear, so here I will use “taxi” and “self-drive” to explain “imperative” and “declarative” vividly difference.

Suppose you want to go to the airport. There are two ways of getting there, one is self-drive and the other is take a taxi. “self-drive” is the `imperative` way, since you need to input the destination into GPS, then follow each instruction. Take a taxi is the `declarative` way, the taxi driver knows where the airport is and how to get there efficiently, you just need to tell the driver your destination, then sit in the car and the taxi will take you to the airport.

In K8s worlds, the cluster is such a skilled taxi driver. The `Master/Node` architecture allows it to know the status of the entire cluster well, and many internal components and plug-ins can automatically monitor and manage applications. We just need to use the `declarative` way to tell K8s our goal of the task, and let it handle the details of the execution process by itself.

## What is YAML <a href="#220a" id="220a"></a>

YAML was created in 2001, three years after XML. YAML’s official website ( [https://yaml.org/](https://yaml.org/) ) has a complete introduction to the language specification, so I won’t list the details of the language here, but only talk about some key points related to K8s to help you master it quickly.

You need to know that YAML is a superset of JSON and supports data types such as integers, floats, booleans, strings, arrays and objects. That said, any legal JSON document is also a YAML document, and learning YAML is a lot easier if you know JSON.

Let’s look at a few simple examples of YAML.

```yaml
# YAML object (dict)
Kubernetes:
  master: 1
  worker: 3
```plaintext

Its JSON equivalent is as follows:

```json
{
  "Kubernetes": {
    "master": 1,
    "worker": 3
  }
}
```plaintext

I won’t go into detail about YAML language, you can refer to its official website to learn more, but I did draw a basic YAML mind map below:

<figure><img src="https://miro.medium.com/v2/resize:fit:669/1*PU08cPH70mnwi--pA_JY6Q.png" alt="" height="549" width="669"><figcaption></figcaption></figure>

## Practical Tips for Engineers (2025)

### 1. Use `kubectl api-resources` and `kubectl explain`
- Discover available resource types and their fields quickly.
- Example:
  ```bash
  kubectl api-resources
  kubectl explain deployment.spec.template.spec.containers
  ```

### 2. Generate Boilerplate YAML with `kubectl`
- Scaffold manifests for Pods, Deployments, Services, etc.:
  ```bash
  kubectl create deployment myapp --image=nginx --dry-run=client -o yaml > deployment.yaml
  ```
- Always review and clean up generated YAML before using in production.

### 3. Edit and Query YAML with `yq`
- Extract, update, and merge YAML fields programmatically:
  ```bash
  yq e '.spec.replicas = 3' deployment.yaml -i
  yq e '.spec.template.spec.containers[0].image' deployment.yaml
  ```

### 4. Validate YAML Before Applying
- Use `kubectl apply --dry-run=client -f file.yaml` to catch errors early.
- Integrate YAML linting in CI/CD pipelines (e.g., with `yamllint`).

### 5. Use VS Code YAML Plugins
- [YAML by Red Hat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) for schema validation and autocompletion.
- [Kubernetes Templates](https://marketplace.visualstudio.com/items?itemName=lunuan.kubernetes-templates) for quick scaffolding.

### 6. Parameterize with Helm or Kustomize
- Use Helm charts or Kustomize overlays for multi-environment deployments and DRY (Don't Repeat Yourself) YAML.

### 7. LLM Integration for YAML Generation
- Use LLMs (like OpenAI, Azure OpenAI) to generate or review YAML for complex resources.
- Example prompt: "Generate a Kubernetes Deployment YAML for a Python app with 3 replicas and resource limits."

## Best Practices (2025)
- Always use version control (Git) for YAML files
- Add comments and clear labels/annotations
- Never hardcode secrets—use Kubernetes Secrets or external vaults
- Validate and lint YAML before deployment
- Keep YAML DRY with Helm/Kustomize

## Common Pitfalls
- Indentation errors (spaces, not tabs!)
- Blindly copying YAML without understanding
- Not specifying resource requests/limits
- Hardcoding credentials
- Ignoring schema validation errors

## References
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)
- [YAML Official Site](https://yaml.org/)
- [yq Documentation](https://mikefarah.gitbook.io/yq/)
- [Helm Docs](https://helm.sh/docs/)
- [Kustomize Docs](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)

---

> **YAML Joke:**
> Why did the DevOps engineer break up with YAML? Too many unresolved issues with indentation!
