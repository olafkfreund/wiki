# Real-life example

In this article, we shall understand how to mock the Kubernetes client using the fake clientset of `client-go` package. Lets’s begin!

Create a package called `client` and a file called `client.go` which defines a struct called `Client` which holds the Kubernetes `Clientset`.

Kubernetes `Clientset`

* contains the clients for groups.
* is the struct used to implement the Kubernetes interface called`Interface`.
* `NewForConfig()` is the constructor of the Kubernetes `Interface` interface that returns the Clientset object.

Moving on, let’s define a public struct called `Client` in `client.go`

```go
// Client is the struct to hold the Kubernetes Clientset
type Client struct {
	Clientset kubernetes.Interface
}
```plaintext

Create a method called `CreatePod` that is called upon the `Client` struct to create pods in a given `namespace` as shown in the same `client.go` file

```go
// CreatePod method creates pod in the cluster referred by the Client
func (c Client) CreatePod(pod *v1.Pod) (*v1.Pod, error) {
	pod, err := c.Clientset.CoreV1().Pods(pod.Namespace).Create(context.TODO(), pod, metav1.CreateOptions{})
	if err != nil {
		klog.Errorf("Error occured while creating pod %s: %s", pod.Name, err.Error())
		return nil, err
	}

	klog.Infof("Pod %s is succesfully created", pod.Name)
	return pod, nil
}
```plaintext

The complete `client.go` file looks like this

```go
/package client

import (
	"context"

	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/klog/v2"
)

type Client struct {
	Clientset kubernetes.Interface
}

func (c Client) CreatePod(pod *v1.Pod) (*v1.Pod, error) {
	pod, err := c.Clientset.CoreV1().Pods(pod.Namespace).Create(context.TODO(), pod, metav1.CreateOptions{})
	if err != nil {
		klog.Errorf("Error occured while creating pod %s: %s", pod.Name, err.Error())
		return nil, err
	}

	klog.Infof("Pod %s is succesfully created", pod.Name)
	return pod, nil
}
```plaintext

Now, let us implement a `main.go` to consume the above `CreatePod` method. For this, we need to

* build the `clientset`

```go
kubeconfig = "<path to kubeconfig file>"

config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
if err != nil {
    panic(err.Error())
}

clientset, err := kubernetes.NewForConfig(config)
if err != nil {
    panic(err. Error())
}
```plaintext

* load the `Client` struct

```go
/client := client.Client{
    Clientset: clientset,
}
```plaintext

* define a `pod` resource object

```go
pod := &v1.Pod{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Pod",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "test-pod",
			Namespace: "default",
		},
		Spec: v1.PodSpec{
			Containers: []v1.Container{
				{
					Name:            "nginx",
					Image:           "nginx",
					ImagePullPolicy: "Always",
				},
			},
		},
	}
```plaintext

* invoke the `CreatePod` call upon the `client` object

```go
pod, err = client.CreatePod(pod)

if err != nil {
  fmt.Printf("%s", err)
}
klog.Infof("Pod %s has been successfully created", pod. Name)
```plaintext

The complete `main. Go` file looks like this

```go
package main

import (
	"fmt"

	client "github.com/kubernetes-sdk-for-go-101/pkg/client"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/klog/v2"
)

func main() {

	kubeconfig := "<path to kubeconfig file>"

	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		panic(err.Error())
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	client := client.Client{
		Clientset: clientset,
	}

	pod := &v1.Pod{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Pod",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "test-pod",
			Namespace: "default",
		},
		Spec: v1.PodSpec{
			Containers: []v1.Container{
				{
					Name:            "nginx",
					Image:           "nginx",
					ImagePullPolicy: "Always",
				},
			},
		},
	}

	pod, err = client.CreatePod(pod)
	if err != nil {
		fmt.Printf("%s", err)
	}
	klog.Infof("Pod %s has been successfully created", pod.Name)
}
```plaintext

When we run this `main.go` file against a running cluster, we end up creating a pod called `test-pod` in the `default` namespace.

Now, let us write a unit test for the same using the Go’s `testing` package. Here, inorder to create the Kubernetes `Clientset`, we use the `NewSimpleClientSet()` constructor from the `fake` package of `client-go/kubernetes` package instead of `NewForConfig()` constructor.

_**What is the difference?**_

`NewForConfig()` constructor returns the actual `ClientSet` that has the clients for every Kubernetes groups and operates upon an actual cluster. Whereas, `NewSimpleClientSet()` constructor returns clientset that will respond with the provided objects. It’s backed by a very simple object tracker that processes creates, updates and deletions as-is, without applying any validations and/or defaults.

What is important to note here is that the `Clientset` of the fake package also implements the Kubernetes Interface. Meant to be embedded into a struct to get a default implementation. This makes faking out just the method you want to test easier.

Our `main_test.go` would like this

```go
package main

import (
	"fmt"
	"testing"

	client "github.com/kubernetes-sdk-for-go-101/pkg/client"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	testclient "k8s.io/client-go/kubernetes/fake"
)

func TestCreatePod(t *testing.T) {
	var client client.Client
	client.Clientset = testclient.NewSimpleClientset()

	pod := &v1.Pod{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Pod",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "test-pod",
			Namespace: "default",
		},
		Spec: v1.PodSpec{
			Containers: []v1.Container{
				{
					Name:            "nginx",
					Image:           "nginx",
					ImagePullPolicy: "Always",
				},
			},
		},
	}

	_, err := client.CreatePod(pod)
	if err != nil {
		fmt.Print(err.Error())
	}

}
```plaintext

Now, if we run this test file using `go test` command, we will successfully execute the `CreatePod()` method even without running this against any running K8s cluster & by bypassing the `Get()` call by mimicing it to return the same object as sent as a parameter to it. Output will be something as shown

```shell
go test
I0520 00:02:03.789351   23893 pod.go:23] Pod test-pod is succesfully created
PASS
ok      github.com/kubernetes-sdk-for-go-101    0.681s
```plaintext

You can keep this article as reference and build upon this, a test framework or a unit test package for your applications employing Kubernetes `client-go`.&#x20;
