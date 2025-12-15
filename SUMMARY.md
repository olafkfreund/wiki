# Table of contents

* [Welcome!](README.md)
* [Quick Start Guide](pages/quick-starts/README.md)
* [About Me](pages/about-me.md)
* [CV](pages/cv.md)
* [Contribute](CONTRIBUTING.md)

## 🧠 DevOps & SRE Foundations

* [DevOps Overview](pages/devops/README.md)
  * [Engineering Fundamentals](pages/devops/engineering-fundamentals-checklist.md)
  * [Implementing DevOps Strategy](pages/devops/implementing-devops-strategy.md)
  * [DevOps Readiness Assessment](pages/devops/devops-readiness-assessment.md)
  * [Lifecycle Management](pages/need-to-know/devops-lifecycle-management.md)
  * [The 12 Factor App](pages/need-to-know/the-12-factor-app.md)
  * [Design for Self Healing](pages/need-to-know/design-for-self-healing.md)
  * [Incident Management Best Practices (2025)](pages/devops/incident-management-best-practices-2025.md)
* [SRE Fundamentals](pages/sre/README.md)
  * [Toil Reduction](pages/sre/toil.md)
  * [System Simplicity](pages/sre/simplicity.md)
  * [Real-world Scenarios](pages/sre/senarios/README.md)
    * [AWS VM Log Monitoring API](pages/sre/senarios/aws-vm-monitoring-api.md)
* [Agile Development](pages/devops/agile-development/README.md)
  * [Team Agreements](pages/devops/agile-development/team-agreements/README.md)
    * [Definition of Done](pages/devops/agile-development/team-agreements/definition-of-done.md)
    * [Definition of Ready](pages/devops/agile-development/team-agreements/definition-of-ready.md)
    * [Team Manifesto](pages/devops/agile-development/team-agreements/team-manifesto.md)
    * [Working Agreement](pages/devops/agile-development/team-agreements/sections-of-a-working-agreement.md)
* [Industry Scenarios](devops-and-sre-foundations/industry-scenarios/README.md)
  * [Finance and Banking](pages/devops/agile-development/senarios/finance.md)
  * [Public Sector (UK/EU)](pages/devops/agile-development/senarios/public_sector.md)
  * [Energy Sector Edge Computing](pages/devops/agile-development/senarios/energy_sector.md)

## 🛠️ DevOps Practices

* [Platform Engineering](pages/devops/platform-engineering.md)
* [FinOps](pages/devops/finops.md)
* [Observability](pages/devops/observability/README.md)
  * [Modern Practices](pages/devops/observability/modern-practices.md)

## 🚀 Modern DevOps Practices

* [Infrastructure Testing](pages/devops/iac-testing.md)
* [Modern Development](pages/devops/modern-development.md)
* [Database DevOps](pages/devops/database-devops.md)

## 🛠️ Infrastructure as Code (IaC)

* [Terraform](pages/terraform/README.md)
  * [Cloud Integrations - Provider-specific implementations](infrastructure-as-code-iac/terraform/cloud-integrations-provider-specific-implementations/README.md)
    * [Azure Scenarios](pages/terraform/azure-scenarios.md)
      * [Azure Authetication](pages/terraform/authenticate-terraform-to-azure/README.md)
        * [Service Principal](pages/terraform/authenticate-terraform-to-azure/service-principal-for-terraform.md)
        * [Service Principal in block](pages/terraform/authenticate-terraform-to-azure/specify-service-principal-credentials-in-a-terraform-provider-block.md)
        * [Service Principal in env](pages/terraform/authenticate-terraform-to-azure/specify-service-principal-credentials-in-environment-variables.md)
    * [AWS Scenarios](pages/terraform/aws-scenarios.md)
      * [AWS Authentication](pages/terraform/aws/aws_auth_terraform.md)
    * [GCP Scenarios](pages/terraform/gcp-scenarios.md)
      * [GCP Authentication](pages/terraform/gcp/gpc_auth_terraform.md)
  * [Testing and Validation](pages/terraform/testing/README.md)
    * [Unit Testing](pages/terraform/testing/unit-testing.md)
    * [Integration Testing](pages/terraform/testing/integration-testing.md)
    * [End-to-End Testing](pages/terraform/testing/e2e-testing.md)
    * [Terratest Guide](pages/terraform/testing/terratest.md)
  * [Best Practices](pages/terraform/best-practices/README.md)
    * [State Management](pages/terraform/best-practices/state-management.md)
    * [Security](pages/terraform/best-practices/security.md)
    * [Code Organization](pages/terraform/best-practices/code-organization.md)
    * [Performance](pages/terraform/best-practices/performance.md)
  * [Tools & Utilities - Enhancing the Terraform workflow](infrastructure-as-code-iac/terraform/tools-and-utilities-enhancing-the-terraform-workflow/README.md)
    * [Terraform Docs](pages/terraform/tools/terraform-docs.md)
    * [TFLint](pages/terraform/tools/tflint.md)
    * [Checkov](pages/terraform/tools/checkov.md)
    * [Terrascan](pages/terraform/tools/terrascan.md)
  * [CI/CD Integration - Automating infrastructure deployment](infrastructure-as-code-iac/terraform/ci-cd-integration-automating-infrastructure-deployment/README.md)
    * [GitHub Actions](pages/terraform/cicd/github-actions.md)
    * [Azure Pipelines](pages/terraform/cicd/azure-pipelines.md)
    * [GitLab CI](pages/terraform/cicd/gitlab-ci.md)
