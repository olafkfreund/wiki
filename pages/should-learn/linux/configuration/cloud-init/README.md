# Cloud-init

## Cloud-init documentation

`Cloud-init` is the _industry standard_ multi-distribution method for cross-platform cloud instance initialisation. It is supported across all major public cloud providers, provisioning systems for private cloud infrastructure, and bare-metal installations.

During boot, `cloud-init` identifies the cloud it is running on and initialises the system accordingly. Cloud instances will automatically be provisioned during first boot with networking, storage, SSH keys, packages and various other system aspects already configured.

`Cloud-init` provides the necessary glue between launching a cloud instance and connecting to it so that it works as expected.

---

## Supported Cloud Providers

Cloud-init is natively supported and used by the following major cloud providers to configure Linux VMs at launch:

- **AWS (Amazon Web Services):** Used for EC2 Linux instances via user data scripts and AMIs.
- **Azure (Microsoft Azure):** Used for Linux VMs and VM Scale Sets, supporting custom data and extensions.
- **GCP (Google Cloud Platform):** Used for Compute Engine Linux VMs via startup scripts and metadata.
- **OpenStack:** Default for Linux guest initialization.
- **Oracle Cloud, IBM Cloud, Alibaba Cloud:** Supported for Linux VM provisioning.

Cloud-init is also used in private clouds and on-premises environments (e.g., MAAS, VMware, bare metal) for consistent, automated Linux configuration.

---

> **Tip:** Always check your cloud provider's documentation for the latest cloud-init support and integration details.

