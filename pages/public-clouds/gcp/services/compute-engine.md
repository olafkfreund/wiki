---
description: Deploying, configuring, and managing virtual machines using Google Compute Engine
---

# Google Compute Engine

Google Compute Engine (GCE) is GCP's Infrastructure as a Service (IaaS) offering that lets you create and run virtual machines on Google's infrastructure. Compute Engine offers scalable, high-performance virtual machines that can run Linux and Windows Server images in a variety of configurations.

## Key Features

- **Flexible machine types**: Predefined or custom machine configurations
- **Global infrastructure**: Deploy VMs across 24+ regions and 73+ zones
- **Managed instance groups**: Autoscaling, auto-healing, and rolling updates
- **Custom images**: Create your own VM images or use public images
- **Spot VMs**: Use excess Compute Engine capacity at steep discounts
- **Sole-tenant nodes**: Physical isolation for compliance requirements
- **Fast networking**: Up to 100 Gbps networking
- **Local and persistent storage options**: Various disk types for different workloads
- **Live migration**: Hardware maintenance without VM restarts
- **GPU and TPU support**: Accelerators for ML/AI workloads

## Deploying VMs with Terraform

### Basic VM Deployment

Here's a basic example of deploying a Linux VM with Terraform:

```hcl
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20  # GB
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y apache2
      cat <<HTML > /var/www/html/index.html
      <html><body><h1>Hello from Google Cloud!</h1></body></html>
      HTML
    EOF
  }

  tags = ["http-server", "https-server"]

  service_account {
    # Use the default service account
    scopes = ["cloud-platform"]
  }
}

# Allow HTTP traffic
resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
```

### Windows VM with Persistent Disk

This example creates a Windows Server VM with an additional persistent disk:

```hcl
resource "google_compute_instance" "windows_server" {
  name         = "windows-server"
  machine_type = "e2-standard-4"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-server-2022-dc-v20220513"
      size  = 50  # GB
      type  = "pd-ssd"
    }
  }

  # Additional persistent disk
  attached_disk {
    source      = google_compute_disk.data_disk.id
    device_name = "data-disk"
    mode        = "READ_WRITE"
  }

  network_interface {
    network = "default"
    
    access_config {
      // Ephemeral public IP
    }
  }

  # Windows password configuration
  metadata = {
    windows-startup-script-ps1 = <<-EOF
      # Configure data disk
      Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false
    EOF
  }

  tags = ["rdp-server"]
}

resource "google_compute_disk" "data_disk" {
  name  = "windows-data-disk"
  type  = "pd-ssd"
  size  = 100  # GB
  zone  = "us-central1-a"
}

# Allow RDP traffic
resource "google_compute_firewall" "rdp" {
  name    = "allow-rdp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]  # Consider restricting this in production
  target_tags   = ["rdp-server"]
}
```

### High Availability with Managed Instance Group

This example creates a regional managed instance group with autoscaling:

```hcl
# Create instance template
resource "google_compute_instance_template" "web_server_template" {
  name_prefix  = "web-server-template-"
  machine_type = "e2-medium"
  
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = 20
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y apache2
      cat <<HTML > /var/www/html/index.html
      <html><body><h1>Hello from $(hostname)!</h1></body></html>
      HTML
    EOF
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["http-server"]

  lifecycle {
    create_before_destroy = true
  }
}

# Create health check
resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

# Create regional instance group manager
resource "google_compute_region_instance_group_manager" "web_server_group" {
  name               = "web-server-group"
  base_instance_name = "web-server"
  region             = "us-central1"
  target_size        = 2  # Start with 2 VMs

  version {
    instance_template = google_compute_instance_template.web_server_template.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    min_ready_sec         = 30
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Create autoscaler
resource "google_compute_region_autoscaler" "web_server_autoscaler" {
  name   = "web-server-autoscaler"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.web_server_group.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6  # Target CPU utilization of 60%
    }
  }
}

# Create a load balancer
resource "google_compute_backend_service" "web_backend" {
  name        = "web-backend"
  protocol    = "HTTP"
  timeout_sec = 30
  health_checks = [google_compute_health_check.autohealing.id]

  backend {
    group = google_compute_region_instance_group_manager.web_server_group.instance_group
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_http_proxy.web_proxy.id
  port_range = "80"
}
```

