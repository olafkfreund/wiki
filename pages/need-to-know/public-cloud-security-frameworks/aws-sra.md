# AWS SRA

The AWS Security Reference Architecture aligns to three AWS security foundations: the AWS Cloud Adoption Framework (AWS CAF), AWS Well-Architected, and the AWS Shared Responsibility Model.

AWS Professional Services created [AWS CAF](https://aws.amazon.com/professional-services/CAF/) to help companies design and follow an accelerated path to successful cloud adoption. The guidance and best practices provided by the framework help you build a comprehensive approach to cloud computing across your enterprise and throughout your IT lifecycle. The AWS CAF organizes guidance into six areas of focus, called _perspectives_. Each perspective covers distinct responsibilities owned or managed by functionally related stakeholders. In general, the business, people, and governance perspectives focus on business capabilities; whereas the platform, security, and operations perspectives focus on technical capabilities.

* The [security perspective of the AWS CAF](https://docs.aws.amazon.com/whitepapers/latest/overview-aws-cloud-adoption-framework/security-perspective.html) helps you structure the selection and implementation of controls across your business. Following the current AWS recommendations in the security pillar can help you meet your business and regulatory requirements.&#x20;

[AWS Well-Architected](http://aws.amazon.com/architecture/well-architected) helps cloud architects build a secure, high-performing, resilient, and efficient infrastructure for their applications and workloads. The framework is based on six pillars—operational excellence, security, reliability, performance efficiency, cost optimization, and sustainability—and provides a consistent approach for AWS customers and Partners to evaluate architectures and implement designs that can scale over time. We believe that having well-architected workloads greatly increases the likelihood of business success.

* The [Well-Architected security pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html) describes how to take advantage of cloud technologies to help protect data, systems, and assets in a way that can improve your security posture. This will help you meet your business and regulatory requirements by following current AWS recommendations. There are additional Well-Architected Framework focus areas that provide more context for specific domains such as governance, serverless, AI/ML, and gaming. These are known as [AWS Well-Architected lenses](https://aws.amazon.com/architecture/well-architected/#AWS\_Well-Architected\_Lenses).&#x20;

Security and compliance are a [shared responsibility between AWS and the customer](https://aws.amazon.com/compliance/shared-responsibility-model/). This shared model can help relieve your operational burden as AWS operates, manages, and controls the components from the host operating system and virtualization layer down to the physical security of the facilities in which the service operates. For example, you assume responsibility and management of the guest operating system (including updates and security patches), application software, server-side data encryption, network traffic route tables, and the configuration of the AWS provided security group firewall. For abstracted services such as Amazon Simple Storage Service (Amazon S3) and Amazon DynamoDB, AWS operates the infrastructure layer, the operating system, and platforms, and you access the endpoints to store and retrieve data. You are responsible for managing your data (including encryption options), classifying your assets, and using AWS Identity and Access Management (IAM) tools to apply the appropriate permissions. This shared model is often described by saying that AWS is responsible for the security _of_ the cloud (that is, for protecting the infrastructure that runs all the services offered in the AWS Cloud), and you are responsible for the security _in_ the cloud (as determined by the AWS Cloud services that you select).&#x20;

Within the guidance provided by these foundational documents, two sets of concepts are particularly relevant to the design and understanding of the AWS SRA: security capabilities and security design principles.

### Security capabilities <a href="#security-capabilities" id="security-capabilities"></a>

The security perspective of AWS CAF outlines nine capabilities that help you achieve the confidentiality, integrity, and availability of your data and cloud workloads.

* _Security governance_ to develop and communicate security roles, responsibilities, policies, processes, and procedures across your organization’s AWS environment.
* _Security assurance_ to monitor, evaluate, manage, and improve the effectiveness of your security and privacy programs.
* _Identity and access management_ to manage identities and permissions at scale.
* _Threat detection_ to understand and identify potential security misconfigurations, threats, or unexpected behaviors.
* _Vulnerability management_ to continuously identify, classify, remediate, and mitigate security vulnerabilities.
* _Infrastructure protection_ to help validate that systems and services within your workloads are protected.
* _Data protection_ to maintain visibility and control over data, and how it is accessed and used in your organization.
* _Application security_ to help detect and address security vulnerabilities during the software development process.
* _Incident response_ to reduce potential harm by effectively responding to security incidents.

### Security design principles <a href="#security-principles" id="security-principles"></a>

The [security pillar](https://docs.aws.amazon.com/wellarchitected/latest/framework/security.html) of the Well-Architected Framework captures a set of seven design principles that turn specific security areas into practical guidance that can help you strengthen your workload security. Where the security capabilities frame the overall security strategy, these Well-Architected principles describe what you can start doing. They are reflected very deliberately in this AWS SRA and consist of the following:

* _Implement a strong identity foundation_ – Implement the principle of least privilege, and enforce separation of duties with appropriate authorization for each interaction with your AWS resources. Centralize identity management, and aim to eliminate reliance on long-term static credentials.
* _Enable traceability_ – Monitor, generate alerts, and audit actions and changes to your environment in real time. Integrate log and metric collection with systems to automatically investigate and take action.
* _Apply security at all layers_ – Apply a defense-in-depth approach with multiple security controls. Apply multiple types of controls (for example, preventive and detective controls) to all layers, including edge of network, virtual private cloud (VPC), load balancing, instance and compute services, operating system, application configuration, and code.
* _Automate security best practices_ – Automated, software-based security mechanisms improve your ability to securely scale more rapidly and cost-effectively. Create secure architectures, and implement controls that are defined and managed as code in version-controlled templates.
* _Protect data in transit and at rest_ – Classify your data into sensitivity levels and use mechanisms such as encryption, tokenization, and access control where appropriate.
* _Keep people away from data_ – Use mechanisms and tools to reduce or eliminate the need to directly access or manually process data. This reduces the risk of mishandling or modification and human error when handling sensitive data.
* _Prepare for security events_ – Prepare for an incident by having incident management and investigation policy and processes that align to your organizational requirements. Run incident response simulations and use tools with automation to increase your speed for detection, investigation, and recovery.