* [Bicep](pages/bicep/README.md)
  * [Getting Started - First steps with Bicep \[BEGINNER\]](infrastructure-as-code-iac/bicep/getting-started-first-steps-with-bicep-beginner.md)
  * [Template Specs](pages/bicep/template-spec-for-bicep.md)
  * [Best Practices - Guidelines for effective Bicep implementations](infrastructure-as-code-iac/bicep/best-practices-guidelines-for-effective-bicep-implementations.md)
  * [Modules - Building reusable components \[INTERMEDIATE\]](infrastructure-as-code-iac/bicep/modules-building-reusable-components-intermediate.md)
  * [Examples - Sample implementations for common scenarios](infrastructure-as-code-iac/bicep/examples-sample-implementations-for-common-scenarios.md)
  * [Advanced Features](pages/bicep/use-inline-scripts.md)
  * [CI/CD Integration - Automating Bicep deployments](infrastructure-as-code-iac/bicep/ci-cd-integration-automating-bicep-deployments/README.md)
    * [GitHub Actions](pages/bicep/bicep-with-github-actions.md)
    * [Azure Pipelines](pages/bicep/integrate-bicep-with-azure-pipelines.md)

## 💰 Cost Management & FinOps

* [Cloud Cost Optimization](pages/devops/cloud-cost-optimization.md)

## 🐳 Containers & Orchestration

* [Containerization Overview](pages/containers/README.md)
  * [Docker](pages/best-practises/containers/docker/README.md)
    * [Dockerfile Best Practices](pages/best-practises/containers/docker/dockerfile.md)
    * [Docker Compose](pages/best-practises/containers/docker/docker-compose.md)
  * [Kubernetes](pages/containers/kubernetes/README.md)
    * [CLI Tools - Essential command-line utilities](containers-and-orchestration/containers/kubernetes/cli-tools-essential-command-line-utilities/README.md)
      * [Kubectl](pages/containers/kubernetes/kubectl.md)
      * [Kubens](pages/containers/kubernetes/kubens.md)
      * [Kubectx](pages/containers/kubernetes/kubectx.md)
    * [Core Concepts](pages/need-to-know/kubernetes/kubernetes-concepts.md)
    * [Components](pages/need-to-know/kubernetes/kubernetes-components.md)
    * [Best Practices](pages/best-practises/containers/kubernetes/kubernetes-best-practices/README.md)
      * [Pod Security](pages/best-practises/containers/kubernetes/kubernetes-best-practices/pod-security.md)
      * [Security Monitoring](pages/best-practises/containers/kubernetes/kubernetes-best-practices/security-monitoring.md)
      * [Resource Limits](pages/best-practises/containers/kubernetes/kubernetes-best-practices/resource-limits/README.md)
    * [Advanced Features - Beyond the basics \[ADVANCED\]](containers-and-orchestration/containers/kubernetes/advanced-features-beyond-the-basics-advanced/README.md)
      * [Service Mesh](pages/should-learn/kubernetes/service-mesh/README.md)
        * [Istio](pages/should-learn/kubernetes/service-mesh/istio.md)
        * [Linkerd](pages/should-learn/kubernetes/service-mesh/linkerd.md)
      * [Ingress Controllers](pages/should-learn/kubernetes/ingress-controllers/README.md)
        * [NGINX](pages/should-learn/kubernetes/ingress-controllers/nginx.md)
        * [Traefik](pages/should-learn/kubernetes/ingress-controllers/traefik.md)
        * [Kong](pages/should-learn/kubernetes/ingress-controllers/kong.md)
        * [Gloo Edge](pages/should-learn/kubernetes/ingress-controllers/gloo-edge.md)
        * [Contour](pages/should-learn/kubernetes/ingress-controllers/contour.md)
    * [Tips](pages/should-learn/kubernetes/tips/README.md)
      * [Status in Pods](pages/should-learn/kubernetes/tips/k8s-troubleshooting-pod-in-container-creating-status.md)
      * [Resource handling](pages/should-learn/kubernetes/tips/kubernetes-resources-for-pods-and-containers.md)
      * [Pod Troubleshooting Commands](pages/should-learn/kubernetes/troubleshooting/kubernetes-pod-troubleshooting-commands.md)
    * [Enterprise Architecture](pages/best-practises/containers/kubernetes/enterprise-scale-architecture.md)
    * [Health Management](pages/best-practises/containers/kubernetes/health-management.md)
    * [Security & Compliance](pages/best-practises/containers/kubernetes/security-and-compliance.md)
    * [Virtual Clusters](pages/best-practises/containers/kubernetes/vcluster.md)
  * [OpenShift](pages/best-practises/containers/openshift.md)
