# Non-Functional Requirements Capture

### Goals <a href="#goals" id="goals"></a>

In software engineering projects, important characteristics of the system providing for necessary e.g., testability, reliability, scalability, observability, security, manageability are best considered as first-class citizens in the requirements gathering process. By defining these non-functional requirements in detail early in the engagement, they can be rigorously evaluated when the cost of their impact on subsequent design decisions is comparatively low.

To support the process of capturing a project's _comprehensive_ non-functional requirements, this document offers a taxonomy for non-functional requirements and provides a framework for their identification, exploration, assignment of customer stakeholders, and eventual codification into formal engineering requirements as input to subsequent solution design.



### Areas of Investigation <a href="#areas-of-investigation" id="areas-of-investigation"></a>

#### Enterprise Security <a href="#enterprise-security" id="enterprise-security"></a>

* Privacy & Compliance
  * PII/GDPR/CCPA
  * HIPAA/HITECH
  * SOC2
  * FedRAMP
* Data Protection
  * Encryption
    * Client-side encryption
    * Server-side encryption
    * End-to-end encryption
  * Data mobility
    * at rest
    * in motion
    * in process/memory
    * cross-region/cloud data transfer
* Key Management
  * Cloud Provider KMS
    * AWS KMS
    * Azure Key Vault
    * Google Cloud KMS
  * HSM options
    * AWS CloudHSM
    * Azure Dedicated HSM
    * Google Cloud HSM
  * Responsibility
    * BYOK (Bring Your Own Key)
    * CMK (Customer Managed Keys)
    * Service Managed Keys
* INFOSEC Standards & Compliance
  * FIPS 140-2/3
  * ISO 27000 series
  * NIST frameworks
  * CIS benchmarks
* Cloud Network Security
  * Multi-Cloud Network Architecture
    * AWS Transit Gateway
    * Azure Virtual WAN
    * Google Cloud Network Connectivity Center
  * Zero Trust Network Access
  * Service Mesh Implementation
    * Istio
    * AWS App Mesh
    * Azure Service Mesh
  * Cloud Native Firewalls
    * AWS Network Firewall
    * Azure Firewall
    * Google Cloud Armor
  * Private Connectivity
    * AWS Direct Connect
    * Azure ExpressRoute
    * Google Cloud Interconnect
* Cloud Native Security Controls
  * CSPM (Cloud Security Posture Management)
  * CWPP (Cloud Workload Protection Platform)
  * CIEM (Cloud Infrastructure Entitlement Management)
* INFOSEC Incident Response
  * Cloud Native SIEM Integration
  * Automated Response Playbooks
  * Cross-Cloud Monitoring
  * Compliance Reporting

#### Enterprise AuthN/AuthZ <a href="#enterprise-authnauthz" id="enterprise-authnauthz"></a>

* Identity Management
  * Cloud Identity Providers
    * AWS IAM Identity Center
    * Azure AD/Entra ID
    * Google Cloud Identity
  * Federation Services
  * Cross-Cloud Identity Management
* Service Authentication
  * Managed Identities
  * Service Principals
  * Workload Identity Federation
* Authentication Mechanisms
  * OIDC
  * SAML 2.0
  * OAuth 2.0
  * FIDO2/WebAuthn
* Authorization
  * Cloud Native RBAC
    * AWS IAM
    * Azure RBAC
    * Google Cloud IAM
  * Attribute-Based Access Control (ABAC)
  * Just-In-Time Access
* Zero Trust Implementation
  * Identity-First Security
  * Continuous Verification
  * Least Privilege Access

#### Enterprise Monitoring/Operations <a href="#enterprise-monitoringoperations" id="enterprise-monitoringoperations"></a>

* Observability
  * Distributed Tracing
    * AWS X-Ray
    * Azure Application Insights
    * Google Cloud Trace
  * Metrics
    * AWS CloudWatch
    * Azure Monitor
    * Google Cloud Monitoring
  * Logging
    * AWS CloudWatch Logs
    * Azure Log Analytics
    * Google Cloud Logging
  * APM Solutions
    * OpenTelemetry Integration
    * Service Level Objectives (SLOs)
    * Service Level Indicators (SLIs)
* Reliability Engineering
  * Chaos Engineering Practices
  * Game Days
  * Fault Injection Testing
* Disaster Recovery
  * Multi-Region Strategy
  * Cross-Cloud Failover
  * Recovery Time Objective (RTO)
  * Recovery Point Objective (RPO)
