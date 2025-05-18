# Creating Azure Bicep modules 💪

## What are Azure Bicep Modules? <a href="#fe16" id="fe16"></a>

Bicep Modules are the application of the **Don’t Repeat Yourself** principle, where a Bicep template calls another Bicep template. As a result, this practice enables the reusability of existing code and can speed up the creation of future resources.

Imagine, for example, that you need to control how infrastructure resources are created. To accomplish this, you can implement rules in the bicep templates that, for example, restrict the size of virtual machines or the regions in which they can be created.

Since the definition has already been created and the rules, will probably remain the same in the next project, it is not necessary to create a new definition. We can create a module that allows us to save valuable time and money by reusing these definitions.

## How to create an Azure Bicep Module? <a href="#522c" id="522c"></a>

If you are already familiar with Bicep Templates, creating a Bicep Module is effortless, as a module has exactly the same structure and it is not necessary to add any special configuration. It is possible, inclusive, to reuse existing templates as modules.

## How to consume an Azure Bicep Module? <a href="#44ae" id="44ae"></a>

### _**Declaring a Bicep Module**_ <a href="#1ac9" id="1ac9"></a>

When working with Bicep Modules, the syntax changes compared to resources. Instead of declaring `resource`the declaration is now `module`**.** Additionally, it is necessary to reference the module path, which can be local or remote.

<figure><img src="https://miro.medium.com/v2/resize:fit:523/1*qtbw9GCE45MafTDjuJ_6vg.png" alt="" height="229" width="523"><figcaption><p>Image prepared by the author</p></figcaption></figure>

It is also mandatory to add a symbolic name to the resource. The symbolic name can be used to recover an output from the module to be used in another part of the template.

<figure><img src="https://miro.medium.com/v2/resize:fit:523/1*dvcRYdnC-LfnI9eJGBiCwA.png" alt="" height="229" width="523"><figcaption><p>Image prepared by the author</p></figcaption></figure>

The property `name` is mandatory. It will become the nested template name in the final template.

<figure><img src="https://miro.medium.com/v2/resize:fit:523/1*6W6RH47RoNV7GF6CfzRC-w.png" alt="" height="229" width="523"><figcaption><p>Image prepared by the author</p></figcaption></figure>

### _**Passing parameters to Bicep modules**_ <a href="#38ac" id="38ac"></a>

The parameters on modules follow the same syntax and contain the same features as regular templates. However, to send the parameters to a module it must be under the `params` node. It must match those declared in the module, including the validations.

<figure><img src="https://miro.medium.com/v2/resize:fit:523/1*QOZF4MK2Y5SfT6AuO2m2jg.png" alt="" height="229" width="523"><figcaption><p>Image prepared by the author</p></figcaption></figure>

## How to deploy an Azure Bicep Module? <a href="#8bc2" id="8bc2"></a>

Deployment of Bicep Modules works exactly like Bicep Templates. It is possible to use [Azure CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-cli?WT.mc\_id=DT-MVP-5004039), [Azure PowerShell](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell?WT.mc\_id=DT-MVP-5004039), or even through [Azure API.](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-rest?WT.mc\_id=DT-MVP-5004039)

After running it is possible to see in the deployments of Azure Resource Group the main.bicep deployment:

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*4QSoI-AuLcjYe9zxF6iiiQ.png" alt="" height="376" width="700"><figcaption><p>Image prepared by the author</p></figcaption></figure>

And if we click on the nested storage deployment we can observe the resource storageAccount being deployed :

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*gqdrDwcLHLaVUXVLbG31_Q.png" alt="" height="378" width="700"><figcaption><p>Image prepared by the author</p></figcaption></figure>

## Conclusion <a href="#0d5b" id="0d5b"></a>

Reusability is one of the main advantages that we can leverage from modularization in any programming language and with Infrastructure as Code templates, it wouldn’t be different. Another benefit is that it also will ensure that your environment is more stable as your templates will be already tested by others, and most importantly, will also save implementation time.
