# Cloud Engineering & DevOps Knowledge Base

* [Welcome!](README.md) - Your comprehensive guide to modern DevOps practices
* [Quick Start Guide](pages/quick-starts/README.md) - Fast track to common DevOps tasks
* [About Me](pages/about-me.md) - Professional background and expertise
* [CV](pages/cv.md) - Professional experience and skills
* [Contribute](CONTRIBUTING.md) - How to contribute

## 🧠 DevOps & SRE Foundations

* [DevOps Overview](pages/devops/README.md) - Core principles for continuous delivery and reliability
  * [Engineering Fundamentals](pages/devops/engineering-fundamentals-checklist.md) - Essential skills for DevOps engineers
  * [Implementing DevOps Strategy](pages/devops/implementing-devops-strategy.md) - Planning and executing DevOps transformations
  * [DevOps Readiness Assessment](pages/devops/devops-readiness-assessment.md) - Evaluate organization readiness for DevOps
  * [Lifecycle Management](pages/need-to-know/devops-lifecycle-management.md) - Understanding the full DevOps lifecycle
  * [The 12 Factor App](pages/need-to-know/the-12-factor-app.md) - Modern application development methodology
  * [Design for Self Healing](pages/need-to-know/design-for-self-healing.md) - Building resilient systems
  * [Incident Management Best Practices (2025)](pages/devops/incident-management-best-practices-2025.md) - Modern incident handling approaches
* [SRE Fundamentals](pages/sre/README.md) - Site Reliability Engineering principles and practices
  * [Toil Reduction](pages/sre/toil.md) - Identifying and eliminating repetitive operational work
  * [System Simplicity](pages/sre/simplicity.md) - Designing and maintaining maintainable systems
  * [Real-world Scenarios](pages/sre/senarios/README.md) - Practical applications and case studies
    * [AWS VM Log Monitoring API](pages/sre/senarios/aws-vm-monitoring-api.md) - Implementing centralized logging
* [Agile Development](pages/devops/agile-development/README.md) - Iterative and collaborative methodologies
  * [Team Agreements](pages/devops/agile-development/team-agreements/README.md) - Establishing effective team norms
    * [Definition of Done](pages/devops/agile-development/team-agreements/definition-of-done.md) - Setting clear completion criteria
    * [Definition of Ready](pages/devops/agile-development/team-agreements/definition-of-ready.md) - Standardizing work intake requirements
    * [Team Manifesto](pages/devops/agile-development/team-agreements/team-manifesto.md) - Defining shared values and principles
    * [Working Agreement](pages/devops/agile-development/team-agreements/sections-of-a-working-agreement.md) - Establishing collaboration guidelines
* [Industry Scenarios](pages/devops/agile-development/senarios/README.md)
  * [Finance and Banking](pages/devops/agile-development/senarios/finance.md)
  * [Public Sector (UK/EU)](pages/devops/agile-development/senarios/public_sector.md)
  * [Energy Sector Edge Computing](pages/devops/agile-development/senarios/energy_sector.md)

## DevOps Practices

* [Platform Engineering](pages/devops/platform-engineering.md)
* [FinOps](pages/devops/finops.md)
* [Observability](pages/devops/observability/)
  * [Modern Practices](pages/devops/observability/modern-practices.md)

## 🚀 Modern DevOps Practices

* [Infrastructure Testing](pages/devops/iac-testing.md)
* [Modern Development](pages/devops/modern-development.md)
* [Database DevOps](pages/devops/database-devops.md)

## 🛠️ Infrastructure as Code (IaC)