* [Docker Image Security](containers-and-orchestration/docker-image-security.md)

## Service Mesh & Networking

* [Service Mesh Implementation](pages/devops/service-mesh/implementation-guide.md)

## Architecture Patterns

* [Data Mesh](pages/architecture/data-mesh/implementation-guide.md)
* [Multi-Cloud Networking](pages/architecture/networking/multi-cloud-connectivity.md)
* [Disaster Recovery](pages/architecture/disaster-recovery/implementation-guide.md)
* [Chaos Engineering](pages/architecture/chaos-engineering/implementation-guide.md)

## Edge Computing

* [Implementation Guide](pages/architecture/edge-computing/implementation-guide.md)
  * [Serverless Edge](pages/architecture/edge-computing/serverless-edge.md)
  * [IoT Edge Patterns](pages/architecture/edge-computing/iot-edge-patterns.md)
  * [Real-Time Processing](pages/architecture/edge-computing/real-time-processing.md)
  * [Edge AI/ML](pages/architecture/edge-computing/edge-ai-deployment.md)
  * [Security Hardening](pages/architecture/edge-computing/security-hardening.md)
  * [Observability Patterns](pages/architecture/edge-computing/observability-patterns.md)
  * [Network Optimization](pages/architecture/edge-computing/network-optimization.md)
  * [Storage Patterns](pages/architecture/edge-computing/storage-patterns.md)

## 🚀 CI/CD & Release Management

* [Continuous Integration](pages/devops/continuous-integration.md)
* [Continuous Delivery](pages/devops/continuous-delivery/README.md)
  * [Deployment Strategies](pages/need-to-know/guide-to-blue-green-canary-and-rolling-deployments.md)
  * [Secrets Management](pages/devops/continuous-delivery/secrets-management.md)
  * [Blue-Green Deployments](pages/devops/continuous-delivery/blue-and-green-deployment-in-real-life.md)
  * [Deployment Metrics](pages/devops/continuous-delivery/deployment-metrics.md)
  * [Progressive Delivery](pages/devops/continuous-delivery/progressive-delivery.md)
  * [Release Management for DevOps/SRE (2025)](pages/devops/continuous-delivery/release-management-2025.md)

### DevOps Governance & ITSM

* [DevOps Governance Overview](pages/devops/governance/README.md) - Change management and compliance automation
* [ServiceNow](pages/devops/governance/servicenow/README.md) - IT Service Management and change control
  * [CI/CD Integration Overview](pages/devops/governance/servicenow/cicd-integration-overview.md) - Platform-agnostic integration patterns
  * [GitLab Integration](pages/devops/governance/servicenow/gitlab-integration.md) - GitLab CI/CD integration guide
  * [GitHub Actions Integration](pages/devops/governance/servicenow/github-integration.md) - GitHub Actions integration guide
  * [Azure DevOps Integration](pages/devops/governance/servicenow/azure-devops-integration.md) - Azure Pipelines integration guide
  * [Best Practices](pages/devops/governance/servicenow/best-practices.md) - ServiceNow DevOps best practices
