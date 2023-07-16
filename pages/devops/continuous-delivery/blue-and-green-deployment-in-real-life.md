# Blue and Green Deployment in real-life

Suppose we have a PaymentService:v1.0.0 (that is called **Blue**) running on our kubernetes cluster:

<figure><img src="https://miro.medium.com/v2/resize:fit:507/1*_lquSqjK90JCIUlOr5TUpw.png" alt="" height="420" width="507"><figcaption><p>PaymentService:v1.0.0 serving the users requests</p></figcaption></figure>

From here, the new version PaymentService:v1.1.0 (that is called **Green**) is deployed next to the old version without affecting its:

<figure><img src="https://miro.medium.com/v2/resize:fit:507/1*fzzsyHHbCwDAvah2NHWTzQ.png" alt="" height="420" width="507"><figcaption><p>PaymentService:v1.1.0 is deployed next to the old version without affecting its</p></figcaption></figure>

The new version of the application is deployed and can be tested for functionality and performance.

Once the testing results are successful, application traffic is switched from blue to green:

<figure><img src="https://miro.medium.com/v2/resize:fit:507/1*dSEoJB6cKyeYnppoO-aS2w.png" alt="" height="420" width="507"><figcaption><p>Green then becomes the new production</p></figcaption></figure>

## Let’s try it now! <a href="#0aa4" id="0aa4"></a>

## What is Argo Rollouts? <a href="#47e4" id="47e4"></a>

> [Argo Rollouts is a Kubernetes controller and set of CRDs which provide advanced deployment capabilities such as blue-green, canary, canary analysis, experimentation, and progressive delivery features to Kubernetes.](https://argo-rollouts.readthedocs.io/en/stable/)

We use Terraform and an argo terraform module that I have implemented in order to deploy Argo products.

## Terraform-Argo-Module <a href="#6914" id="6914"></a>

modules/kubernetes\_modules/argo/argo\_rollouts.tf

```
resource "helm_release" "argo_rollouts" {

  for_each = var.argo_rollouts != null ? toset(["devops"]) : toset([])
  
  name       = var.argo_rollouts.name  

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = var.argo_rollouts.version
  namespace  = "argo-rollouts"
  create_namespace = true 


  dynamic "set" {
    for_each = var.argo_rollouts.sets

    content {
        name = set.key 
        value = set.value  
    }
  }

  values = var.argo_rollouts.values 
}
```

modules/kubernetes\_modules/argo/variables.tf

```
variable "argo_rollouts" {

    type = object({
        name = string 
        sets = optional(map(string), {})
        values = optional(set(string), [])
        version = optional(string)

    })

    default = null
}
```

## Blue Green Example Project <a href="#9081" id="9081"></a>

examples/bluegreen/main.tf

```
module "argo" {

    source = "../../modules/kubernetes_modules/argo"

    argo_rollouts = {
        name = "lupass"
        version = "2.31.0"

        values = [
            yamlencode(
                {
                    dashboard = {
                        enabled = true 
                        service = {
                            type = "LoadBalancer"
                        }
                    }
                }
            )
        ]
    }
}
```

Remember to define providers.tf in order to use kubernetes and helm providers and to connect to your cluster.

```
provider "kubernetes" {
  config_path    = "~/.kube/config"

}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

Running terraform apply, we deploy Argo Rollouts on our target cluster.

## Deploy Application to test blue green deployment <a href="#7f9d" id="7f9d"></a>

To obtain the advanced deployments capabilities, we need to specify our Application Manifest via Argo Rollout CRD: Rollout. It is the same of Kubernetes deployments plus a strategy block with which you can define your deployment strategy:

```


resource "kubernetes_namespace" "my_app" {

    metadata  {
        name = "my-app"
    }
}

resource "kubernetes_manifest" "super_hello" {

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind = "Rollout"
    metadata = {
      name = "super-hello"
      namespace = kubernetes_namespace.my_app.metadata.0.name 

    }

    spec = {
        replicas = 3
        revisionHistoryLimit = 6
        selector = {
            matchLabels = {
                "app" = "super-hello"
            }
        }
        template = {
            metadata = {
                labels = {
                    "app" = "super-hello"
                }
            }
            spec = {
                containers = [
                    {
                        name = "super-hello"
                        image = "ghcr.io/gbaeke/super:1.0.2"
                        env = [
                            {
                                name = "WELCOME"
                                value = "VERSION V2"
                            }
                        ]
                        imagePullPolicy = "Always"
                        resources = {
                            requests = {
                                memory = "128Mi"
                                cpu = "50m"
                            }
                            limits = {
                                memory = "128Mi"
                                cpu = "50m"
                            }
                        }
                        readinessProbe = {
                            httpGet = {
                                path = "/healthz"
                                port = "8080"
                                initialDelaySeconds = 3
                                periodSeconds = 3
                            }
                        }
                    }
                ]
            }
        }
        strategy = {
            blueGreen = {
                activeService = kubernetes_service_v1.blue_green_prod.metadata.0.name
                previewService = kubernetes_service_v1.blue_green_preview.metadata.0.name
                autoPromotionEnabled = false 
            }
        }
    }


  }

  field_manager {
    force_conflicts = true 
  }

}

