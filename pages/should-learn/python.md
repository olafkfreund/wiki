# Python

Python is an increasingly popular programming language that has become a go-to choose for many Azure Platform Engineers. Azure is Microsoft's cloud computing platform, offering a wide range of services and tools for building, deploying, and managing applications and services. Here are some reasons why a Platform Engineer working with Azure should learn Python:

1. Automation: Python has a rich set of libraries that enable the creation of automated scripts and workflows. As a Platform Engineer, you may need to automate various tasks such as deploying infrastructure, configuring services, and managing resources. Python's automation capabilities can help you save time and reduce the risk of manual errors.
2. Azure SDK for Python: Microsoft provides an Azure SDK for Python, which is a collection of libraries and tools that enable the development of Azure applications in Python. This SDK provides access to all Azure services, making it easier for Platform Engineers to manage and configure their Azure infrastructure using Python.
3. Data Analysis: Python has a robust set of libraries for data analysis and visualization, such as Pandas and Matplotlib. As a Platform Engineer, you may need to analyze logs, monitor performance, and troubleshoot issues. Python's data analysis capabilities can help you gain insights into your Azure infrastructure and make informed decisions.
4. Open-Source: Python is an open-source programming language, meaning that it's free to use and has a large community of developers contributing to it. This community has created many libraries and tools that can be used to enhance Azure development, such as Azure Functions, Flask, and Django.
5. Scalability: Azure is a highly scalable cloud platform, and Python's support for concurrency and asynchronous programming makes it an excellent choice for building scalable applications. Python's asyncio library, for example, enables the creation of high-performance, non-blocking applications that can handle many requests simultaneously.

In conclusion, as an Azure Platform Engineer, learning Python can help you automate tasks, manage resources, analyze data, and build scalable applications. With its rich set of libraries and tools, Python is an excellent choice for Azure development and is quickly becoming a must-know language for many Platform Engineers.

Create a Virtual Machine:

```python
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.compute.models import HardwareProfile, NetworkInterfaceReference, \
    OSDisk, StorageAccountTypes, StorageProfile, VirtualHardDisk, VirtualMachine, \
    VirtualMachineSizeTypes, OSProfile, LinuxConfiguration, SshConfiguration, SshPublicKey

credential = DefaultAzureCredential()

compute_client = ComputeManagementClient(
    credential=credential,
    subscription_id='<your-subscription-id>'
)

vm_name = 'my-vm'
location = 'westus2'
rg_name = 'my-resource-group'
vnet_name = 'my-vnet'
subnet_name = 'my-subnet'
username = 'my-username'
password = 'my-password'
ssh_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCx...'

vm_parameters = VirtualMachine(
    location=location,
    hardware_profile=HardwareProfile(vm_size=VirtualMachineSizeTypes.standard_b1s),
    storage_profile=StorageProfile(
        image_reference={
            'publisher': 'Canonical',
            'offer': 'UbuntuServer',
            'sku': '20.04-LTS',
            'version': 'latest'
        },
        os_disk=OSDisk(
            create_option='fromImage',
            managed_disk=VirtualHardDisk(storage_account_type=StorageAccountTypes.standard_lrs)
        )
    ),
    os_profile=OSProfile(
        computer_name=vm_name,
        admin_username=username,
        admin_password=password,
        linux_configuration=LinuxConfiguration(
            disable_password_authentication=True,
            ssh=SshConfiguration(
                public_keys=[
                    SshPublicKey(
                        path='/home/{}/.ssh/authorized_keys'.format(username),
                        key_data=ssh_key
                    )
                ]
            )
        )
    ),
    network_profile={
        'network_interfaces': [
            {
                'id': compute_client.network_interfaces.get(
                    resource_group_name=rg_name,
                    network_interface_name='<your-network-interface-name>'
                ).id,
                'properties': {
                    'primary': True
                }
            }
        ]
    }
)

compute_client.virtual_machines.create_or_update(
    resource_group_name=rg_name,
    vm_name=vm_name,
    parameters=vm_parameters
)
```

Create an Azure Storage Account:

````python
from azure.identity import DefaultAzureCredential
from azure.mgmt.storage import StorageManagementClient
from azure.mgmt.storage.models import StorageAccountCreateParameters, Sku, SkuName, Kind

credential = DefaultAzureCredential()

storage_client = StorageManagementClient(
    credential=credential,
    subscription_id='<your-subscription-id>'
)

rg_name = 'my-resource-group'
account_name = 'mystorageaccount'
location = 'eastus'
sku = Sku(name=SkuName.standard_lrs)
kind = Kind.storage_v2

account_params = StorageAccountCreateParameters(
    sku=sku,
    kind=kind,
    location=location
)

storage_client.storage_accounts.create(rg_name, account_name, account_params)
```

3. List Azure Virtual Machines:

```python
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

credential = DefaultAzureCredential()

compute_client = ComputeManagementClient(
    credential=credential,
    subscription_id='<your-subscription-id>'
)

rg_name = 'my-resource-group'

vms = compute_client.virtual_machines.list(rg_name)

for vm in vms:
    print(vm.name)
````

These examples demonstrate how to create a Virtual Machine, create an Azure Storage Account, and list Virtual Machines using Python and the Azure SDK. Of course, there are many more operations you can perform with the SDK, and the documentation provides a comprehensive reference for all available functionality.
