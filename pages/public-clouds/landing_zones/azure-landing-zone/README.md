# Azure landing zone

An Azure landing zone architecture is scalable and modular to meet a range of deployment needs. A repeatable infrastructure allows you to consistently apply configurations and controls to every subscription. Modules make it easy to deploy and modify specific components of the Azure landing zone architecture as your requirements evolve.

The Azure landing zone conceptual architecture (_see figure 1_) represents an opinionated, target architecture for your Azure landing zone

<figure><img src="https://learn.microsoft.com/en-gb/azure/cloud-adoption-framework/ready/enterprise-scale/media/ns-arch-cust-expanded.svg" alt=""><figcaption><p><em>Figure 1: Azure landing zone conceptual architecture. Download a</em> <a href="https://raw.githubusercontent.com/microsoft/CloudAdoptionFramework/master/ready/enterprise-scale-architecture.vsdx"><em>Visio file</em></a> <em>of this architecture.</em></p></figcaption></figure>

**Design areas:** The conceptual architecture illustrates the relationships between its eight design areas. These design areas are Azure billing and Azure Active Directory tenant (A), identity and access management (B), resource organization (C), network topology and connectivity (E), security (F), management (D, G, H), governance (C, D), and platform automation and DevOps (I).&#x20;

**Resource organization:** The conceptual architecture shows a sample management group hierarchy. It organizes subscriptions (yellow boxes) by management group. The subscriptions under the "Platform" management group represent the platform landing zones. The subscriptions under the "Landing zone" management group represent the application landing zones. The conceptual architecture shows five subscriptions in detail. You can see the resources in each subscription and the policies applied.

## Refactor landing zones <a href="#refactor-landing-zones" id="refactor-landing-zones"></a>

A landing zone is an environment for hosting your workloads that's **preprovisioned through code**. Since landing zone infrastructure is defined in code, it can be refactored similar to any other codebase. Refactoring is the process of modifying or restructuring source code to optimize the output of that code without changing its purpose or core function.

The Ready methodology uses the concept of refactoring to accelerate migration and remove common blockers. The steps in the ready overview discuss a process that starts with predefined landing zone template that aligns best with your hosting function. Then refactor or add to the source code to expand the landing zones ability to deliver that function through improved security, operations, or governance. The following image illustrates the concept of refactoring.

<figure><img src="https://learn.microsoft.com/en-gb/azure/cloud-adoption-framework/_images/ready/refactor.png" alt=""><figcaption></figcaption></figure>

### Theory <a href="#theory" id="theory"></a>

The concept of refactoring a landing zone is simple, but execution requires proper guardrails. The concept shown above outlines the basic flow:

* When you're ready to build your first landing zone, start with an initial landing zone defined via a template.
* Once that landing zone is deployed, use the guidance in the articles under the `Enhance` section of the table of contents to refactor and add to your initial landing zone.
* Repeat the process of reviewing and adding until you have an enterprise-ready environment that meets the enhanced requirements of your security, operations, and governance teams.