resource "kubernetes_service_v1" "blue_green_prod" {

    metadata {
        name = "super-hello-prod"
        namespace = kubernetes_namespace.my_app.metadata.0.name 
    }

    spec {
        selector = {
          "app" = "super-hello"    
        }

        port {
            port = 8088
            target_port = 8080
        }
        type = "LoadBalancer"
    }
  lifecycle {
        ignore_changes = [
            metadata.0.annotations["argo-rollouts.argoproj.io/managed-by-rollouts"],
            spec.0.selector["rollouts-pod-template-hash"],
        ]
    }
}


resource "kubernetes_service_v1" "blue_green_preview" {

    metadata {
        name = "super-hello-preview"
        namespace = kubernetes_namespace.my_app.metadata.0.name 
    }

    spec {
        selector = {
          "app" = "super-hello"    
        }

        port {
            port = 8089
            target_port = 8080
        }
        type = "LoadBalancer"
    }
  lifecycle {
        ignore_changes = [
            metadata.0.annotations["argo-rollouts.argoproj.io/managed-by-rollouts"],
            spec.0.selector["rollouts-pod-template-hash"],
        ]
    }
}
```

After that we have (_**for simplicity we draw only one pod in the image**_):

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*KGvAunBfQhFebXbNr29hdQ.png" alt="" height="372" width="700"><figcaption></figcaption></figure>

kubectl get all -n my-app

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*DbrGL1KrsVKqLbap5C-MUg.png" alt="" height="191" width="700"><figcaption></figcaption></figure>

The SVC **suer-hello-prod** (and **BalancerProd**) is used for production traffic, instead of **super-hello-preview (**and **Balancer Preview)** that can be used in order to test future updates by Developers/Testers/SRE/...

If we do a HTTP GET request to BalancerProd:

```
curl http://192.168.93.140:8088 && echo
VERSION V2
```

And also it is exposed on preview side via BalancerPreview:

```
curl http://192.168.93.140:8089 && echo
VERSION V2
```

To see the status of our application , there is also

kubectl argo rollouts get rollout bluegreen-demo -n my-app — watch:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*mZ6ktHZY70j6X6KdFl-uiA.png" alt="" height="370" width="700"><figcaption></figcaption></figure>

From Argo Rollout Dashboard UI:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*opGhPq9W8Kg1-ySV0IZLIA.png" alt="" height="505" width="700"><figcaption></figcaption></figure>

Now, we update our manifest setting MESSAGE env variable with value “VERSION V3”

_N.B: The image tag remains the same (1.0.2), but what we change is the MESSAGE that returns (from V2 to V3). But it’s the same if we change the tag version._

At this point, the Argo Rollout detect the changes and apply the strategy defined in the desired state of our Rollout Manifest.

As we can see, now we have this situation:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*7QZx_VjJQtfo63WFg93Ngg.png" alt="" height="372" width="700"><figcaption></figcaption></figure>

kubectl argo rollouts get rollout super-hello -n my-app — watch

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*IlQ_K-ZqKGUvjr3k4-DjTw.png" alt="" height="461" width="700"><figcaption></figcaption></figure>

Argo Rollouts Dashboard UI

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*XIC_ZB2xSmThzVZouSePYw.png" alt="" height="368" width="700"><figcaption></figcaption></figure>

k get all -n my-app

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*Th-1eCSWzTyoAKfRkTa94w.png" alt="" height="254" width="700"><figcaption></figcaption></figure>

curl BalancerProd

```
 curl http://192.168.93.140:8088 && echo
VERSION V2
```

curl BalancerPreview

```
curl http://192.168.93.140:8089 && echo
VERSION V3
```

Once tested the functionality and the performance of super-hello:V3, we can promote the rollout and so switching to use super-hello:V3 in production:

```
> kubectl argo rollouts promote super-hello
rollout 'super-hello' promoted
```

So we have:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*07NKNjdmFVE8_C4sSG1UxA.png" alt="" height="372" width="700"><figcaption></figcaption></figure>

kubectl argo rollouts get

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*4ckgtl-nNS4gXCdfWD5cTw.png" alt="" height="445" width="700"><figcaption></figcaption></figure>

Argo Rollouts Dashboard UI

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*xNv3TCaSGZD-TtVhDokzuQ.png" alt="" height="318" width="700"><figcaption></figcaption></figure>

k get all -n my-app

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*NyNw7Om8-S2ymWxVj6YMMQ.png" alt="" height="209" width="700"><figcaption></figcaption></figure>

curl BalancerProd

```
curl http://192.168.93.140:8088 && echo
VERSION V3
```

curl BalancerPreview

```
curl http://192.168.93.140:8089 && echo
VERSION V3
```

Finaly, the old super-hello:V2 is destroyed:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*xITtkmUPB1bZROJth1gZxw.png" alt="" height="372" width="700"><figcaption></figcaption></figure>

This way you can minimize downtime possibilities by ensuring service availability during updates. In contrast to blue-green deployments, there are canary deployments that allow a gradual upgrade between versions.
