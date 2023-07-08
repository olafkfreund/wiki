# YAML

YAML, which stands for “Yet Another Markup Language,” is a text-based format used for configuration data. Kubernetes (K8s) supports creating resource objects in both YAML and JSON formats, which facilitate message exchange between interfaces and are suitable for development. However, YAML has gained more widespread use and become the de facto standard in the K8s ecosystem.

Compared to JSON, YAML offers a more user-friendly format. Additionally, YAML is a superset of JSON, meaning that a YAML parser can interpret JSON, though the reverse may not be true. In general, YAML is visually easier to read, can reference other items, does not allow duplicate keys, and provides more features. These advantages have contributed to YAML becoming the default standard language for K8s.

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
```

Its JSON equivalent is as follows:

```json
{
  "Kubernetes": {
    "master": 1,
    "worker": 3
  }
}
```

I won’t go into detail about YAML language, you can refer to its official website to learn more, but I did draw a basic YAML mind map below:

<figure><img src="https://miro.medium.com/v2/resize:fit:669/1*PU08cPH70mnwi--pA_JY6Q.png" alt="" height="549" width="669"><figcaption></figcaption></figure>

ricks Write YAML in K8s

At this point, I believe you should have a general understanding of how to use YAML to communicate with K8s, but questions will follow: With so many API objects, how do we know what apiVersion and what kind to use? What fields should be written in metadata and spec? In addition, YAML looks simple, but it is more troublesome to write, and it is easy to make mistakes in indentation alignment. Is there any simple way?

The most authoritative answer to these questions is undoubtedly the official reference documentation of K8s ( [https://kubernetes.io/docs/reference/kubernetes-api/](https://kubernetes.io/docs/reference/kubernetes-api/) ), where all fields of the API object can be found. However, the content of the official documents is too much and too detailed, and it is a bit difficult to read, so I will introduce a few simple and practical tips below.

### Trick one <a href="#06a6" id="06a6"></a>

The first trick is the `kubectl api-resources` command, which will display the corresponding API version and type of the resource object. For example, the version of Pod is “v1”, and the version of Ingress is “[networking.k8s.io](http://networking.k8s.io/)” /v1", you can never go wrong with it.

### Trick two <a href="#02b5" id="02b5"></a>

The second trick is the command `kubectl explain`, which is equivalent to the API document that comes with K8s, and will give a detailed description of the object fields, so that we don’t have to search online. For example, if you want to see how to write the fields in the Pod, you can do this:

```bash
$ kubectl explain pod
$ kubectl explain pod.metadata
$ kubectl explain pod.spec
$ kubectl explain pod.spec.containers
```

Sample output will look like:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*kv9EBYcE5b04zUpfNtpVUg.png" alt="" height="429" width="700"><figcaption></figcaption></figure>

### Trick three <a href="#063a" id="063a"></a>

Third trick is we can also let kubectl “do it” for us, generating a “document boilerplate” that saves us the work of typing and aligning the format. we can use two special parameters of kubectl : — dry-run=client and -o yaml, the former is dry run, the latter is to generate YAML format, combined use will make kubectl not have the actual creation action , but only generates a YAML file.

```bash
$ kubectl run ngx --image=nginx:alpine --dry-run=client -o yaml
```

The above command will generate an absolutely correct YAML file:

```bash
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ngx
  name: ngx
spec:
  containers:
  - image: nginx:alpine
    name: ngx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

[\
](https://medium.com/tag/kubernetes?source=post\_page-----2f102903478---------------kubernetes-----------------)\