* GitOps Practices
  * Infrastructure as Code (IaC)
  * Configuration as Code
  * Policy as Code
* Cost Management
  * FinOps Implementation
  * Resource Tagging Strategy
  * Automated Cost Optimization
* Performance Monitoring
  * Auto-scaling policies
  * Load Testing
  * Capacity Planning
* Incident Management
  * AIOps Integration
  * Automated Remediation
  * Cross-Cloud Alerting
* Compliance Monitoring
  * Continuous Compliance
  * Audit Logging
  * Policy Enforcement

#### Other standard Enterprise technologies/practices <a href="#other-standard-enterprise-technologiespractices" id="other-standard-enterprise-technologiespractices"></a>

* Developer ecosystem
  * Platform/OS
    * Hardened
    * Approved base images
    * Image repository
  * Tools, languages
    * Approval process
  * Code repositories
    * Secrets management patterns
      * Env var
      * Config file(s)
      * Secrets retrieval API
  * Package manager source(s)
    * Private
    * Public
    * Approved/Trusted
  * CI/CD
  * Artifact repositories

#### Production ecosystem <a href="#production-ecosystem" id="production-ecosystem"></a>

* Container Orchestration
  * Kubernetes Distributions
    * Amazon EKS
    * Azure AKS
    * Google GKE
  * Service Mesh
  * Container Security
  * Registry Management
* Infrastructure Management
  * Multi-Cloud Strategy
  * Terraform Management
  * Policy Management
    * OPA/Gatekeeper
    * AWS Organizations
    * Azure Policy
    * Google Organization Policy
* Platform Engineering
  * Internal Developer Platform
  * Self-Service Capabilities
  * Platform API Management
* Cloud Native Storage
  * Block Storage
  * Object Storage
  * File Systems
  * Database Services
* Network Architecture
  * Service Discovery
  * Load Balancing
  * API Gateway
  * CDN Integration
* Deployment Strategies
  * Blue-Green
  * Canary
  * Feature Flags
  * Progressive Delivery
* Security Posture
  * Supply Chain Security
  * Runtime Security
  * Vulnerability Management
* Compliance Framework
  * Industry Standards
  * Internal Policies
  * Automated Enforcement

#### Other areas/topics not addressed above (requires customer input to comprehensively enumerate) <a href="#other-areastopics-not-addressed-above-requires-customer-input-to-comprehensively-enumerate" id="other-areastopics-not-addressed-above-requires-customer-input-to-comprehensively-enumerate"></a>



### Investigation Process <a href="#investigation-process" id="investigation-process"></a>

1. Identify/brainstorm areas/topics requiring further investigation/definition
2. Identify customer stakeholder(s) responsible for each identified area/topic
3. Schedule debrief/requirements definition session(s) with each stakeholder
   * as necessary to achieve sufficient understanding of the probable impact of each requirement to the project
   * both current/initial milestone and long-term/road map
4. Document requirements/dependencies identified and related design constraints
5. Evaluate current/near-term planned milestone(s) through the lens of the identified requirements/constraints
   * Categorize each requirement as affecting immediate/near-term milestone(s) or as applicable instead to the longer-term road map/subsequent milestones
6. Adapt plans for current/near-term milestone(s) to accommodate immediate/near-term-categorized requirements



### Structure of Outline/Assignment of Responsible Stakeholder <a href="#structure-of-outlineassignment-of-responsible-stakeholder" id="structure-of-outlineassignment-of-responsible-stakeholder"></a>

In the following outline, assign name/email of 'responsible stakeholder' for each element after the appropriate level in the outline hierarchy. Assume inheritance model of responsibility assignment: stakeholder at any ancestor (parent) level is also responsible for descendent (child) elements unless overridden at the descendent level).

e.g.,

* Parent1 _\[Susan/susan@domain.com]_
  * child1
  * child2 _\[John/john@domain.com]_
    * grandchild1
  * child3
* Parent2 _\[Sam/sam@domain.com]_
  * child1
  * child2

In the preceding example, 'Susan' is responsible for `Parent1` and all of its descendants _except_ for `Parent1/child2` and `Parent1/child2/grandchild1` (for which 'John' is the stakeholder). 'Sam' is responsible for the entirety of `Parent2` and all of its descendants.

This approach permits the retention of the logical hierarchy of elements themselves while also flexibly interleaving the 'stakeholder' identifications within the hierarchy of topics if/when they may need to diverge due to e.g., customer organizational nuances.