## VM Deployment with Packer

[Packer](https://www.packer.io/) is a great tool for creating custom machine images. Here's how to build a custom GCE image:

```hcl
# packer.json
{
  "builders": [
    {
      "type": "googlecompute",
      "project_id": "your-project-id",
      "source_image_family": "debian-11",
      "source_image_project_id": "debian-cloud",
      "zone": "us-central1-a",
      "ssh_username": "packer",
      "image_name": "webapp-base-{{timestamp}}",
      "image_family": "webapp-base"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update",
        "sudo apt-get install -y nginx nodejs npm",
        "sudo systemctl enable nginx"
      ]
    },
    {
      "type": "file",
      "source": "./app/",
      "destination": "/tmp/app"
    },
    {
      "type": "shell",
      "inline": [
        "sudo mv /tmp/app /var/www/app",
        "cd /var/www/app && sudo npm install"
      ]
    }
  ]
}
```

Build the image with:

```bash
packer build packer.json
```

Then use the image in your Terraform configuration:

```hcl
resource "google_compute_instance" "webapp" {
  name         = "webapp"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "webapp-base"  # Your custom image family
    }
  }

  network_interface {
    network = "default"
    
    access_config {
      // Ephemeral public IP
    }
  }
}
```

## Configuration Management with Ansible

Ansible can be used to configure VMs once they're deployed. Create an inventory file that uses GCP dynamic inventory:

```ini
# gcp.yml
plugin: gcp_compute
projects:
  - your-project-id
regions:
  - us-central1
groups:
  web: "'web' in name"
  db: "'db' in name"
```

Create a playbook to configure web servers:

```yaml
# configure_web.yml
---
- name: Configure web servers
  hosts: web
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
      
    - name: Install required packages
      apt:
        name:
          - nginx
          - nodejs
          - npm
        state: present
        
    - name: Copy website files
      copy:
        src: ./website/
        dest: /var/www/html/
        owner: www-data
        group: www-data
        
    - name: Configure Nginx
      template:
        src: ./templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: Restart Nginx
      
  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

Execute the playbook against GCP instances:

```bash
ansible-inventory -i gcp.yml --list  # Verify the inventory
ansible-playbook -i gcp.yml configure_web.yml
```

## Monitoring with Google Cloud Operations (formerly Stackdriver)

Install the monitoring agent on your VMs using Terraform's `metadata_startup_script`:

```hcl
resource "google_compute_instance" "monitored_instance" {
  name         = "monitored-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Install monitoring agent
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    
    # Install logging agent
    sudo systemctl enable google-cloud-ops-agent
    sudo systemctl start google-cloud-ops-agent
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}
```

## CI/CD Pipeline with GitHub Actions

Set up a continuous deployment pipeline for your infrastructure:

```yaml
# .github/workflows/deploy_infrastructure.yml
name: Deploy Infrastructure

on:
  push:
    branches: [ main ]
    paths:
      - 'terraform/**'

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      
    - name: Authenticate to Google Cloud
      uses: google-github-actions/auth@v1
      with:
        credentials_json: ${{ secrets.GCP_CREDENTIALS }}

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v1
      with:
        project_id: ${{ secrets.GCP_PROJECT_ID }}

    - name: Terraform Init
      run: terraform init
      working-directory: ./terraform

    - name: Terraform Plan
      run: terraform plan
      working-directory: ./terraform

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve
      working-directory: ./terraform
```

## Using Pulumi for GCE Deployment

[Pulumi](https://www.pulumi.com/) is an alternative to Terraform that lets you use familiar programming languages. Here's a Python example:

```python
import pulumi
import pulumi_gcp as gcp

# Define a GCP instance
instance = gcp.compute.Instance("webserver",
    machine_type="e2-medium",
    zone="us-central1-a",
    boot_disk=gcp.compute.InstanceBootDiskArgs(
        initialize_params=gcp.compute.InstanceBootDiskInitializeParamsArgs(
            image="debian-cloud/debian-11",
        ),
    ),
    network_interfaces=[gcp.compute.InstanceNetworkInterfaceArgs(
        network="default",
        access_configs=[gcp.compute.InstanceNetworkInterfaceAccessConfigArgs()],
    )],
    metadata_startup_script="""
        #!/bin/bash
        apt-get update
        apt-get install -y apache2
        echo "Hello, World!" > /var/www/html/index.html
    """,
    tags=[
        "http-server",
    ],
)

# Create a firewall rule
firewall = gcp.compute.Firewall("allow-http",
    network="default",
    allows=[gcp.compute.FirewallAllowArgs(
        protocol="tcp",
        ports=["80"],
    )],
    source_ranges=["0.0.0.0/0"],
    target_tags=["http-server"],
)

# Export the IP address
pulumi.export("instance_ip", instance.network_interfaces[0].access_configs[0].nat_ip)
```

## Best Practices

1. **VM Naming Conventions**: Use a consistent naming convention that includes environment, purpose, and a unique identifier.
   ```
   [environment]-[purpose]-[number]-[region]
   Example: prod-web-001-us-central1
   ```

2. **Right-sizing VMs**: Start with appropriate sizes and use sustained use discounts.
   ```bash
   # Example: Analyze CPU usage and recommend machine types
   gcloud compute recommender recommendations list \
     --project=PROJECT_ID \
     --location=ZONE \
     --recommender=google.compute.instance.MachineTypeRecommender
   ```

3. **Use Startup Scripts with Caution**: For critical configuration, prefer custom images over extensive startup scripts.

4. **Cost Optimization**:
   - Use preemptible/spot VMs for batch workloads
   - Use sustained use discounts and committed use discounts
   - Schedule VM startups/shutdowns for non-24/7 workloads
   
   ```hcl
   # Example: Create a preemptible VM
   resource "google_compute_instance" "preemptible_worker" {
     name         = "preemptible-worker"
     machine_type = "e2-medium"
     zone         = "us-central1-a"
     
     scheduling {
       preemptible = true
       automatic_restart = false
     }
     
     # Other configuration...
   }
   ```

5. **Security Hardening**:
   - Use OS Login instead of SSH keys
   - Lock down firewall rules to specific IPs
   - Use service accounts with minimal permissions
   - Enable shielded VM options
   
   ```hcl
   resource "google_compute_instance" "secure_instance" {
     # Basic configuration...
     
     shielded_instance_config {
       enable_secure_boot = true
       enable_vtpm = true
       enable_integrity_monitoring = true
     }
     
     # Use OS Login instead of SSH keys
     metadata = {
       enable-oslogin = "TRUE"
     }
     
     # Use a custom service account
     service_account {
       email = google_service_account.vm_service_account.email
       scopes = ["cloud-platform"]
     }
   }
   ```

6. **Use Instance Templates**: Define your infrastructure once and reuse it.

7. **Implement Auto-healing and Auto-scaling**: For production workloads.

8. **Automate Backups**: Use scheduled snapshots for critical data.
   ```hcl
   resource "google_compute_resource_policy" "daily_backup" {
     name   = "daily-backup-policy"
     region = "us-central1"
     
     snapshot_schedule_policy {
       schedule {
         daily_schedule {
           days_in_cycle = 1
           start_time    = "04:00"
         }
       }
       retention_policy {
         max_retention_days    = 7
       }
     }
   }
   
   resource "google_compute_disk_resource_policy_attachment" "attachment" {
     name = google_compute_resource_policy.daily_backup.name
     disk = google_compute_instance.example.name
     zone = "us-central1-a"
   }
   ```

9. **Use Labels and Tags**: Apply tags for network rules and labels for resource organization.
   ```hcl
   resource "google_compute_instance" "labeled_instance" {
     # Basic configuration...
     
     tags = ["web", "production"]
     
     labels = {
       environment = "production"
       team        = "frontend"
       application = "website"
       cost-center = "marketing-101"
     }
   }
   ```

10. **Automate VM Management**: Use automation for patching, updates, and configuration changes.

## Common Pitfalls

1. **Not planning for VM placement**: Placing all VMs in a single zone creates a single point of failure.

2. **Ignoring quotas**: GCP has default quotas that can cause unexpected deployment failures.

3. **Hardcoding credentials**: Never store service account keys in your code or image.

4. **Using the default service account**: It often has broader permissions than necessary.

5. **Neglecting cleanup**: Set up automated processes to delete unused resources.

6. **Manual configuration drift**: Always manage infrastructure as code to prevent configuration drift.

7. **Overlooking network security**: Don't open firewall rules too broadly.

8. **Choosing the wrong machine type**: Oversized VMs waste money; undersized VMs cause performance issues.

## Advanced VM Configurations

### Spot VMs for Cost Savings

```hcl
resource "google_compute_instance" "spot_vm" {
  name         = "spot-instance"
  machine_type = "e2-standard-2"
  zone         = "us-central1-a"
  
  scheduling {
    preemptible                 = true
    automatic_restart           = false
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP" 
  }
  
  # Other configuration...
}
```

### Confidential VM for Enhanced Security

```hcl
resource "google_compute_instance" "confidential_vm" {
  name         = "confidential-vm"
  machine_type = "n2d-standard-2" # Confidential VMs require specific machine types
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  confidential_instance_config {
    enable_confidential_compute = true
  }
  
  # Other configuration...
}
```

### GPU-Accelerated VM

```hcl
resource "google_compute_instance" "gpu_vm" {
  name         = "gpu-vm"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"
  
  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }
  
  scheduling {
    on_host_maintenance = "TERMINATE" # Required for VMs with GPUs
  }
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  # Other configuration...
}
```

### Windows VM with Automated Password Reset

```hcl
resource "google_compute_instance" "windows_vm" {
  name         = "windows-server"
  machine_type = "e2-standard-4"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-server-2022-dc-core-v20230614"
    }
  }
  
  network_interface {
    network = "default"
    access_config {}
  }
  
  metadata = {
    windows-startup-script-ps1 = <<-EOF
      # Set password policy
      net accounts /minpwlen:12 /maxpwage:30 /minpwage:1 /uniquepw:5
      
      # Create a scheduled task to update Windows
      $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "& {Install-WindowsUpdate -AcceptAll -AutoReboot}"'
      $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
      Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "WeeklyWindowsUpdates" -Description "Weekly Windows Updates" -RunLevel Highest -User "System"
    EOF
  }
}

# Terraform can't directly set Windows passwords, but you can use gcloud in a local-exec provisioner
resource "null_resource" "windows_password_reset" {
  depends_on = [google_compute_instance.windows_vm]
  
  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute reset-windows-password ${google_compute_instance.windows_vm.name} \
        --zone=${google_compute_instance.windows_vm.zone} \
        --quiet
    EOT
  }
}
```

## Further Reading

- [Google Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Best Practices for Compute Engine](https://cloud.google.com/compute/docs/best-practices)
- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
- [Compute Engine Instance Pricing](https://cloud.google.com/compute/vm-instance-pricing)
- [Managed Instance Groups Guide](https://cloud.google.com/compute/docs/instance-groups)
- [VM Manager for patch management](https://cloud.google.com/compute/docs/vm-manager)