* [Terraform](pages/terraform/README.md) - HashiCorp's multi-cloud infrastructure automation
  * [Getting Started](pages/terraform/install.md) - Installation and initial setup [BEGINNER]
  * [Cloud Integrations](pages/terraform/) - Provider-specific implementations
    * [Azure Scenarios](pages/terraform/azure-scenarios.md) - Azure resource management patterns
    * [AWS Scenarios](pages/terraform/aws-scenarios.md) - AWS deployment strategies
    * [GCP Scenarios](pages/terraform/gcp-scenarios.md) - Google Cloud automation patterns
  * [Testing and Validation](pages/terraform/testing/) - Ensuring infrastructure quality
    * [Unit Testing](pages/terraform/testing/unit-testing.md) - Testing individual resources
    * [Integration Testing](pages/terraform/testing/integration-testing.md) - Testing resource interactions
    * [End-to-End Testing](pages/terraform/testing/e2e-testing.md) - Testing complete infrastructure
    * [Terratest Guide](pages/terraform/testing/terratest.md) - Go-based testing framework
  * [Best Practices](pages/terraform/best-practices/) - Production-ready implementation strategies
    * [State Management](pages/terraform/best-practices/state-management.md) - Remote state and locking [ADVANCED]
    * [Security](pages/terraform/best-practices/security.md) - Securing infrastructure code
    * [Code Organization](pages/terraform/best-practices/code-organization.md) - Project structure and modules
    * [Performance](pages/terraform/best-practices/performance.md) - Optimizing deployment speed
  * [Tools & Utilities](pages/terraform/tools/) - Enhancing the Terraform workflow
    * [Terraform Docs](pages/terraform/tools/terraform-docs.md) - Automated documentation generation
    * [TFLint](pages/terraform/tools/tflint.md) - Static code analysis and linting
    * [Checkov](pages/terraform/tools/checkov.md) - Policy-as-code scanning
    * [Terrascan](pages/terraform/tools/terrascan.md) - Security vulnerability scanning
  * [CI/CD Integration](pages/terraform/cicd/) - Automating infrastructure deployment
    * [GitHub Actions](pages/terraform/cicd/github-actions.md) - GitHub-based automation workflows
    * [Azure Pipelines](pages/terraform/cicd/azure-pipelines.md) - Azure DevOps integration
    * [GitLab CI](pages/terraform/cicd/gitlab-ci.md) - GitLab-based deployment pipelines
* [Bicep](pages/bicep/README.md) - Azure-native infrastructure as code language
  * [Getting Started](pages/bicep/getting-started.md) - First steps with Bicep [BEGINNER]
  * [Template Specs](pages/bicep/template-spec-for-bicep.md) - Creating reusable infrastructure templates
  * [Best Practices](pages/bicep/best-practices.md) - Guidelines for effective Bicep implementations
  * [Modules](pages/bicep/modules.md) - Building reusable components [INTERMEDIATE]
  * [Examples](pages/bicep/examples.md) - Sample implementations for common scenarios
  * [Advanced Features](pages/bicep/use-inline-scripts.md) - Using inline scripts and extensions
  * [CI/CD Integration](pages/bicep/) - Automating Bicep deployments
    * [GitHub Actions](pages/bicep/bicep-with-github-actions.md) - GitHub workflow integration
    * [Azure Pipelines](pages/bicep/integrate-bicep-with-azure-pipelines.md) - Azure DevOps integration

## 💰 Cost Management & FinOps

* [Cloud Cost Optimization](pages/devops/cloud-cost-optimization.md)

## 🐳 Containers & Orchestration

* [Containerization Overview](pages/containers/README.md) - Introduction to container technology
* [Docker](pages/best-practises/containers/docker/README.md) - Container runtime and tooling
  * [Dockerfile Best Practices](pages/best-practises/containers/docker/dockerfile.md) - Efficient and secure container images
  * [Docker Compose](pages/best-practises/containers/docker/docker-compose.md) - Multi-container application management
* [Kubernetes](pages/containers/kubernetes/README.md) - Production-grade container orchestration
  * [CLI Tools](pages/containers/kubernetes/) - Essential command-line utilities
    * [Kubectl](pages/containers/kubernetes/kubectl.md) - Primary Kubernetes control tool
    * [Kubens](pages/containers/kubernetes/kubens.md) - Namespace switching utility
    * [Kubectx](pages/containers/kubernetes/kubectx.md) - Context switching utility
  * [Core Concepts](pages/need-to-know/kubernetes/kubernetes-concepts.md) - Fundamental Kubernetes architecture
  * [Components](pages/need-to-know/kubernetes/kubernetes-components.md) - Cluster building blocks
  * [Best Practices](pages/best-practises/containers/kubernetes/kubernetes-best-practices/README.md) - Production implementation guidelines
    * [Pod Security](pages/best-practises/containers/kubernetes/kubernetes-best-practices/pod-security.md)
    * [Security Monitoring](pages/best-practises/containers/kubernetes/kubernetes-best-practices/security-monitoring.md)
    * [Resource Limits](pages/best-practises/containers/kubernetes/kubernetes-best-practices/resource-limits/README.md)
  * [Advanced Features](pages/should-learn/kubernetes/) - Beyond the basics [ADVANCED]
    * [Service Mesh](pages/should-learn/kubernetes/service-mesh/README.md) - Network traffic management
    * [Ingress Controllers](pages/should-learn/kubernetes/ingress-controllers/README.md) - External access management
      * [NGINX](pages/should-learn/kubernetes/ingress-controllers/nginx.md) - NGINX-based ingress
      * [Traefik](pages/should-learn/kubernetes/ingress-controllers/traefik.md) - Cloud-native edge router
      * [Kong](pages/should-learn/kubernetes/ingress-controllers/kong.md) - API gateway implementation
      * [Gloo Edge](pages/should-learn/kubernetes/ingress-controllers/gloo-edge.md) - Next-gen API gateway
  * [Troubleshooting](pages/should-learn/kubernetes/troubleshooting/README.md) - Diagnosing and resolving common issues
    * [Pod Troubleshooting Commands](pages/should-learn/kubernetes/troubleshooting/kubernetes-pod-troubleshooting-commands.md) - Essential diagnostic tools
  * [Enterprise Architecture](pages/best-practises/containers/kubernetes/enterprise-scale-architecture.md) - Large-scale multi-cloud Kubernetes designs [ADVANCED]
  * [Health Management](pages/best-practises/containers/kubernetes/health-management.md) - Monitoring and maintaining cluster health [ADVANCED]
  * [Security & Compliance](pages/best-practises/containers/kubernetes/security-and-compliance.md) - Securing enterprise Kubernetes deployments [ADVANCED]
  * [Virtual Clusters](pages/best-practises/containers/kubernetes/vcluster.md) - Nested Kubernetes clusters for multi-tenancy
* [OpenShift](pages/best-practises/containers/openshift.md) - Red Hat's enterprise Kubernetes platform

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

## 🔄 CI/CD & GitOps

* [CI/CD Overview](pages/devops/ci-cd-platforms/README.md) - Automated build, test and deployment pipelines
* [Continuous Integration](pages/devops/continuous-integration.md) - Automating code validation and integration
* [Continuous Delivery](pages/devops/continuous-delivery/README.md) - Reliable software release automation
  * [Deployment Strategies](pages/need-to-know/guide-to-blue-green-canary-and-rolling-deployments.md) - Progressive release methods
  * [Secrets Management](pages/devops/continuous-delivery/secrets-management.md) - Securing sensitive configuration data
  * [Blue-Green Deployments](pages/devops/continuous-delivery/blue-and-green-deployment-in-real-life.md)
  * [Deployment Metrics](pages/devops/continuous-delivery/deployment-metrics.md)
  * [Progressive Delivery](pages/devops/continuous-delivery/progressive-delivery.md)
  * [Release Management for DevOps/SRE (2025)](pages/devops/continuous-delivery/release-management-2025.md) - Modern release practices and patterns
* [CI/CD Platforms](pages/devops/ci-cd-platforms/) - Tool selection and implementation
  * [Azure DevOps](pages/azure-devops/README.md) - Microsoft's comprehensive DevOps platform
    * [Pipelines](pages/azure-devops/pipelines/README.md) - YAML-based CI/CD implementation
      * [Stages](pages/azure-devops/pipelines/stages.md) - Pipeline organization units
      * [Jobs](pages/azure-devops/pipelines/jobs.md) - Execution containers
      * [Steps](pages/azure-devops/pipelines/steps.md) - Individual pipeline tasks
      * [Templates](pages/azure-devops/pipelines/templates.md) - Reusable pipeline components
      * [Extends](pages/azure-devops/pipelines/extends.md) - Template inheritance and customization
      * [Service Connections](pages/azure-devops/pipelines/service-connections.md) - External service authentication
      * [Best Practices for 2025](pages/azure-devops/pipelines/README.md#best-practices-for-2025) - Modern pipeline approaches
      * [Agents and Runners](pages/azure-devops/pipelines/README.md#agents-and-runners) - Pipeline execution environments
      * [Third-Party Integrations](pages/azure-devops/pipelines/README.md#third-party-integrations) - Extended tool integration
      * [Azure DevOps CLI](pages/azure-devops/pipelines/README.md#azure-devops-cli) - Command-line automation
    * [Boards & Work Items](pages/devops/ci-cd-platforms/azure-devops/boards-and-work-items/README.md) - Agile project management
  * [GitHub Actions](pages/devops/ci-cd-platforms/github/github-action.md) - GitHub's integrated CI/CD solution
  * [GitLab](pages/devops/source-control/gitlab/README.md)
    * [GitLab Runner](pages/devops/source-control/gitlab/gitlab_runner.md)
    * Real-life scenarios
    * Installation guides
    * Pros and Cons
    * Comparison with alternatives
* [GitOps](pages/devops/gitops/README.md)
  * [Modern GitOps Practices](pages/devops/gitops/modern-practices.md)
  * [GitOps Patterns for Multi-Cloud (2025)](pages/devops/gitops/modern-gitops-patterns-2025.md)
  * Flux
    * [Overview](pages/devops/gitops/flux/README.md)
    * [Progressive Delivery](pages/devops/gitops/flux/progressive-delivery.md)
    * [Use GitOps with Flux, GitHub and AKS](pages/devops/gitops/flux/use-gitops-with-flux-github-and-aks-to-implement-ci-cd.md)

## Source Control

* [Source Control Overview](pages/devops/source-control/README.md) - Version control fundamentals and best practices
* [Git Branching Strategies](pages/devops/source-control/git-branching-strategies.md) - Effective branching models for DevOps teams
* [Component Versioning](pages/devops/source-control/component-versioning.md) - Versioning strategies for software components
* [Kubernetes Manifest Versioning](pages/devops/source-control/kubernetes-manifest-versioning.md) - Version control for Kubernetes resources
* [GitLab](pages/devops/source-control/gitlab/README.md)
  * [GitLab Runner](pages/devops/source-control/gitlab/gitlab_runner.md)
* [Creating a Fork](pages/devops/source-control/create-fork.md)
* [Naming Branches](pages/devops/source-control/naming-branches.md)
* [Pull Requests](pages/devops/source-control/pull-request.md)
* [Integrating LLMs into Source Control Workflows](pages/devops/source-control/llm-integration.md)

## ☁️ Cloud Platforms

* [Cloud Strategy](pages/public-clouds/README.md) - Multi-cloud and platform selection guidelines
* [Azure](pages/public-clouds/azure/README.md) - Microsoft's cloud computing platform
  * [Best Practices](pages/public-clouds/azure/best-practise/README.md) - Architecture and implementation guidelines
  * [Landing Zones](pages/public-clouds/azure/azure-landing-zone/README.md) - Enterprise-scale foundation architecture
  * [Services](pages/public-clouds/azure/services/README.md) - Key platform capabilities
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
  * [Monitoring](pages/public-clouds/azure/monitoring/README.md) - Azure-native observability solutions
  * [Administration Tools](pages/public-clouds/azure/) - Platform management interfaces
    * [Azure PowerShell](pages/azure-powershell/README.md) - PowerShell-based automation
    * [Azure CLI](pages/az-cli/README.md) - Command-line management interface
  * [Tips & Tricks](pages/public-clouds/azure/tips-and-tricks.md) - Productivity enhancements
* [AWS](pages/public-clouds/aws/README.md) - Amazon's cloud platform
  * [Authentication](pages/public-clouds/aws/authentication.md) - IAM and access management
  * [Best Practices](pages/public-clouds/aws/best-practices.md) - Well-Architected implementation guidance
  * [Tips & Tricks](pages/public-clouds/aws/tips-and-tricks.md) - Efficiency improvements
  * [Services](pages/public-clouds/aws/services/README.md) - Key platform offerings
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
* [Google Cloud](pages/public-clouds/gcp/README.md) - Google's cloud platform
  * [Services](pages/public-clouds/gcp/services/README.md) - Key platform offerings
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
    * [Cloud Spanner](pages/public-clouds/gcp/services/cloud-spanner.md)
    * [Firestore](pages/public-clouds/gcp/services/firestore.md)
    * [Bigtable](pages/public-clouds/gcp/services/bigtable.md)
    * [BigQuery](pages/public-clouds/gcp/services/bigquery.md)
    * [VPC (Virtual Private Cloud)](pages/public-clouds/gcp/services/vpc.md)

## 🔐 Security & Compliance

* [DevSecOps Overview](pages/security/README.md) - Security throughout the delivery pipeline
* [DevSecOps Pipeline Security](pages/security/README.md) - Comprehensive pipeline security guide
* [DevSecOps](pages/dev-secops/README.md) - Security-integrated development practices
  * [Real-life Examples](pages/dev-secops/real-life-examples.md) - Implementation case studies
  * [Scanning & Protection](pages/dev-secops/) - Automated security tooling
    * [Dependency Scanning](pages/dev-secops/dependency-and-container-scanning.md) - Supply chain security
    * [Credential Scanning](pages/dev-secops/credential-scanning/README.md) - Secret detection and prevention
    * [Container Security Scanning](pages/dev-secops/container-security-scanning.md) - Container image analysis
    * [Static Code Analysis](pages/dev-secops/static-code-analysis/README.md) - Code quality and security
      * [Best Practices](pages/dev-secops/static-code-analysis/best-practices.md) - Effective implementation
      * [Tool Integration Guide](pages/dev-secops/static-code-analysis/tool-integration.md) - Setup instructions
      * [Pipeline Configuration](pages/dev-secops/static-code-analysis/pipeline-config.md) - CI/CD integration
  * [CI/CD Security](pages/dev-secops/ci-cd-security.md) - Securing the deployment pipeline
  * [Secrets Rotation](pages/dev-secops/secrets-rotation/README.md) - Automated credential management
* [Supply Chain Security](pages/dev-secops/supply-chain-security.md)
  * [SLSA Framework](pages/dev-secops/supply-chain-security.md#slsa-framework-implementation)
  * [Binary Authorization](pages/dev-secops/supply-chain-security.md#binary-authorization)
  * [Artifact Signing](pages/dev-secops/supply-chain-security.md#artifact-signing)
* [Security Best Practices](pages/devops/security/README.md) - Holistic security guidelines
  * [Threat Modeling](pages/devops/security/threat-modeling.md) - Structured risk assessment
  * [Kubernetes Security](pages/devops/security/kubernetes/README.md) - Container platform hardening
* [SecOps](pages/secops/README.md) - Security operations and management
* [Zero Trust Model](pages/need-to-know/zero-trust-model/README.md) - Modern security architecture
* [Cloud Compliance](pages/need-to-know/cloud-compliance/README.md) - Regulatory frameworks and standards
  * [ISO/IEC 27001:2022](pages/need-to-know/cloud-compliance/iso-iec-27001-2022.md) - Information security management
  * [ISO 22301:2019](pages/need-to-know/cloud-compliance/iso-22301-2019.md) - Business continuity planning
  * [PCI DSS](pages/need-to-know/cloud-compliance/pci-dss.md) - Payment card industry compliance
  * [CSA STAR](pages/need-to-know/cloud-compliance/csa-star.md) - Cloud security certification
* [Security Frameworks](pages/need-to-know/public-cloud-security-frameworks/README.md) - Implementation methodologies
* [SIEM and SOAR](pages/need-to-know/siem-and-soar.md) - Security monitoring and automation

## Security Architecture

* [Zero Trust Implementation](pages/security/zero-trust/implementation-guide.md)
  * [Identity Management](pages/security/zero-trust/implementation-guide.md#identity-management)
  * [Network Security](pages/security/zero-trust/implementation-guide.md#network-security)
  * [Access Control](pages/security/zero-trust/implementation-guide.md#access-control)

## 🔍 Observability & Monitoring

* [Observability Fundamentals](pages/devops/observability/README.md) - Unified monitoring approach
* [Logging](pages/devops/observability/logging/README.md) - Log collection and analysis strategies
* [Metrics](pages/devops/observability/metrics.md) - Quantitative system measurements
* [Tracing](pages/devops/observability/tracing.md) - Distributed transaction monitoring
* [Dashboards](pages/devops/observability/dashboard.md) - Visualization and reporting
* [SLOs and SLAs](pages/need-to-know/understanding-sli-slo-and-sla.md) - Service level objectives and agreements
* [Observability as Code](pages/devops/observability/observability-as-code.md) - Automated monitoring setup
* [Pipeline Observability](pages/devops/observability/observability-of-ci-cd-pipelines.md) - CI/CD process insights

## 🧪 Testing Strategies

* [Testing Overview](pages/devops/testing/README.md) - Comprehensive quality assurance approach
* [Modern Testing Approaches](pages/need-to-know/testing/README.md) - Cloud-native validation techniques
* [End-to-End Testing](pages/need-to-know/testing/end-to-end-testing/README.md) - Complete system validation
* [Unit Testing](pages/need-to-know/testing/unit-testing.md) - Component-level verification
* [Performance Testing](pages/devops/testing/performance-testing/README.md) - System capability assessment
  * [Load Testing](pages/devops/testing/performance-testing/load-testing/README.md) - Capacity verification
* [Fault Injection Testing](pages/devops/testing/fault-injection-testing.md) - Chaos engineering practice
* [Integration Testing](pages/devops/testing/integration-testing.md) - Component interaction validation
* [Smoke Testing](pages/devops/testing/smoke-testing.md) - Basic functionality verification

## 🤖 AI Integration

* [AIops Overview](pages/devops/aiops-integration.md)
  * [Workflow Automation](pages/devops/aiops-integration.md#workflow-automation)
  * [Predictive Analytics](pages/devops/aiops-integration.md#predictive-analytics)
  * [Code Quality](pages/devops/aiops-integration.md#code-quality-enhancement)

## 🧠 AI & LLM Integration

* [Overview](pages/llm/README.md) - AI applications in DevOps workflows
* [Claude](pages/llm/claude/README.md) - Anthropic's large language model
  * [Installation Guide](pages/llm/claude/claude-installation.md) - Setup and configuration
  * [Project Guides](pages/llm/claude/claude-project-guide.md) - Implementation strategies
  * [MCP Server Setup](pages/llm/claude/mcp-server-setup.md) - Multi-Claude Protocol implementation
  * [LLM Comparison](pages/llm/claude/llm-modules-comparison.md) - Feature and capability analysis
* [Ollama](pages/llm/ollama/README.md) - Local LLM deployment solution
  * [Installation Guide](pages/llm/ollama/installation.md) - Platform-specific setup
  * [Configuration](pages/llm/ollama/configuration.md) - Customization and optimization
  * [Models and Fine-tuning](pages/llm/ollama/models.md) - Available model options
  * [DevOps Usage](pages/llm/ollama/devops-usage.md) - Automation integrations
  * [Docker Setup](pages/llm/ollama/docker-setup.md) - Containerized deployment
  * [GPU Setup](pages/llm/ollama/gpu-setup.md) - Hardware acceleration configuration
  * [Open WebUI](pages/llm/ollama/open-webui.md) - Browser-based interface
* [Copilot](pages/llm/copilot/README.md) - GitHub's AI programming assistant
  * [Installation Guide](pages/llm/copilot/installation.md) - Setup and licensing
  * [VS Code Integration](pages/llm/copilot/vscode-integration.md) - Editor productivity features
  * [CLI Usage](pages/llm/copilot/cli-usage.md) - Command-line capabilities
* [Gemini](pages/llm/gemini/README.md) - Google's multimodal AI model
  * [Installation Guides](pages/llm/gemini/) - Platform-specific setup
    * [Linux Installation](pages/llm/gemini/installation-linux.md) - Standard Linux deployment
    * [WSL Installation](pages/llm/gemini/installation-wsl.md) - Windows Subsystem for Linux setup
    * [NixOS Installation](pages/llm/gemini/installation-nixos.md) - NixOS package configuration
  * [Gemini 2.5 Features](pages/llm/gemini/gemini-2-5-features.md) - Latest model capabilities
  * [Roles and Agents](pages/llm/gemini/roles-and-agents.md) - Specialized assistants
  * [NotebookML Guide](pages/llm/gemini/notebookml-guide.md) - Jupyter integration
  * [Cloud Infrastructure Deployment](pages/llm/gemini/cloud-infrastructure-deployment.md) - Production implementation
  * [Summary](pages/llm/gemini/summary.md) - Key takeaways and best practices

## 💻 Development Environment

* [Tools Overview](pages/devops/tools-to-install/README.md) - Essential development utilities
* [DevOps Tools](pages/devops-tools/README.md) - Specialized engineering tools
* [Operating Systems](pages/devops/tools-to-install/) - Development platforms
  * [NixOS](pages/Nixos/README.md) - Declarative Linux distribution
    * [Install NixOS: PC, Mac, WSL](pages/Nixos/install.md)
    * [Nix Language Deep Dive](pages/Nixos/nix-language.md)
    * [Nix Language Fundamentals](pages/Nixos/Nix/README.md) - Core concepts of the Nix language
      * [Nix Functions and Techniques](pages/Nixos/Nix/nix-functions.md) - Advanced function patterns
      * [Building Packages with Nix](pages/Nixos/Nix/building-packages.md) - Package creation guide
      * [NixOS Configuration Patterns](pages/Nixos/Nix/nixos-patterns.md) - System architecture patterns
      * [Flakes: The Future of Nix](pages/Nixos/Nix/flakes.md) - Next-gen dependency management
    * [NixOS Generators: Azure & QEMU](pages/Nixos/nixos-generators-azure-qemu.md)
  * [WSL2](pages/devops/tools-to-install/wsl2/README.md) - Windows Subsystem for Linux
    * [Distributions](pages/devops/tools-to-install/wsl2/rhel-in-wsl2.md) - Linux variants for WSL
    * [Terminal Setup](pages/devops/tools-to-install/wsl2/make-your-terminal-devops-and-kubernetes-friendly.md) - CLI environment optimization
* [Editor Environments](pages/devops/tools-to-install/) - Code editing tools
  * [VS Code](pages/devops/tools-to-install/visual-studio-code.md) - Microsoft's extensible editor
  * [LunarVim](pages/devops/tools-to-install/lunarvim/README.md) - Neovim-based IDE
* [CLI Tools](pages/should-learn/README.md) - Command-line utilities
  * [Azure CLI](pages/should-learn/az-cli/README.md) - Azure resource management
  * [PowerShell](pages/devops/tools-to-install/powershell/README.md) - Cross-platform automation shell
  * [Linux Commands](pages/should-learn/linux/commands/README.md) - Essential command-line operations
  * [YAML Tools](pages/should-learn/yaml/README.md) - Configuration file manipulation

## 📚 Programming Languages

* [Python](pages/should-learn/python.md) - Versatile scripting and application development
* [Go](pages/should-learn/go-lang.md) - Cloud-native systems programming
* [JavaScript/TypeScript](pages/should-learn/README.md) - Web and automation scripting
* [Java](pages/should-learn/java.md) - Enterprise application development
* [Rust](pages/should-learn/rust.md) - High-performance systems programming

## 📖 Documentation Best Practices

* [Documentation Strategy](pages/devops/documentation/README.md) - Comprehensive documentation approach
* [Project Documentation](pages/devops/documentation/projects-and-repositories.md) - Repository-level documentation
* [Release Notes](pages/devops/documentation/create-release-notes-with-pipeline.md) - Automated change documentation
* [Static Sites](pages/devops/documentation/how-to-create-a-static-website-for-your-documentation-based-on-mkdocs-and-mkdocs-material.md) - Documentation portal creation
* [Documentation Templates](pages/devops/documentation/templates/repository-templates.md)
* [Real-World Examples](pages/devops/documentation/examples/real-world-examples.md)

## 📋 Reference Materials

* [Glossary](pages/reference/glossary.md) - DevOps and cloud terminology
* [Tool Comparison](pages/reference/tool-comparison.md) - Feature analysis of DevOps tools
* [Tool Decision Guides](pages/reference/tool-decision-guides.md) - Decision trees and migration guides for tool selection
* [Recommended Reading](pages/reference/reading.md) - Essential books and resources
* [Troubleshooting Guide](pages/reference/troubleshooting.md) - Advanced issue resolution for DevOps/SRE

## Platform Engineering

* [Implementation Guide](pages/platform-engineering/implementation-guide.md)

## FinOps

* [Implementation Guide](pages/finops/implementation-guide.md)

## AIOps

* [LLMOps Guide](pages/aiops/llmops-guide.md)

## Development Setup

* [Development Setup](pages/development/setup.md)

## Should Learn

* [Should Learn](pages/should-learn/README.md)
  * [Linux](pages/should-learn/linux.md)
    * [Commands](pages/should-learn/linux/commands/README.md)
    * [OS](pages/should-learn/linux/os/README.md)
      * [Bash Shortcuts Every Linux User Needs to Know](pages/should-learn/linux/os/how-to-avoid-multiple-sudo-commands-in-one-liners/bash-shortcuts-every-linux-user-needs-to-know.md)
    * [Services](pages/should-learn/linux/services/README.md)
  * [Terraform](pages/terraform/README.md) - HashiCorp's multi-cloud infrastructure automation
  * [Getting Started](pages/terraform/install.md) - Installation and initial setup [BEGINNER]
  * [Cloud Integrations](pages/terraform/) - Provider-specific implementations
    * [Azure Scenarios](pages/terraform/azure-scenarios.md) - Azure resource management patterns
    * [AWS Scenarios](pages/terraform/aws-scenarios.md) - AWS deployment strategies
    * [GCP Scenarios](pages/terraform/gcp-scenarios.md) - Google Cloud automation patterns
  * [Testing and Validation](pages/terraform/testing/) - Ensuring infrastructure quality
    * [Unit Testing](pages/terraform/testing/unit-testing.md) - Testing individual resources
    * [Integration Testing](pages/terraform/testing/integration-testing.md) - Testing resource interactions
    * [End-to-End Testing](pages/terraform/testing/e2e-testing.md) - Testing complete infrastructure
    * [Terratest Guide](pages/terraform/testing/terratest.md) - Go-based testing framework
  * [Best Practices](pages/terraform/best-practices/) - Production-ready implementation strategies
    * [State Management](pages/terraform/best-practices/state-management.md) - Remote state and locking [ADVANCED]
    * [Security](pages/terraform/best-practices/security.md) - Securing infrastructure code
    * [Code Organization](pages/terraform/best-practices/code-organization.md) - Project structure and modules
    * [Performance](pages/terraform/best-practices/performance.md) - Optimizing deployment speed
  * [Tools & Utilities](pages/terraform/tools/) - Enhancing the Terraform workflow
    * [Terraform Docs](pages/terraform/tools/terraform-docs.md) - Automated documentation generation
    * [TFLint](pages/terraform/tools/tflint.md) - Static code analysis and linting
    * [Checkov](pages/terraform/tools/checkov.md) - Policy-as-code scanning
    * [Terrascan](pages/terraform/tools/terrascan.md) - Security vulnerability scanning
  * [CI/CD Integration](pages/terraform/cicd/) - Automating infrastructure deployment
    * [GitHub Actions](pages/terraform/cicd/github-actions.md) - GitHub-based automation workflows
    * [Azure Pipelines](pages/terraform/cicd/azure-pipelines.md) - Azure DevOps integration
    * [GitLab CI](pages/terraform/cicd/gitlab-ci.md) - GitLab-based deployment pipelines
  * [Bicep](pages/bicep/README.md) - Azure-native infrastructure as code language
    * [Getting Started](pages/bicep/getting-started.md) - First steps with Bicep [BEGINNER]
    * [Template Specs](pages/bicep/template-spec-for-bicep.md) - Creating reusable infrastructure templates
    * [Best Practices](pages/bicep/best-practices.md) - Guidelines for effective Bicep implementations
    * [Modules](pages/bicep/modules.md) - Building reusable components [INTERMEDIATE]
    * [Examples](pages/bicep/examples.md) - Sample implementations for common scenarios
    * [Advanced Features](pages/bicep/use-inline-scripts.md) - Using inline scripts and extensions
    * [CI/CD Integration](pages/bicep/) - Automating Bicep deployments
      * [GitHub Actions](pages/bicep/bicep-with-github-actions.md) - GitHub workflow integration
      * [Azure Pipelines](pages/bicep/integrate-bicep-with-azure-pipelines.md) - Azure DevOps integration
  * [Kubernetes](pages/should-learn/kubernetes/tools/README.md)
    * [kubectl](pages/should-learn/kubernetes/kubectl.md)
  * [Ansible](pages/should-learn/ansible.md)
  * [Puppet](pages/should-learn/puppet.md)
  * [Java](pages/should-learn/java.md)
  * [Rust](pages/should-learn/rust.md)
  * [Azure CLI](pages/should-learn/az-cli/README.md)

## Cloud Migration

* [AWS to Azure](pages/cloud-migration/aws-azure.md)
* [Azure to AWS](pages/cloud-migration/azure-aws.md)
* [GCP to Azure](pages/cloud-migration/gcp-azure.md)
* [AWS to GCP](pages/cloud-migration/aws-gcp.md)
* [GCP to AWS](pages/cloud-migration/gcp-aws.md)
