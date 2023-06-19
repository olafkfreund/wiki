# Terraform

### Design <a href="#design" id="design"></a>

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/landing-zones/terraform/images/alz-tf-module-overview.png" alt=""><figcaption></figcaption></figure>

The architecture takes advantage of the configurable nature of Terraform and is composed of a primary orchestration module. This module encapsulates multiple capabilities of the Azure landing zones conceptual architecture. You can deploy each capability individually or in part. For example, you can deploy just a hub network, or just the Azure DDoS Protection, or just the DNS resources. When doing so, you need to consider that the capabilities have dependencies.

### Layers and staging <a href="#layers-and-staging" id="layers-and-staging"></a>

The implementation focuses on the central resource hierarchy of the Azure landing zone conceptual architecture. The design is centered around the following capabilities:

* Core resources
* Management resources
* Connectivity resources
* Identity resources

The module groups resources into these capabilities as they are intended to be deployed together. These groups form logical stages of the implementation.

You control the deployment of each of these capabilities by using feature flags. A benefit of this approach is the ability to add to your environment incrementally over time. For example, you can start with a small number of capabilities. You can add the remaining capabilities at a later stage when you’re ready.



Ref: [https://learn.microsoft.com/en-us/azure/architecture/landing-zones/terraform/landing-zone-terraform](https://learn.microsoft.com/en-us/azure/architecture/landing-zones/terraform/landing-zone-terraform)
