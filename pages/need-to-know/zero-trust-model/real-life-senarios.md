# Real life senarios

### Designing a zero-trust architecture <a href="#_idparadest-165" id="_idparadest-165"></a>

Company BigMoney has concerns across its Azure, on-premises, and SaaS applications’ architecture. They have come to you for assistance in addressing their security concerns. They want you to provide suggestions on how they can use the security capabilities within Azure, Azure AD, and Microsoft 365 to enforce zero-trust methodologies across the company’s technology infrastructure.

The possible responses for the company’s areas of concern and requirements for enforcing Zero-trust include the following:

* Utilization of strong modern authentication techniques for all users, including cloud-native and on-premises directory users:
  * The cybersecurity architect should develop a plan to migrate users to Azure AD as a cloud-native identity provider. For users to remain on Windows AD, you can utilize Azure AD Connect with either password hash or pass-through synchronization with password write-back. This will allow modern authentication to new applications and the ability to utilize Azure AD MFA and Conditional Access policies.
  * Applications that support modern authentication can be registered in Azure AD to use cloud-native identities for authentication and authorization.
* Guest users should only be allowed to access resources that are assigned to them, and they should be regularly reviewed:
  * This can be accomplished utilizing Entitlement Management within Microsoft Entra Identity Governance
  * Regular access reviews can be created with Company ABC project managers or supervisors as the reviewers
* Administrative users should have **Just-in-Time** (**JIT**) access to privileged resources and all access should be justified and audited:
  * Microsoft Entra Identity Governance with **Privileged Identity Management** (**PIM**) provides JIT access. All enabled privileged access requires a justification and is audited.
  * Migrating users to Azure AD as a cloud-native identity provider will allow this governance to be used across all users within the company.
* When accessing applications that contain sensitive information, users should be required to verify their identity:
  * Planning, developing, and using Conditional Access policies to protect sensitive business applications should be done here. Applications and additional verification requirements for compliant devices and user-required MFA can be used for access and authorization.
* All user identities should be protected from common attacks:
  * Azure AD Identity Protection will monitor user and sign-in risks. The risks include common attack vectors such as brute-force identity attacks.
  * Azure AD Password protection can be used to protect against brute-force attacks by setting parameters for login frequency to block them. Password strength can be enforced by creating a dictionary of blocked passwords.
* Users that are accessing company resources from potentially dangerous locations should be forced to re-authenticate:
  * Additional Conditional Access policies can be created that identify trusted and untrusted locations that can force changes in the password and/or MFA verification. Untrusted locations can also be blocked from allowing users to authenticate.
* Devices should be verified with proper security patches before accessing company resources:
  * Microsoft Defender for Endpoint can be used to decrease the attack surface on Windows 10 and 11 devices
  * All devices that are accessing company resources should be managed with Microsoft Intune MDM or MAM
  * Conditional Access policies can be created to verify that devices follow Microsoft Intune policies before accessing applications
* Users should be analyzed for anomalous behavior and potential threats to identities:
  * Azure AD Identity Protection will monitor user and sign-in risks. This solution will monitor for potential threats and anomalous user behavior.
  * Creating a user risk policy can protect users, identify anomalies, and protect against unauthorized access from risky users.
* Network resources with sensitive information should not be accessible through publicly available connections:
  * Network infrastructure and resources should be designed with VNet segmentation. Resources containing sensitive information should be on their own dedicated VNet. Access through the network should be protected more securely than VNet peering. Network and Application Security Groups should have rules for how traffic goes between VNet segments and subnets to the private VNets.
  * Data on applications should also be identified, classified, and protected by using sensitivity labels. Sensitivity labels should be configured within DLP policies to decrease the potential for over-sharing of data by users.
  * Data that is being accessed across networks, both private and public, can be protected with private endpoint connections or service endpoints within **Network Security Groups** (**NSGs**).
* All activity and event data should be logged and can be reviewed:
  * Azure Monitor should be turned on for all Azure resources
  * Azure Arc can extend the monitoring to non-Azure resources
  * Microsoft 365 monitors and logs SaaS activity
  * Log Analytics and Microsoft Sentinel can be used to connect all data sources and provide a single location for monitoring and reviewing events and activities for malicious activity
* Reports can be generated for executive reviews and incident handling:
  * Taking these steps when monitoring activities and events allows the creation of reports for review. This information can also be used in custom dashboards, workbooks, and Power BI.

### Designing for regulatory compliance <a href="#_idparadest-166" id="_idparadest-166"></a>

In this section, you will be given a company scenario and asked to complete several tasks to meet the requirements of adhering to regulatory, data residency, and privacy requirements.

Company ABC has concerns across its Azure, on-premises, and SaaS applications architecture. They have come to you for assistance in addressing their regulatory and privacy concerns. They want you to provide suggestions on how they can use the standards and regulatory compliance and privacy capabilities within Microsoft and Azure to govern data residency and data privacy across the company’s technology infrastructure.

The possible responses for the company’s areas of concern and requirements include the following:
