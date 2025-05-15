# Cloud Engineering & DevOps Knowledge Base

* [Welcome!](README.md) - Introduction to this knowledge resource
* [About Me](pages/about-me.md) - Professional background and expertise
* [CV](pages/cv.md) - Professional experience and skills

## 🧠 DevOps & SRE Foundations

* [DevOps Overview](pages/devops/README.md) - Core DevOps principles and practices
  * [Engineering Fundamentals](pages/devops/engineering-fundamentals-checklist.md) - Essential skills for DevOps engineers
  * [Implementing DevOps Strategy](pages/devops/implementing-devops-strategy.md) - Planning and executing DevOps transformations
  * [DevOps Readiness Assessment](pages/devops/devops-readiness-assessment.md) - Evaluate organization readiness for DevOps
  * [Lifecycle Management](pages/need-to-know/devops-lifecycle-management.md) - Understanding the full DevOps lifecycle
  * [The 12 Factor App](pages/need-to-know/the-12-factor-app.md) - Modern application development methodology
  * [Design for Self Healing](pages/need-to-know/design-for-self-healing.md) - Building resilient systems
  * [Incident Management Best Practices (2025)](pages/devops/incident-management-best-practices-2025.md) - Modern incident handling approaches
* [SRE Fundamentals](pages/sre/README.md) - Site Reliability Engineering principles
  * [Toil Reduction](pages/sre/toil.md) - Eliminating manual, repetitive work
  * [System Simplicity](pages/sre/simplicity.md) - Building maintainable systems
  * [Real-world Scenarios](pages/sre/senarios/README.md) - Practical applications of SRE
    * [AWS VM Log Monitoring API](pages/sre/senarios/aws-vm-monitoring-api.md) - Implementation example
* [Agile Development](pages/devops/agile-development/README.md) - Agile methodologies and practices
  * [Team Agreements](pages/devops/agile-development/team-agreements/README.md) - Establishing team norms
    * [Definition of Done](pages/devops/agile-development/team-agreements/definition-of-done.md) - Clear completion criteria
    * [Definition of Ready](pages/devops/agile-development/team-agreements/definition-of-ready.md) - Work intake standards
    * [Team Manifesto](pages/devops/agile-development/team-agreements/team-manifesto.md) - Team values and principles
    * [Working Agreement](pages/devops/agile-development/team-agreements/sections-of-a-working-agreement.md) - Collaboration guidelines

## 🛠️ Infrastructure as Code (IaC)

* [Terraform](pages/terraform/README.md) - Multi-cloud infrastructure automation
  * [Getting Started](pages/terraform/install.md) - Installation and initial setup
  * [Cloud Integrations](pages/terraform/) - Provider-specific implementations
    * [Azure Scenarios](pages/terraform/azure-scenarios.md) - Azure resource deployment patterns
    * [AWS Scenarios](pages/terraform/aws-scenarios.md) - AWS resource deployment patterns
    * [GCP Scenarios](pages/terraform/gcp-scenarios.md) - Google Cloud deployment patterns
  * [Testing and Validation](pages/terraform/testing/) - Ensuring infrastructure quality
    * [Unit Testing](pages/terraform/testing/unit-testing.md) - Testing individual resources
    * [Integration Testing](pages/terraform/testing/integration-testing.md) - Testing resource interactions
    * [End-to-End Testing](pages/terraform/testing/e2e-testing.md) - Testing complete infrastructure
    * [Terratest Guide](pages/terraform/testing/terratest.md) - Go-based testing framework
  * [Best Practices](pages/terraform/best-practices/) - Recommended implementation approaches
    * [State Management](pages/terraform/best-practices/state-management.md) - Handling Terraform state
    * [Security](pages/terraform/best-practices/security.md) - Securing infrastructure code
    * [Code Organization](pages/terraform/best-practices/code-organization.md) - Structure for maintainability
    * [Performance](pages/terraform/best-practices/performance.md) - Optimizing Terraform runs
  * [Tools & Utilities](pages/terraform/tools/) - Enhancing the Terraform workflow
    * [Terraform Docs](pages/terraform/tools/terraform-docs.md) - Automated documentation
    * [TFLint](pages/terraform/tools/tflint.md) - Static code analysis
    * [Checkov](pages/terraform/tools/checkov.md) - Security & compliance scanning
    * [Terrascan](pages/terraform/tools/terrascan.md) - Vulnerability scanning
  * [CI/CD Integration](pages/terraform/cicd/) - Automation with CI/CD platforms
    * [GitHub Actions](pages/terraform/cicd/github-actions.md) - GitHub-based automation
    * [Azure Pipelines](pages/terraform/cicd/azure-pipelines.md) - Azure DevOps automation
    * [GitLab CI](pages/terraform/cicd/gitlab-ci.md) - GitLab-based automation
* [Bicep](group-1/bicep/README.md) - Azure-native infrastructure as code
  * [Getting Started](group-1/bicep/getting-started.md) - First steps with Bicep
  * [Template Specs](group-1/bicep/template-spec-for-bicep.md) - Reusable infrastructure templates 
  * [Best Practices](group-1/bicep/best-practices.md) - Guidelines for effective Bicep usage
  * [Modules](group-1/bicep/modules.md) - Creating reusable components
  * [Examples](group-1/bicep/examples.md) - Sample implementations
  * [Advanced Features](group-1/bicep/use-inline-scripts.md) - Using inline scripts with Bicep
  * [CI/CD Integration](group-1/bicep/) - Automation workflows
    * [GitHub Actions](group-1/bicep/bicep-with-github-actions.md) - GitHub workflow integration
    * [Azure Pipelines](group-1/bicep/integrate-bicep-with-azure-pipelines.md) - Azure DevOps integration

## 🐳 Containers & Orchestration

* [Docker](pages/best-practises/containers/docker/README.md) - Container technology fundamentals
  * [Dockerfile Best Practices](pages/best-practises/containers/docker/dockerfile.md) - Optimizing container builds
  * [Docker Compose](pages/best-practises/containers/docker/docker-compose.md) - Multi-container applications
* [Kubernetes](pages/containers/kubernetes/README.md) - Container orchestration platform
  * [CLI Tools](pages/containers/kubernetes/) - Essential command-line utilities
    * [Kubectl](pages/containers/kubernetes/kubectl.md) - Primary Kubernetes CLI
    * [Kubens](pages/containers/kubernetes/kubens.md) - Namespace switching utility
    * [Kubectx](pages/containers/kubernetes/kubectx.md) - Context switching utility
  * [Core Concepts](pages/need-to-know/kubernetes/kubernetes-concepts.md) - Fundamental Kubernetes principles
  * [Components](pages/need-to-know/kubernetes/kubernetes-components.md) - Kubernetes architecture
  * [Best Practices](pages/best-practises/containers/kubernetes/kubernetes-best-practices/README.md) - Recommended approaches
  * [Advanced Features](pages/should-learn/kubernetes/) - Beyond the basics
    * [Service Mesh](pages/should-learn/kubernetes/service-mesh/README.md) - Service-to-service communication
    * [Ingress Controllers](pages/should-learn/kubernetes/ingress-controllers/README.md) - Managing external access
      * [NGINX](pages/should-learn/kubernetes/ingress-controllers/nginx.md) - NGINX-based ingress
      * [Traefik](pages/should-learn/kubernetes/ingress-controllers/traefik.md) - Traefik ingress controller
      * [Kong](pages/should-learn/kubernetes/ingress-controllers/kong.md) - Kong API gateway
      * [Gloo Edge](pages/should-learn/kubernetes/ingress-controllers/gloo-edge.md) - API gateway
  * [Troubleshooting](pages/should-learn/kubernetes/troubleshooting/README.md) - Diagnosing and fixing issues
    * [Pod Troubleshooting Commands](pages/should-learn/kubernetes/troubleshooting/kubernetes-pod-troubleshooting-commands.md) - Diagnostic tools
* [OpenShift](pages/best-practises/containers/openshift.md) - Enterprise Kubernetes platform

## 🔄 CI/CD & GitOps

* [CI/CD Overview](pages/devops/ci-cd-platforms/README.md) - Continuous integration and delivery concepts
* [Continuous Integration](pages/devops/continuous-integration.md) - Automating code integration and testing
* [Continuous Delivery](pages/devops/continuous-delivery/README.md) - Reliable software release processes
  * [Deployment Strategies](pages/need-to-know/guide-to-blue-green-canary-and-rolling-deployments.md) - Progressive deployment methods
  * [Secrets Management](pages/devops/continuous-delivery/secrets-management.md) - Managing sensitive information
* [CI/CD Platforms](pages/devops/ci-cd-platforms/) - Implementation options
  * [Azure DevOps](pages/azure-devops/README.md) - Microsoft's DevOps platform
    * [Pipelines](pages/azure-devops/pipelines/README.md) - CI/CD implementation
      * [Stages](pages/azure-devops/pipelines/stages.md) - Pipeline organization
      * [Jobs](pages/azure-devops/pipelines/jobs.md) - Execution units
      * [Steps](pages/azure-devops/pipelines/steps.md) - Individual tasks
      * [Templates](pages/azure-devops/pipelines/templates.md) - Reusable configurations
      * [Extends](pages/azure-devops/pipelines/extends.md) - Template inheritance
      * [Service Connections](pages/azure-devops/pipelines/service-connections.md) - External integrations
      * [Best Practices for 2025](pages/azure-devops/pipelines/README.md#best-practices-for-2025) - Modern approaches
      * [Agents and Runners](pages/azure-devops/pipelines/README.md#agents-and-runners) - Execution environments
      * [Third-Party Integrations](pages/azure-devops/pipelines/README.md#third-party-integrations) - Ecosystem connections
      * [Azure DevOps CLI](pages/azure-devops/pipelines/README.md#azure-devops-cli) - Command-line automation
    * [Boards & Work Items](pages/devops/ci-cd-platforms/azure-devops/boards-and-work-items/README.md) - Project management
  * [GitHub Actions](pages/devops/ci-cd-platforms/github/github-action.md) - GitHub's CI/CD solution
* [GitOps](pages/devops/gitops/README.md) - Git-centric infrastructure automation
  * [Flux](pages/devops/gitops/flux/README.md) - CNCF GitOps tool
  * [ArgoCD](pages/devops/ci-cd-platforms/argo-cd/README.md) - Declarative GitOps CD tool

## ☁️ Cloud Platforms

* [Cloud Strategy](pages/public-clouds/README.md) - Multi-cloud approach and considerations
* [Azure](pages/public-clouds/azure/README.md) - Microsoft Azure platform
  * [Best Practices](pages/public-clouds/azure/best-practise/README.md) - Recommended approaches
  * [Landing Zones](pages/public-clouds/azure/azure-landing-zone/README.md) - Enterprise-scale foundations
  * [Services](pages/public-clouds/azure/services/README.md) - Key Azure offerings
  * [Monitoring](pages/public-clouds/azure/monitoring/README.md) - Observability solutions
  * [Administration Tools](pages/public-clouds/azure/) - Management interfaces
    * [Azure PowerShell](pages/azure-powershell/README.md) - PowerShell automation
    * [Azure CLI](pages/az-cli/README.md) - Command-line interface
  * [Tips & Tricks](pages/public-clouds/azure/tips-and-tricks.md) - Productivity enhancers
* [AWS](pages/public-clouds/aws/README.md) - Amazon Web Services platform
  * [Authentication](pages/public-clouds/aws/authentication.md) - Access management
  * [Best Practices](pages/public-clouds/aws/best-practices.md) - Recommended approaches
  * [Tips & Tricks](pages/public-clouds/aws/tips-and-tricks.md) - Productivity enhancers
* [Google Cloud](pages/public-clouds/gcp/README.md) - Google Cloud Platform
  * [Services](pages/public-clouds/gcp/services/README.md) - Key GCP offerings
* [Private Cloud](pages/private-cloud.md) - On-premises implementations

## 🔐 Security & Compliance

* [DevSecOps](pages/dev-secops/README.md) - Security-integrated development
  * [Real-life Examples](pages/dev-secops/real-life-examples.md) - Case studies and implementations
  * [Scanning & Protection](pages/dev-secops/) - Automated security controls
    * [Dependency Scanning](pages/dev-secops/dependency-and-container-scanning.md) - Software supply chain security
    * [Credential Scanning](pages/dev-secops/credential-scanning/README.md) - Preventing secret leaks
    * [Container Security Scanning](pages/dev-secops/container-security-scanning.md) - Container vulnerabilities
    * [Static Code Analysis](pages/dev-secops/static-code-analysis/README.md) - Code quality and security
      * [Best Practices](pages/dev-secops/static-code-analysis/best-practices.md) - Effective implementation
      * [Tool Integration Guide](pages/dev-secops/static-code-analysis/tool-integration.md) - Setup instructions
      * [Pipeline Configuration](pages/dev-secops/static-code-analysis/pipeline-config.md) - Automation examples
  * [CI/CD Security](pages/dev-secops/ci-cd-security.md) - Pipeline security controls
  * [Secrets Rotation](pages/dev-secops/secrets-rotation/README.md) - Managing sensitive credentials
* [Security Best Practices](pages/devops/security/README.md) - General security guidelines
  * [Threat Modeling](pages/devops/security/threat-modeling.md) - Identifying security risks
  * [Kubernetes Security](pages/devops/security/kubernetes/README.md) - Container orchestration security
* [SecOps](pages/secops/README.md) - Security operations
* [Zero Trust Model](pages/need-to-know/zero-trust-model/README.md) - Modern security architecture
* [Cloud Compliance](pages/need-to-know/cloud-compliance/README.md) - Regulatory frameworks
  * [ISO/IEC 27001:2022](pages/need-to-know/cloud-compliance/iso-iec-27001-2022.md) - Information security standard
  * [ISO 22301:2019](pages/need-to-know/cloud-compliance/iso-22301-2019.md) - Business continuity
  * [PCI DSS](pages/need-to-know/cloud-compliance/pci-dss.md) - Payment card security
  * [CSA STAR](pages/need-to-know/cloud-compliance/csa-star.md) - Cloud security assurance
* [Security Frameworks](pages/need-to-know/public-cloud-security-frameworks/README.md) - Structured approaches
* [SIEM and SOAR](pages/need-to-know/siem-and-soar.md) - Security monitoring and response

## 🔍 Observability & Monitoring

* [Observability Fundamentals](pages/devops/observability/README.md) - Core monitoring concepts
* [Logging](pages/devops/observability/logging/README.md) - Log collection and analysis
* [Metrics](pages/devops/observability/metrics.md) - Quantitative measurement
* [Tracing](pages/devops/observability/tracing.md) - Request flow visualization
* [Dashboards](pages/devops/observability/dashboard.md) - Data visualization
* [SLOs and SLAs](pages/need-to-know/understanding-sli-slo-and-sla.md) - Performance objectives
* [Observability as Code](pages/devops/observability/observability-as-code.md) - Automated monitoring
* [Pipeline Observability](pages/devops/observability/observability-of-ci-cd-pipelines.md) - CI/CD insights

## 🧪 Testing Strategies

* [Testing Overview](pages/devops/testing/README.md) - Comprehensive testing approach
* [Modern Testing Approaches](pages/need-to-know/testing/README.md) - Cloud-native testing
* [End-to-End Testing](pages/need-to-know/testing/end-to-end-testing/README.md) - Complete system validation
* [Unit Testing](pages/need-to-know/testing/unit-testing.md) - Component-level validation
* [Performance Testing](pages/devops/testing/performance-testing/README.md) - System capability measurement
  * [Load Testing](pages/devops/testing/performance-testing/load-testing/README.md) - Capacity assessment
* [Fault Injection Testing](pages/devops/testing/fault-injection-testing.md) - Resilience verification
* [Integration Testing](pages/devops/testing/integration-testing.md) - Component interaction testing
* [Smoke Testing](pages/devops/testing/smoke-testing.md) - Basic functionality verification

## 🧠 AI & LLM Integration

* [Overview](pages/llm/README.md) - AI in DevOps introduction
* [Claude](pages/llm/claude/README.md) - Anthropic's AI assistant
  * [Installation Guide](pages/llm/claude/claude-installation.md) - Setup instructions
  * [Project Guides](pages/llm/claude/claude-project-guide.md) - Implementation patterns
  * [MCP Server Setup](pages/llm/claude/mcp-server-setup.md) - Multi-Claude Protocol
  * [LLM Comparison](pages/llm/claude/llm-modules-comparison.md) - Model capabilities analysis
* [Ollama](pages/llm/ollama/README.md) - Local LLM runner
  * [Installation Guide](pages/llm/ollama/installation.md) - Setup instructions
  * [Configuration](pages/llm/ollama/configuration.md) - Customization options
  * [Models and Fine-tuning](pages/llm/ollama/models.md) - Available models
  * [DevOps Usage](pages/llm/ollama/devops-usage.md) - Automation applications
  * [Docker Setup](pages/llm/ollama/docker-setup.md) - Containerized deployment
  * [GPU Setup](pages/llm/ollama/gpu-setup.md) - Hardware acceleration
  * [Open WebUI](pages/llm/ollama/open-webui.md) - Browser interface
* [Copilot](pages/llm/copilot/README.md) - GitHub's AI assistant
  * [Installation Guide](pages/llm/copilot/installation.md) - Setup instructions
  * [VS Code Integration](pages/llm/copilot/vscode-integration.md) - Editor integration
  * [CLI Usage](pages/llm/copilot/cli-usage.md) - Command-line features
* [Gemini](pages/llm/gemini/README.md) - Google's AI model
  * [Installation Guides](pages/llm/gemini/) - Platform-specific setup
    * [Linux Installation](pages/llm/gemini/installation-linux.md) - Standard Linux setup
    * [WSL Installation](pages/llm/gemini/installation-wsl.md) - Windows Subsystem for Linux
    * [NixOS Installation](pages/llm/gemini/installation-nixos.md) - NixOS package manager
  * [Gemini 2.5 Features](pages/llm/gemini/gemini-2-5-features.md) - Latest capabilities
  * [Roles and Agents](pages/llm/gemini/roles-and-agents.md) - Specialized assistants
  * [NotebookML Guide](pages/llm/gemini/notebookml-guide.md) - Notebook integration
  * [Cloud Infrastructure Deployment](pages/llm/gemini/cloud-infrastructure-deployment.md) - Production setup
  * [Summary](pages/llm/gemini/summary.md) - Key takeaways

## 💻 Development Environment

* [Tools Overview](pages/devops/tools-to-install/README.md) - Essential developer utilities
* [DevOps Tools](pages/devops-tools/README.md) - Specialized DevOps utilities
* [Operating Systems](pages/devops/tools-to-install/) - Development platforms
  * [NixOS](pages/Nixos/README.md) - Declarative Linux distribution
    * [Installation](pages/Nixos/install.md) - Setup guide
    * [DevEnv with Nix](pages/Nixos/devenv.md) - Development environment
    * [Cloud Deployments](pages/Nixos/nix-anywhere-cloud.md) - Cloud infrastructure
  * [WSL2](pages/devops/tools-to-install/wsl2/README.md) - Windows Subsystem for Linux
    * [Distributions](pages/devops/tools-to-install/wsl2/rhel-in-wsl2.md) - Available Linux variants
    * [Terminal Setup](pages/devops/tools-to-install/wsl2/make-your-terminal-devops-and-kubernetes-friendly.md) - CLI optimization
* [Editor Environments](pages/devops/tools-to-install/) - Code editing tools
  * [VS Code](pages/devops/tools-to-install/visual-studio-code.md) - Microsoft's code editor
  * [LunarVim](pages/devops/tools-to-install/lunarvim/README.md) - Vim-based IDE
* [CLI Tools](pages/should-learn/README.md) - Command-line utilities
  * [Azure CLI](pages/should-learn/az-cli/README.md) - Azure management
  * [PowerShell](pages/devops/tools-to-install/powershell/README.md) - Microsoft shell
  * [Linux Commands](pages/should-learn/linux/commands/README.md) - Essential Linux CLI
  * [YAML Tools](pages/should-learn/yaml/README.md) - YAML manipulation utilities

## 📚 Programming Languages

* [Python](pages/should-learn/python.md) - General-purpose language with strong DevOps ecosystem
* [Go](pages/should-learn/go-lang.md) - High-performance cloud-native language
* [JavaScript/TypeScript](pages/should-learn/README.md) - Web and Node.js development
* [Java](pages/should-learn/java.md) - Enterprise-focused language
* [Rust](pages/should-learn/rust.md) - Systems programming with memory safety

## 📖 Documentation Best Practices

* [Documentation Strategy](pages/devops/documentation/README.md) - Overall documentation approach
* [Project Documentation](pages/devops/documentation/projects-and-repositories.md) - Repository-level documentation
* [Release Notes](pages/devops/documentation/create-release-notes-with-pipeline.md) - Automated change documentation
* [Static Sites](pages/devops/documentation/how-to-create-a-static-website-for-your-documentation-based-on-mkdocs-and-mkdocs-material.md) - Documentation portal setup