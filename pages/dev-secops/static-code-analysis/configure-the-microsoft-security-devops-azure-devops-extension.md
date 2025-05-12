# Configure the Microsoft Security DevOps Azure DevOps extension

Microsoft Security DevOps is a command line application that integrates static analysis tools into the development lifecycle. Microsoft Security DevOps installs, configures, and runs the latest versions of static analysis tools (including, but not limited to, SDL/security and compliance tools). Microsoft Security DevOps is data-driven with portable configurations that enable deterministic execution across multiple environments.

The Microsoft Security DevOps uses the following Open Source tools:

| Name                                                                                          | Language                                                                                                                                                                                                                                                                        | License                                                                         |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| [AntiMalware](https://www.microsoft.com/windows/comprehensive-security)                       | AntiMalware protection in Windows from Microsoft Defender for Endpoint, that scans for malware and breaks the build if malware has been found. This tool scans by default on windows-latest agent.                                                                              | Not Open Source                                                                 |
| [Bandit](https://github.com/PyCQA/bandit)                                                     | Python                                                                                                                                                                                                                                                                          | [Apache License 2.0](https://github.com/PyCQA/bandit/blob/master/LICENSE)       |
| [BinSkim](https://github.com/Microsoft/binskim)                                               | Binary--Windows, ELF                                                                                                                                                                                                                                                            | [MIT License](https://github.com/microsoft/binskim/blob/main/LICENSE)           |
| [Credscan](https://learn.microsoft.com/en-us/azure/defender-for-cloud/detect-exposed-secrets) | <p>Credential Scanner (also known as CredScan) is a tool developed and maintained by Microsoft to identify credential leaks such as those in source code and configuration files<br>common types: default passwords, SQL connection strings, Certificates with private keys</p> | Not Open Source                                                                 |
| [ESlint](https://github.com/eslint/eslint)                                                    | JavaScript                                                                                                                                                                                                                                                                      | [MIT License](https://github.com/eslint/eslint/blob/main/LICENSE)               |
| [Template Analyzer](https://github.com/Azure/template-analyzer)                               | ARM template, Bicep file                                                                                                                                                                                                                                                        | [MIT License](https://github.com/Azure/template-analyzer/blob/main/LICENSE.txt) |
| [Terrascan](https://github.com/accurics/terrascan)                                            | Terraform (HCL2), Kubernetes (JSON/YAML), Helm v3, Kustomize, Dockerfiles, Cloud Formation                                                                                                                                                                                      | [Apache License 2.0](https://github.com/accurics/terrascan/blob/master/LICENSE) |
| [Trivy](https://github.com/aquasecurity/trivy)                                                | container images, file systems, git repositories                                                                                                                                                                                                                                | [Apache License 2.0](https://github.com/aquasecurity/trivy/blob/main/LICENSE)   |

YAML&#x20;

```yaml
# Starter pipeline
# Start with a minimal pipeline that you can customize to build and deploy your code.
# Add steps that build, run tests, deploy, and more:
# https://aka.ms/yaml
trigger: none
pool:
  vmImage: 'windows-latest'
steps:
- task: MicrosoftSecurityDevOps@1
  displayName: 'Microsoft Security DevOps'
```plaintext
