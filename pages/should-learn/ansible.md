---
description: Ansible for DevOps & SRE (2025)
---

# Ansible for DevOps & SRE (2025)

Ansible is a leading open-source automation tool for managing cloud and on-premises infrastructure. Its agentless, YAML-based approach makes it ideal for DevOps and SRE teams working across AWS, Azure, GCP, Linux, NixOS, and WSL environments.

## Why Use Ansible in DevOps & SRE?
- **Cloud Automation**: Provision and configure resources on AWS, Azure, and GCP using official modules.
- **Idempotent Deployments**: Ensure consistent, repeatable infrastructure changes.
- **Agentless**: No software required on managed nodes (uses SSH/WinRM).
- **Integration**: Works with Terraform, CI/CD (GitHub Actions, Azure Pipelines, GitLab CI), and Kubernetes.
- **Extensible**: Huge module ecosystem for cloud, OS, containers, and more.

## Real-Life Examples

### 1. Multi-Cloud VM Provisioning (AWS & Azure)
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  tasks:
    - name: Launch AWS EC2 instance
      amazon.aws.ec2_instance:
        name: devops-ec2
        key_name: my-key
        instance_type: t3.micro
        image_id: ami-0abcdef1234567890
        region: eu-west-1
        tags:
          Owner: devops
      register: aws_result

    - name: Create Azure VM
      azure.azcollection.azure_vm:
        resource_group: devops-rg
        name: devops-vm
        vm_size: Standard_B1s
        admin_username: azureuser
        ssh_password_enabled: false
        ssh_public_keys:
          - path: /home/azureuser/.ssh/authorized_keys
            key_data: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
        image:
          offer: UbuntuServer
          publisher: Canonical
          sku: 20.04-LTS
          version: latest
        location: westeurope
      register: azure_result
```

### 2. Automated Patch Management (Linux)
```yaml
- hosts: linux_servers
  become: yes
  tasks:
    - name: Update all packages
      apt:
        upgrade: dist
        update_cache: yes
```

### 3. Kubernetes Manifest Deployment
```yaml
- hosts: localhost
  tasks:
    - name: Apply Kubernetes manifests
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', 'deployment.yaml') }}"
```

### 4. Integrating with GitHub Actions
```yaml
# .github/workflows/ansible-deploy.yml
name: Ansible Deploy
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Ansible
        run: pip install ansible
      - name: Run Playbook
        run: ansible-playbook -i inventory playbook.yml
```

### 5. LLM Integration for Change Summaries
```python
import openai

openai.api_key = 'sk-...'
summary = openai.ChatCompletion.create(
    model='gpt-4',
    messages=[
        {"role": "system", "content": "Summarize this Ansible deployment log for SREs."},
        {"role": "user", "content": open('ansible.log').read()}
    ]
)
print(summary['choices'][0]['message']['content'])
```

## Best Practices (2025)
- Use roles and playbooks for modular, reusable code
- Store secrets in Ansible Vault or cloud secret managers
- Integrate Ansible runs with CI/CD pipelines
- Test playbooks with Molecule
- Use tags for targeted runs
- Prefer official cloud modules for AWS, Azure, GCP
- Document all playbooks and roles

## Common Pitfalls
- Hardcoding credentials in playbooks
- Not using idempotent modules (avoid shell/command when possible)
- Ignoring error handling (use `ignore_errors` judiciously)
- Not validating playbooks before production runs
- Overusing `become` without need

## References
- [Ansible Docs](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [AWS Ansible Collection](https://docs.ansible.com/ansible/latest/collections/amazon/aws/)
- [Azure Ansible Collection](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/)
- [Kubernetes Ansible Collection](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/)

---

> **Ansible Joke:**
> Why did the SRE break up with Ansible? Too many unresolved variables!