* [Kosli](pages/devops/governance/kosli/README.md) - Automated change tracking and compliance
  * [Getting Started](pages/devops/governance/kosli/getting-started.md) - Install and configure Kosli
  * [GitHub Actions Integration](pages/devops/governance/kosli/github-actions.md) - GitHub Actions integration guide
  * [GitLab CI Integration](pages/devops/governance/kosli/gitlab-ci.md) - GitLab CI/CD integration guide
  * [Azure DevOps Integration](pages/devops/governance/kosli/azure-devops.md) - Azure Pipelines integration guide
  * [CLI Reference](pages/devops/governance/kosli/cli-reference.md) - Complete CLI command reference
  * [Best Practices](pages/devops/governance/kosli/best-practices.md) - Kosli implementation best practices

## CI/CD Platforms

* [Tekton](pages/devops/ci-cd-platforms/tekton/README.md)
  * [Build and Push Container Images](pages/devops/ci-cd-platforms/tekton/build-and-push-an-image-with-tekton.md)
  * [Tekton on NixOS Setup](pages/devops/ci-cd-platforms/tekton/tekton-nixos-setup.md)
* [Flagger](pages/devops/ci-cd-platforms/flagger.md)
* [Azure DevOps](pages/azure-devops/README.md)
  * [Pipelines](pages/azure-devops/pipelines/README.md)
    * [Stages](pages/azure-devops/pipelines/stages.md)
    * [Jobs](pages/azure-devops/pipelines/jobs.md)
    * [Steps](pages/azure-devops/pipelines/steps.md)
    * [Templates - Reusable pipeline components](ci-cd-platforms/azure-devops/pipelines/templates-reusable-pipeline-components.md)
    * [Extends](pages/azure-devops/pipelines/extends.md)
    * [Service Connections - External service authentication](ci-cd-platforms/azure-devops/pipelines/service-connections-external-service-authentication.md)
    * [Best Practices for 2025](pages/azure-devops/pipelines/README.md#best-practices-for-2025)
    * [Agents and Runners](pages/azure-devops/pipelines/README.md#agents-and-runners)
    * [Third-Party Integrations](pages/azure-devops/pipelines/README.md#third-party-integrations)
    * [Azure DevOps CLI](pages/azure-devops/pipelines/README.md#azure-devops-cli)
  * [Boards & Work Items](pages/devops/ci-cd-platforms/azure-devops/boards-and-work-items/README.md)
* [GitHub Actions](pages/devops/ci-cd-platforms/github/github-action.md)
  * [GitHub SecOps: DevSecOps Pipeline](pages/devops/ci-cd-platforms/github/github-secops.md)
* [GitLab](pages/devops/source-control/gitlab/README.md)
  * [GitLab Runner](pages/devops/source-control/gitlab/gitlab_runner.md)

## GitOps

* [GitOps Overview](pages/devops/gitops/README.md)
  * [Modern GitOps Practices](pages/devops/gitops/modern-practices.md)
  * [GitOps Patterns for Multi-Cloud (2025)](pages/devops/gitops/modern-gitops-patterns-2025.md)
  * [Flux](pages/devops/gitops/flux/README.md)
    * [Progressive Delivery](pages/devops/gitops/flux/progressive-delivery.md)
    * [Use GitOps with Flux, GitHub and AKS](pages/devops/gitops/flux/use-gitops-with-flux-github-and-aks-to-implement-ci-cd.md)

## Source Control

* [Source Control Overview](pages/devops/source-control/README.md)
  * [Git Branching Strategies](pages/devops/source-control/git-branching-strategies.md)
  * [Component Versioning](pages/devops/source-control/component-versioning.md)
  * [Kubernetes Manifest Versioning](pages/devops/source-control/kubernetes-manifest-versioning.md)
  * [GitLab](pages/devops/source-control/gitlab/README.md)
  * [Creating a Fork](source-control/source-control/creating-a-fork.md)
  * [Naming Branches](pages/devops/source-control/naming-branches.md)
  * [Pull Requests](source-control/source-control/pull-requests.md)
  * [Integrating LLMs into Source Control Workflows](pages/devops/source-control/llm-integration.md)

## ☁️ Cloud Platforms

* [Cloud Strategy](pages/public-clouds/README.md)
  * [AWS to Azure](pages/cloud-migration/aws-azure.md)
  * [Azure to AWS](pages/cloud-migration/azure-aws.md)
  * [GCP to Azure](pages/cloud-migration/gcp-azure.md)
  * [AWS to GCP](pages/cloud-migration/aws-gcp.md)
  * [GCP to AWS](pages/cloud-migration/gcp-aws.md)
* [Landing Zones in Public Clouds](pages/public-clouds/landing_zones/README.md)
  * [AWS Landing Zone](pages/public-clouds/landing_zones/aws-landing_zone/README.md)
  * [GCP Landing Zone](pages/public-clouds/landing_zones/gcp-landing_zone/README.md)
  * [Azure Landing Zones](pages/public-clouds/landing_zones/azure-landing-zone/README.md)
* [Azure](pages/public-clouds/azure/README.md)
  * [Best Practices](pages/public-clouds/azure/best-practise/README.md)
    * [Azure Best Practices Overview](pages/public-clouds/azure/best-practise/README.md)
    * [Azure Architecture Best Practices](pages/public-clouds/azure/best-practise/architecture-best-practises.md)
    * [Azure Naming Standards](pages/public-clouds/azure/best-practise/azure-naming-standards.md)
    * [Azure Tags](pages/public-clouds/azure/best-practise/azure-tags.md)
    * [Azure Security Best Practices](pages/public-clouds/azure/best-practise/security-best-practise.md)
  * [Services](pages/public-clouds/azure/services/README.md)
    * [Azure Active Directory (AAD)](pages/public-clouds/azure/services/aad.md)
    * [Azure Monitor](pages/public-clouds/azure/services/monitor.md)
    * [Azure Key Vault](pages/public-clouds/azure/services/key-vault.md)
    * [Azure Service Bus](pages/public-clouds/azure/services/service-bus.md)
    * [Azure DNS](pages/public-clouds/azure/services/dns.md)
    * [Azure App Service](pages/public-clouds/azure/services/app-service.md)
    * [Azure Batch](pages/public-clouds/azure/services/batch.md)
    * [Azure Machine Learning](pages/public-clouds/azure/services/machine-learning.md)
    * [Azure OpenAI Service](pages/public-clouds/azure/services/openai.md)
    * [Azure Cognitive Services](pages/public-clouds/azure/services/cognitive-services.md)
    * [Azure Kubernetes Service (AKS)](pages/public-clouds/azure/services/aks.md)
    * [Azure Databricks](pages/public-clouds/azure/services/databricks.md)
    * [Azure SQL Database](pages/public-clouds/azure/services/sql.md)
  * [Monitoring](pages/public-clouds/azure/monitoring/README.md)
  * [Administration Tools - Platform management interfaces](cloud-platforms/azure/administration-tools-platform-management-interfaces/README.md)
    * [Azure PowerShell](pages/azure-powershell/README.md)
    * [Azure CLI](pages/az-cli/README.md)
  * [Tips & Tricks](pages/public-clouds/azure/tips-and-tricks.md)
* [AWS](pages/public-clouds/aws/README.md)
  * [Authentication](pages/public-clouds/aws/authentication.md)
  * [Best Practices](pages/public-clouds/aws/best-practices.md)
  * [Tips & Tricks](pages/public-clouds/aws/tips-and-tricks.md)
  * [Services](pages/public-clouds/aws/services/README.md)
    * [AWS IAM (Identity and Access Management)](pages/public-clouds/aws/services/iam.md)
    * [Amazon CloudWatch](pages/public-clouds/aws/services/cloudwatch.md)
    * [Amazon SNS (Simple Notification Service)](pages/public-clouds/aws/services/sns.md)
    * [Amazon SQS (Simple Queue Service)](pages/public-clouds/aws/services/sqs.md)
    * [Amazon Route 53](pages/public-clouds/aws/services/route53.md)
    * [AWS Elastic Beanstalk](pages/public-clouds/aws/services/elastic-beanstalk.md)
    * [AWS Batch](pages/public-clouds/aws/services/batch.md)
    * [Amazon SageMaker](pages/public-clouds/aws/services/sagemaker.md)
    * [Amazon Bedrock](pages/public-clouds/aws/services/bedrock.md)
    * [Amazon Comprehend](pages/public-clouds/aws/services/comprehend.md)
* [Google Cloud](pages/public-clouds/gcp/README.md)
  * [Services](pages/public-clouds/gcp/services/README.md)
    * [Cloud CDN](pages/public-clouds/gcp/services/cloud-cdn.md)
    * [Cloud DNS](pages/public-clouds/gcp/services/cloud-dns.md)
    * [Cloud Load Balancing](pages/public-clouds/gcp/services/cloud-load-balancing.md)
    * [Google Kubernetes Engine (GKE)](pages/public-clouds/gcp/services/gke.md)
    * [Cloud Run](pages/public-clouds/gcp/services/cloud-run.md)
    * [Artifact Registry](pages/public-clouds/gcp/services/artifact-registry.md)
    * [Compute Engine](pages/public-clouds/gcp/services/compute-engine.md)
    * [Cloud Functions](pages/public-clouds/gcp/services/cloud-functions.md)
    * [App Engine](pages/public-clouds/gcp/services/app-engine.md)
    * [Cloud Storage](pages/public-clouds/gcp/services/cloud-storage.md)
    * [Persistent Disk](pages/public-clouds/gcp/services/persistent-disk.md)
    * [Filestore](pages/public-clouds/gcp/services/filestore.md)
    * [Cloud SQL](pages/public-clouds/gcp/services/cloud-sql.md)
    * [Cloud Spanner](cloud-platforms/gcp/services/cloud-spanner.md)
    * [Firestore](cloud-platforms/gcp/services/firestore.md)
    * [Bigtable](pages/public-clouds/gcp/services/bigtable.md)
    * [BigQuery](pages/public-clouds/gcp/services/bigquery.md)
    * [VPC (Virtual Private Cloud)](pages/public-clouds/gcp/services/vpc.md)

## 🔐 Security & Compliance

* [DevSecOps Overview](pages/security/README.md)
  * [DevSecOps Pipeline Security](pages/security/README.md)
  * [DevSecOps](pages/dev-secops/README.md)
    * [Real-life Examples](pages/dev-secops/real-life-examples.md)
    * [Scanning & Protection - Automated security tooling](security-and-compliance/security/dev-secops/scanning-and-protection-automated-security-tooling/README.md)
      * [Dependency Scanning](pages/dev-secops/dependency-and-container-scanning.md)
      * [Credential Scanning](pages/dev-secops/credential-scanning/README.md)
      * [Container Security Scanning](pages/dev-secops/container-security-scanning.md)
      * [Static Code Analysis](pages/dev-secops/static-code-analysis/README.md)
        * [Best Practices](pages/dev-secops/static-code-analysis/best-practices.md)
        * [Tool Integration Guide](pages/dev-secops/static-code-analysis/tool-integration.md)
        * [Pipeline Configuration](pages/dev-secops/static-code-analysis/pipeline-config.md)
    * [CI/CD Security](pages/dev-secops/ci-cd-security.md)
    * [Secrets Rotation](pages/dev-secops/secrets-rotation/README.md)
  * [Supply Chain Security](pages/dev-secops/supply-chain-security.md)
    * [SLSA Framework](pages/dev-secops/supply-chain-security.md#slsa-framework-implementation)
    * [Binary Authorization](pages/dev-secops/supply-chain-security.md#binary-authorization)
    * [Artifact Signing](pages/dev-secops/supply-chain-security.md#artifact-signing)
  * [Security Best Practices](pages/devops/security/README.md)
    * [Threat Modeling](pages/devops/security/threat-modeling.md)
    * [Kubernetes Security](pages/devops/security/kubernetes/README.md)
  * [SecOps](pages/secops/README.md)
  * [Zero Trust Model](pages/need-to-know/zero-trust-model/README.md)
  * [Cloud Compliance](pages/need-to-know/cloud-compliance/README.md)
    * [ISO/IEC 27001:2022](pages/need-to-know/cloud-compliance/iso-iec-27001-2022.md)
    * [ISO 22301:2019](pages/need-to-know/cloud-compliance/iso-22301-2019.md)
    * [PCI DSS](pages/need-to-know/cloud-compliance/pci-dss.md)
    * [CSA STAR](pages/need-to-know/cloud-compliance/csa-star.md)
  * [Security Frameworks](pages/need-to-know/public-cloud-security-frameworks/README.md)
  * [SIEM and SOAR](pages/need-to-know/siem-and-soar.md)

## Security Architecture

* [Zero Trust Implementation](pages/security/zero-trust/implementation-guide.md)
  * [Identity Management](pages/security/zero-trust/implementation-guide.md#identity-management)
  * [Network Security](pages/security/zero-trust/implementation-guide.md#network-security)
  * [Access Control](pages/security/zero-trust/implementation-guide.md#access-control)

## 🔍 Observability & Monitoring

* [Observability Fundamentals](pages/devops/observability/README.md)

## 🧪 Testing Strategies

* [Testing Overview](pages/devops/testing/README.md)
  * [Modern Testing Approaches](pages/need-to-know/testing/README.md)
  * [End-to-End Testing](pages/need-to-know/testing/end-to-end-testing/README.md)
  * [Unit Testing](pages/need-to-know/testing/unit-testing.md)
  * [Performance Testing](pages/devops/testing/performance-testing/README.md)
    * [Load Testing](pages/devops/testing/performance-testing/load-testing/README.md)
  * [Fault Injection Testing](pages/devops/testing/fault-injection-testing.md)
  * [Integration Testing](pages/devops/testing/integration-testing.md)
  * [Smoke Testing](pages/devops/testing/smoke-testing.md)

## 🤖 AI Integration

* [AIops Overview](pages/devops/aiops-integration.md)
  * [Workflow Automation](pages/devops/aiops-integration.md#workflow-automation)
  * [Predictive Analytics](pages/devops/aiops-integration.md#predictive-analytics)
  * [Code Quality](pages/devops/aiops-integration.md#code-quality-enhancement)

## 🧠 AI & LLM Integration

* [Overview](pages/llm/README.md)
  * [Claude](pages/llm/claude/README.md)
    * [Installation Guide](pages/llm/claude/claude-installation.md)
    * [Project Guides](pages/llm/claude/claude-project-guide.md)
    * [MCP Server Setup](pages/llm/claude/mcp-server-setup.md)
    * [LLM Comparison](pages/llm/claude/llm-modules-comparison.md)
  * [Ollama](pages/llm/ollama/README.md)
    * [Installation Guide](pages/llm/ollama/installation.md)
    * [Configuration](pages/llm/ollama/configuration.md)
    * [Models and Fine-tuning](pages/llm/ollama/models.md)
    * [DevOps Usage](pages/llm/ollama/devops-usage.md)
    * [Docker Setup](pages/llm/ollama/docker-setup.md)
    * [GPU Setup](pages/llm/ollama/gpu-setup.md)
    * [Open WebUI](pages/llm/ollama/open-webui.md)
  * [Copilot](pages/llm/copilot/README.md)
    * [Installation Guide](pages/llm/copilot/installation.md)
    * [VS Code Integration](pages/llm/copilot/vscode-integration.md)
    * [CLI Usage](pages/llm/copilot/cli-usage.md)
  * [Gemini](pages/llm/gemini/README.md)
    * [Installation Guides - Platform-specific setup](ai-and-llm-integration/llm/gemini/installation-guides-platform-specific-setup/README.md)
      * [Linux Installation](pages/llm/gemini/installation-linux.md)
      * [WSL Installation](pages/llm/gemini/installation-wsl.md)
      * [NixOS Installation](pages/llm/gemini/installation-nixos.md)
    * [Gemini 2.5 Features](pages/llm/gemini/gemini-2-5-features.md)
    * [Roles and Agents](pages/llm/gemini/roles-and-agents.md)
    * [NotebookML Guide](pages/llm/gemini/notebookml-guide.md)
    * [Cloud Infrastructure Deployment](pages/llm/gemini/cloud-infrastructure-deployment.md)
    * [Summary](pages/llm/gemini/summary.md)

## 💻 Development Environment

* [DevOps Tools](pages/devops-tools/README.md)
  * [Pulumi](pages/pulumi/README.md)
  * [Operating Systems - Development platforms](development-environment/devops-tools/operating-systems-development-platforms/README.md)
    * [NixOS](pages/Nixos/README.md)
      * [Install NixOS: PC, Mac, WSL](pages/Nixos/install.md)
      * [Nix Language Deep Dive](pages/Nixos/nix-language.md)
      * [Nix Language Fundamentals](pages/Nixos/Nix/README.md)
        * [Nix Functions and Techniques](pages/Nixos/Nix/nix-functions.md)
        * [Building Packages with Nix](pages/Nixos/Nix/building-packages.md)
        * [NixOS Configuration Patterns](pages/Nixos/Nix/nixos-patterns.md)
        * [Flakes: The Future of Nix](pages/Nixos/Nix/flakes.md)
      * [NixOS Generators: Azure & QEMU](pages/Nixos/nixos-generators-azure-qemu.md)
    * [WSL2](pages/devops/tools-to-install/wsl2/README.md)
      * [Distributions](pages/devops/tools-to-install/wsl2/rhel-in-wsl2.md)
      * [Terminal Setup](pages/devops/tools-to-install/wsl2/make-your-terminal-devops-and-kubernetes-friendly.md)
  * [Editor Environments](development-environment/devops-tools/operating-systems-development-platforms/README.md)
  * [CLI Tools](pages/should-learn/README.md)
    * [Azure CLI](pages/should-learn/az-cli/README.md)
    * [PowerShell](pages/devops/tools-to-install/powershell/README.md)
    * [Linux Commands](pages/should-learn/linux/commands/README.md)
      * [SSH - Secure Shell)](development-environment/devops-tools/should-learn/commands/ssh-secure-shell/README.md)
        * [SSH Config](pages/should-learn/linux/commands/ssh/how-to-use-ssh-config.md)
        * [SSH Port Forwarding](pages/should-learn/linux/commands/ssh/port-forwarding-and-proxying-using-openssh.md)
    * [Linux Fundametals](pages/should-learn/linux/os/README.md)
    * [Cloud init](pages/should-learn/linux/configuration/cloud-init/README.md)
      * [Cloud init examples](pages/should-learn/linux/configuration/cloud-init/cloud-init-examples.md)
    * [YAML Tools](pages/should-learn/yaml/README.md)
      * [How to create a k8s yaml file - How to create YAML config](development-environment/devops-tools/should-learn/yaml/how-to-create-a-k8s-yaml-file-how-to-create-yaml-config.md)
      * [YQ the tool](pages/should-learn/yaml/yq.md)

## 📚 Programming Languages

* [Python](pages/should-learn/python.md)
* [Go](pages/should-learn/go-lang.md)
* [JavaScript/TypeScript](pages/should-learn/README.md)
* [Java](pages/should-learn/java.md)
* [Rust](pages/should-learn/rust.md)

## Platform Engineering

* [Implementation Guide](pages/platform-engineering/implementation-guide.md)

## FinOps

* [Implementation Guide](pages/finops/implementation-guide.md)

## AIOps

* [LLMOps Guide](pages/aiops/llmops-guide.md)

## Should Learn

* [Should Learn](pages/should-learn/README.md)
* [Linux](pages/should-learn/linux.md)
  * [Commands](pages/should-learn/linux/commands/README.md)
  * [OS](pages/should-learn/linux/os/README.md)
  * [Services](pages/should-learn/linux/services/README.md)
* [Terraform](pages/terraform/README.md)
* [Getting Started - Installation and initial setup \[BEGINNER\]](should-learn/getting-started-installation-and-initial-setup-beginner.md)
* [Cloud Integrations](infrastructure-as-code-iac/terraform/cloud-integrations-provider-specific-implementations/README.md)
* [Testing and Validation - Ensuring infrastructure quality](should-learn/testing-and-validation-ensuring-infrastructure-quality/README.md)
  * [Unit Testing](pages/terraform/testing/unit-testing.md)
  * [Integration Testing](pages/terraform/testing/integration-testing.md)
  * [End-to-End Testing](pages/terraform/testing/e2e-testing.md)
  * [Terratest Guide](pages/terraform/testing/terratest.md)
* [Best Practices - Production-ready implementation strategies](should-learn/best-practices-production-ready-implementation-strategies/README.md)
  * [State Management](pages/terraform/best-practices/state-management.md)
  * [Security](pages/terraform/best-practices/security.md)
  * [Code Organization](pages/terraform/best-practices/code-organization.md)
  * [Performance](pages/terraform/best-practices/performance.md)
* [Tools & Utilities](infrastructure-as-code-iac/terraform/tools-and-utilities-enhancing-the-terraform-workflow/README.md)
* [CI/CD Integration](infrastructure-as-code-iac/terraform/ci-cd-integration-automating-infrastructure-deployment/README.md)
* [Bicep](pages/bicep/README.md)
* [Kubernetes](pages/should-learn/kubernetes/tools/README.md)
  * [kubectl](pages/should-learn/kubernetes/kubectl.md)
* [Ansible](pages/should-learn/ansible.md)
* [Puppet](pages/should-learn/puppet.md)
* [Java](pages/should-learn/java.md)
* [Rust](pages/should-learn/rust.md)
* [Azure CLI](pages/should-learn/az-cli/README.md)

## 📖 Documentation Best Practices

* [Documentation Strategy](pages/devops/documentation/README.md)
  * [Project Documentation](pages/devops/documentation/projects-and-repositories.md)
  * [Release Notes](pages/devops/documentation/create-release-notes-with-pipeline.md)
  * [Static Sites](pages/devops/documentation/how-to-create-a-static-website-for-your-documentation-based-on-mkdocs-and-mkdocs-material.md)
  * [Documentation Templates](pages/devops/documentation/templates/repository-templates.md)
  * [Real-World Examples](pages/devops/documentation/examples/real-world-examples.md)

## 📋 Reference Materials

* [Glossary](pages/reference/glossary.md)
* [Tool Comparison](pages/reference/tool-comparison.md)
* [Tool Decision Guides](pages/reference/tool-decision-guides.md)
* [Recommended Reading](pages/reference/reading.md)
* [Troubleshooting Guide](pages/reference/troubleshooting.md)
* [Development Setup](pages/development/setup.md)
