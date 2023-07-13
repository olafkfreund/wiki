# Real-life example

When working with cluster components, or building custom resources, that are deployed in Kubernetes, it is often necessary to run full end-to-end tests to ensure all aspects of your solutions work as intended.

> Project e2e-framework [sigs.k8s.io/e2e-framework](http://sigs.k8s.io/e2e-framework)

Project [e2e-framework](https://github.com/kubernetes-sigs/e2e-framework), from Kubernetes-SIGs, makes it easy to create and run end-to-end tests using the standard Go test tool. Some high-level goals of the project includes:

* Provide a sensible programmatic API using Go’s built-in test tools
* Expose packages that are easy to programmatically consume
* Provide helper packages that makes it easy to interact with the cluster and the Kubernetes API server

## Hello e2e-framework <a href="#a71f" id="a71f"></a>

An e2e-framework test is written as a normal Go test function. First, you will need to get the e2e-framework module as a dependency for your project:

```sh
go get sigs.k8s.io/e2e-framework@latest
```

The first step in using e2e-framework is to (programmatically) setup and configure a test environment, `tenv`, that will be used to run the defined test.

```go
tenv := env.NewWithConfig(envconf.New())
```

Prior to continue, it should be understood that e2e-framework tests are broken into units called `features`. A feature can have a name, arbitrary labels (used for filtering), and lifecycle setup/teardown functions. Crucially, features can also include assessment functions which contain test logic for the feature.

Now that we know the parts of an e2e-framework test, let us define a simple Go test function with a simple test feature, `feat`:

```go
func TestHello(t *testing.T) {
 tenv := env.NewWithConfig(envconf.New())
 var name string
 
 feat := features.New("Hello Feature").
   WithLabel("type", "simple").
   Setup(func(ctx context.Context, t *testing.T, _ *envconf.Config) context.Context {
     name = "foobar"
     return ctx
   }).
   Assess("test message", func(ctx context.Context, t *testing.T, _ *envconf.Config) context.Context {
     result := Hello(name)
     if result != "Hello foobar" {
       t.Error("unexpected message")
     }
     return ctx
   })

  tenv.Test(t, feat.Feature())
}
```

In the example above, feature `feat` has title “Hello Feature” and defines label `type=simple`. It also includes a `Setup` function that is used to initialize variable `name`. Method call `Assess` defines an assessment function, that contains a simple test logic, with title “test message”. Lastly, test environment `tenv` is used to trigger the test with method call `tenv.Test(t, feat.Feature())`.

Running the e2e-framework test above is as simple as using the `go test` command as shown below:

```go
go test .

=== RUN   TestHello
=== RUN   TestHello/Hello_Feature
=== RUN   TestHello/Hello_Feature/test_message
--- PASS: TestHello (0.00s)
    --- PASS: TestHello/Hello_Feature (0.00s)
        --- PASS: TestHello /Hello_Feature/test_message (0.00s)
PASS
ok      vladimirvivien/e2e-framework/simple  0.803s
```

## An end-to-end Kubernetes test <a href="#3b0a" id="3b0a"></a>

Now, let us explore how the e2e-framework can be used to write code to test resources deployed on a Kubernetes cluster.

### Configure a test environment in TestMain <a href="#4c6c" id="4c6c"></a>

The snippet below uses Go test function `TestMain` to programmatically configure a test environment, `testenv`, in a test suite. Inside `TestMain`, the code uses the test environment to define lifecycle function `Setup`, triggered before any test feature is executed. The test environment also defines a teardown function, `Finish`, which is triggered after all feature tests are executed in the test suite.

```go

var testenv env.Environment

func TestMain(m *testing.M) {
 testenv = env.New()
 kindClusterName := envconf.RandomName("ngnix-web", 16)
 namespace := envconf.RandomName("kind-ns", 16)

 // pre-test setup of kind cluster
 testenv.Setup(
  envfuncs.CreateKindCluster(kindClusterName),
  envfuncs.CreateNamespace(namespace),
 )

 // post-test teardown kind cluster
 testenv.Finish(
  envfuncs.DeleteNamespace(namespace),
  envfuncs.DestroyKindCluster(kindClusterName),
 )
 os.Exit(testenv.Run(m))
}
```

The source snippet above also highlights the fact that the e2e-framework comes bundled with several pre-defined environment functions (in package `envfuncs`). This example uses environment function `envfuncs.CreateKindCluster` to create a KinD cluster during the environment setup. Conversely, environment function `envfuncs.DestroyKindCluster` is used to teardown the cluster after the test is finished.

### Cluster component end-to-end test <a href="#d592" id="d592"></a>

Now let us create a simple test that uses the e2e-framework library to do the followings:

* Create an _appv1.Deployment_ on the Kubernetes cluster
* Test to ensure the deployment is fully deployed within a specified time
* Delete the deployment from the cluster

```go
func TestDeployment(t *testing.T) {
 feat := features.New("v1/deployment").WithLabel("app", "nginx-web")
 
 // Run before feature assessment: create deployment
 feat.Setup(func(ctx context.Context, t *testing.T, cfg *envconf.Config) context.Context {
   // create a deployment
   deployment := newDeployment(cfg.Namespace(), "test-deployment", 4)
   client, err := cfg.NewClient()
   if err != nil {
    t.Fatal(err)
   }
   if err := client.Resources().Create(ctx, deployment); err != nil {
    t.Fatal(err)
   }
   return ctx
  })

 // Assessment - wait for deployment and all replicas to be fully available or timeout
 feat.Assess("deployment ready", func(ctx context.Context, t *testing.T, cfg *envconf.Config) context.Context {
   client, err := cfg.NewClient()
   if err != nil {
    t.Fatal(err)
   }
   dep := appsv1.Deployment{
    ObjectMeta: metav1.ObjectMeta{Name: "test-deployment", Namespace: cfg.Namespace()},
   }
   // use wait package to wait for deployment to be ready in 1 minute
   err = wait.For(conditions.New(client.Resources()).DeploymentConditionMatch(&dep, appsv1.DeploymentAvailable, v1.ConditionTrue), wait.WithTimeout(time.Minute*1))
   if err != nil {
    t.Fatal(err)
   }
   return ctx
 })

 // Run after all assessments: Delete deployment Teardown
 feat.Teardown(func(ctx context.Context, t *testing.T, cfg *envconf.Config) context.Context {
   client, err := cfg.NewClient()
   if err != nil {
    t.Fatal(err)
   }
   dep := appsv1.Deployment{
    ObjectMeta: metav1.ObjectMeta{Name: "test-deployment", Namespace: cfg.Namespace()},
   }
   err = client.Resources(cfg.Namespace()).Delete(context.TODO(), &dep)
   if err != nil {
    t.Fatal(err)
   }
   return ctx
 })

 // trigger feature tests
 testenv.Test(t, feat.Feature())
}

// helper to create appsv1.Deployment
func newDeployment(namespace string, name string, replicas int32) *appsv1.Deployment {

  return &appsv1.Deployment{
   ObjectMeta: metav1.ObjectMeta{Name: name, Namespace: namespace, Labels: map[string]string{"app": "nginx-web"}},
   Spec: appsv1.DeploymentSpec{
     Replicas: &replicas,
     Selector: &metav1.LabelSelector{
       MatchLabels: map[string]string{"app": "ngix-web"},
     },
     Template: v1.PodTemplateSpec{
       ObjectMeta: metav1.ObjectMeta{Labels: map[string]string{"app": "nginx-web"}},
       Spec: v1.PodSpec{Containers: []v1.Container{{Name: "nginx", Image: "nginx"}}},
     },
   },
 }

}
```

What is going on in the code above, you may be wondering? Go test function `TestDeployment` defines feature variable `feat` with a `Setup`, an `Assess`, and a `Teardown` method which creates a Deployment object, waits for the deployment replicas to be fully deployed, and deletes the deployment respectively.

The test source code above also highlights the `wait` package, which comes with the e2e-framework, to declare a condition and wait for that condition to become true within a time period. In the example above, the `wait` package is used to wait for the Deployment to be marked available within one minute. If that condition fails, an error is returned and the test fails.

### Testing the code <a href="#8b26" id="8b26"></a>

Because the e2e-framework integrates well with KinD, all that is required to run the test above is the following command:

```shell
go test .
```

The framework will automatically create a kind cluster, create the deployment object in the cluster, run the test specified in the assessment, delete the object, and finally delete the cluster once all tests have completed.

### e2e-framework flags <a href="#b0c0" id="b0c0"></a>

The e2e-framework also exposes several flags to help you configure the execution of your tests at runtime. For instance, the following will only execute tests with features titled “deployment”.

```shell
go test -v . -args --features "depolyment"
```

Or, you can specify to only run features with a specific label.

```shell
go test -v . -args --labels "app=web"
```

The framework also supports flags that skips tests based on provided values. For instance, the following will skip assessments with title “pod-unstable” during test execution.

```sh
go test -v . -args --skip-assessment "pod-unstable"
```

> Read more about e2e-framework supported flags [here](https://github.com/kubernetes-sigs/e2e-framework/tree/main/examples/flags).

## Conclusion <a href="#9ac2" id="9ac2"></a>

This post provides a high-level introduction that shows how to get started with project [Kubernetes-SIGs/e2e-framework](https://github.com/kubernetes-sigs/e2e-framework) to write and run end-to-end tests for your Kubernetes cluster components. The framework provides packages to compose and run tests that can automatically start a local cluster, deploy components on the cluster, and run assessments that test those components, and teardown all resources when done.

