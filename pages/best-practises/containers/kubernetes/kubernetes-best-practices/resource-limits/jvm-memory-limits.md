# JVM memory limits

_**Disclaimer**. This post describes hotfix for Java less than 17. If you are using Java 17+ skip this post and just use `-XX:UseContainerSupport` . Don’t remember to set limits for containers._

Note that Heap is not a single memory consumer in JVM. `JVM Memory = Heap + NonHeap` where `NonHeap = Metaspace + CodeHeap (non-nmethods) + Compressed Class Space + CodeHeap (non-profiled nmethods)` . While we can limit Heap size using a single parameter like `-Xmx` we can not do the same thing for nonheap.

## How set Kubernetes memory limits for container <a href="#bf52" id="bf52"></a>

We [can specify memory request and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for each container using `spec.containers[].resources.limits.memory` and `spec.containers[].resources.requests.memory` . If the container will consume more memory than it was permitted then the container will be killed.

<figure><img src="https://miro.medium.com/v2/resize:fit:418/1*Zh5H5WCvjrocUq85MmS3cg.png" alt="" height="340" width="418"><figcaption><p>Kubernetes requests &#x26; limits example</p></figcaption></figure>

The main reason why you should specify requests and limits in the same time is [QoS classes](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/): policy of resource assignment in case of lack of resources.

<figure><img src="https://miro.medium.com/v2/1*iGRP2cF86wMUWwztqQKi3A.png" alt="QoS Classes of K8s Pods. Quality of Service (QoS) class is a… | by Alen  Güler | blutv | Medium" width="700"><figcaption><p>QOS Class Explain</p></figcaption></figure>

Let’s look at QOS description from Kubernetes [Github issue](https://github.com/kubernetes/website/issues/18982):

> **Guaranteed** — pods are guaranteed to have the requested resources when they are scheduled, and the least likely to be evicted if the node running the pod is overcommitted.
>
> **Burstable** — pods are guaranteed to have the requested resources, but are not guaranteed to have the full resources specified in the resource \`limits\` when scheduled. If a node is overcommitted, Burstable pods will be evicted before Guaranteed pods are evicted.
>
> **BestEffort** — pods are not given any guarantees with respect to allocated resources when scheduled. If a node is overcommitted, BestEffort pods are the first ones considered for eviction.

If you would like to understand memory qos more deeply I recommend you to read a [KEP-2570](https://github.com/kubernetes/enhancements/tree/48599d1cc4391c5d176606490ed6f766677855d9/keps/sig-node/2570-memory-qos) “KEP-2570: Support Memory QoS with cgroups v2” and [KEP-1769](https://github.com/kubernetes/enhancements/tree/48599d1cc4391c5d176606490ed6f766677855d9/keps/sig-node/1769-memory-manager) “KEP-1769: Memory Manager”.

## JVM Memory structure <a href="#ffed" id="ffed"></a>

Let’s look at the memory profile of some Java application using [Yourkit](https://www.yourkit.com/) profiler. There are 3 frames: heap memory, non-heap and classes. Heap memory structure is the most well known by regular Java developers because it’s found in stories about [GC](https://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html) (Garbage Collection). Look at the “limit” label in Heap Memory and Non-Heap Memory. You can see that Non-Heap memory limit can be equal or higher then Heap memory. That means that we have to limit non-heap memory too in case of k8s application.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*90HQMTYuuox9iMX8nW65ow.png" alt="" height="525" width="700"><figcaption><p>JVM Memory structure in Yourkit UI</p></figcaption></figure>

A lesser known part of JVM memory is Non-Heap. Non heap memory consists of the following parts:

* [Meta space](https://stuefe.de/posts/metaspace/metaspace-architecture/) — contains meta information about jvm.
* [Compressed Class Space](https://stuefe.de/posts/metaspace/what-is-compressed-class-space/) — separate space for [class metadata](https://poonamparhar.github.io/understanding-metaspace-gc-logs/).
* CodeHeap (non-nmethods) is new name of [Code Cache](https://docs.oracle.com/javase/8/embedded/develop-apps-platforms/codecache.htm) that contains complited bytecode into native code.
* CodeHeap (non-profiled nmethods) is new name of [Code Cache](https://docs.oracle.com/javase/8/embedded/develop-apps-platforms/codecache.htm) that contains complited bytecode into native code.

## JVM Memory flags <a href="#7e46" id="7e46"></a>

You can apply memory flags adding to `java {PUT_FLAGS} {OTHER_COMMAND}` like `java -Mmx1024m -jar app.jar` . Each option consists of a`value` and unit like `g` (GB), `m` (MB), `k` (KB).

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*5rATDXwNbENDQL_HVdEn1w.png" alt="" height="177" width="700"><figcaption><p>JVM Print All Flags</p></figcaption></figure>

Let’s look at all memory limit related flags (option `-XX:+PrintFlagsFinal` shows all JVM flags):

* Xmx
* MaxMetaspaceSize
* CompressedClassSpaceSize
* ProfiledCodeHeapSize
* NonProfiledCodeHeapSize
* NonNMethodCodeHeapSize

## How to limit memory using flags <a href="#f379" id="f379"></a>

We can limit only Heap size (Xmx), Metaspace (MaxMetaspaceSize), Compressed Class (CompressedClassSpaceSize). Other parts of memory we can mark as other and assume that it will be less than 250MB.

Using this assumptions we can evaluate heap size using kubernetes container limit:

`HEAP_SIZE = KUBE_MEMORY_LIMIT-METASPACE_SIZE-COMPRESSED_CLASS_SIZE-OTHER_NON_HEAP_SIZE`

* **KUBE\_MEMORY\_LIMIT** comes from container limits. You can pass this limit to container using `valueFrom` env (`value -> valueFrom.resourceFieldRef.containerName:{yourContainerName}` + `valueFrom.resourceFieldRef.resource=limits.memory` )
* **METASPACE\_SIZE** depends on your application size. I suggest using 200 MB as a starting point. If metaspace is not enough then new classes can not be loaded.
* **COMPRESSED\_CLASS\_SIZE** can be equal 100MB but it is depends on your application
* **OTHER\_NON\_HEAP\_SIZE** can be equal 250MB.

I suggest using `entrypoint.sh` as the launcher of your application that evaluates all configuration options. Note that you have to print an error if the limit is too low for your application (HEAP\_SIZE based on your formula less than zero).

## Summary <a href="#a2f7" id="a2f7"></a>

Specify `KUBERNETES_MEMORY_LIMITS` in env

```yaml
- name: KUBERNETES_MEMORY_LIMITS
  valueFrom:
    resourceFieldRef:
      containerName: {PUT_YOUR_CONTAINER_NAME_HERE}
      resource: limits.memory
```plaintext

Start your application with `entrypoint.sh` that evaluates heap size with fixed predefined meta space and compressed class space.

```shell
KUBERNETES_MEMORY_LIMIT_MB=$((KUBERNETES_MEMORY_LIMITS/1048576))
META_SPACE_MB=200
COMPRESSED_CLASS_SPACE_MB=100
OTHER_NON_HEAP_MB=250
JVM_HEAP_MB=$((($KUBERNETES_MEMORY_LIMIT_MB-$META_SPACE_MB-$COMPRESSED_CLASS_SPACE_MB-$OTHER_NON_HEAP_MB)))

java \
  -Xmx${JVM_HEAP_MB}m \
  -XX:MaxMetaspaceSize=${META_SPACE_MB}m \
  -XX:CompressedClassSpaceSize=${COMPRESSED_CLASS_SPACE_MB}m \
  -jar \
  app.jar
```plaintext
