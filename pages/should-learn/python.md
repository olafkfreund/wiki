# Python for DevOps & SRE (2025)

Python is a top choice for DevOps and SRE engineers working across AWS, Azure, and GCP. Its versatility, rich ecosystem, and strong cloud SDK support make it ideal for automating infrastructure, integrating with CI/CD, and building cloud-native solutions.

## Why DevOps & SREs Should Learn Python

1. **Cloud Automation**: Python SDKs for AWS (boto3), Azure, and GCP enable engineers to automate provisioning, scaling, and management of cloud resources.
2. **IaC & Configuration**: Python is used in tools like Ansible, Pulumi, and custom Terraform modules for advanced automation.
3. **CI/CD Integration**: Python scripts are common in GitHub Actions, Azure Pipelines, and GitLab CI/CD for deployment, testing, and monitoring.
4. **Observability & Monitoring**: Python powers log analysis, custom Prometheus exporters, and alerting integrations.
5. **LLM & AI Integration**: Python is the primary language for integrating Large Language Models (LLMs) into DevOps workflows (e.g., using OpenAI, Azure OpenAI, or Hugging Face APIs).

## Real-Life Examples

### 1. AWS EC2 Instance Automation (boto3)
```python
import boto3

ec2 = boto3.resource('ec2')
instance = ec2.create_instances(
    ImageId='ami-0abcdef1234567890',
    MinCount=1,
    MaxCount=1,
    InstanceType='t3.micro',
    KeyName='my-keypair',
    TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Owner', 'Value': 'devops'}]}]
)
print(f'Launched instance: {instance[0].id}')
```

### 2. Azure VM Creation (Azure SDK)
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

### 3. GCP Cloud Storage Bucket Creation (google-cloud-storage)
```python
from google.cloud import storage

client = storage.Client()
bucket = client.create_bucket('my-devops-bucket-2025')
print(f'Created bucket: {bucket.name}')
```

### 4. Integrating LLMs for Automated Change Summaries
```python
import openai

openai.api_key = 'sk-...'
response = openai.ChatCompletion.create(
    model='gpt-4',
    messages=[
        {"role": "system", "content": "Summarize this deployment change log for SREs."},
        {"role": "user", "content": open('changelog.txt').read()}
    ]
)
print(response['choices'][0]['message']['content'])
```

### 5. CI/CD Pipeline Step (GitHub Actions)
```yaml
- name: Run Python deployment script
  run: |
    python deploy.py --env=prod
```

## Best Practices (2025)
- Use virtual environments (venv, pipenv) for dependency management
- Store secrets securely (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)
- Write idempotent scripts for infrastructure changes
- Integrate Python scripts with CI/CD for repeatable automation
- Use logging and exception handling for observability
- Test automation code with pytest or unittest

## Common Pitfalls
- Hardcoding credentials in scripts
- Not handling API rate limits or errors
- Ignoring dependency pinning (requirements.txt)
- Lack of logging and monitoring
- Not using version control for automation scripts

## References
- [Python Official Docs](https://docs.python.org/3/)
- [boto3 AWS SDK](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [Azure SDK for Python](https://learn.microsoft.com/python/azure/)
- [Google Cloud Python Client](https://cloud.google.com/python/docs/reference)
- [OpenAI Python API](https://platform.openai.com/docs/api-reference)

---

> **Python Joke:**
> Why did the DevOps engineer love Python scripts? Because they always passed the test—unless they were indented wrong!
