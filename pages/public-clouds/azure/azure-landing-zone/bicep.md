# Bicep

Design

<figure><img src="https://learn.microsoft.com/en-us/azure/architecture/landing-zones/bicep/images/bicep-architecture.png" alt=""><figcaption></figcaption></figure>

The architecture takes advantage of the modular nature of Azure Bicep and is composed of number of modules. Each module encapsulates a core capability of the Azure Landing Zones conceptual architecture. The modules can be deployed individually, but there are dependencies to be aware of.

The architecture proposes the inclusion of orchestrator modules to simplify the deployment experience. The orchestrator modules could be used to automate the deployment of the modules and to encapsulate differing deployment topologies.



Ref: [https://learn.microsoft.com/en-us/azure/architecture/landing-zones/bicep/landing-zone-bicep](https://learn.microsoft.com/en-us/azure/architecture/landing-zones/bicep/landing-zone-bicep)
