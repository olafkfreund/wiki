# Puppet

Puppet is a leading open-source configuration management tool, widely used by DevOps and SRE teams to automate provisioning, enforce compliance, and manage cloud and on-premises infrastructure at scale.

## Overview (2025)

Puppet enables Infrastructure as Code (IaC) using a declarative, model-driven approach. It supports hybrid and multi-cloud environments (AWS, Azure, GCP), integrates with CI/CD pipelines, and is ideal for large-scale, compliance-driven operations.

## Pros

- Declarative language for infrastructure configuration
- Large module ecosystem
- Strong community support
- Idempotent operations
- Cross-platform support
- Built-in reporting and compliance
- Integration with cloud providers
- Excellent for large-scale deployments

## Cons

- Steep learning curve
- Complex setup for master-agent architecture
- Resource-intensive master server
- Limited real-time execution compared to other tools
- Ruby dependency
- Can be overkill for small infrastructures

## Installation and Setup (2025)

### Linux (Ubuntu/Debian)

```bash
# Install Puppet server
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install puppetserver

# Configure Java heap size if needed
sudo vi /etc/default/puppetserver
# JAVA_ARGS="-Xms1g -Xmx1g"

# Start Puppet server
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
```

### WSL

```bash
# Install Puppet agent
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install puppet-agent
```

### NixOS

```nix
# Add to configuration.nix
{
  services.puppet = {
    enable = true;
    masterService.enable = true;
    extraConfig = ''
      [main]
      server = puppet.example.com
    '';
  };
}
```

## Real-Life DevOps & SRE Examples

### 1. Enforcing Compliance Across Cloud VMs

```puppet
node /^web\d+\.prod\.aws\.example\.com$/ {
  include profile::base
  include profile::cloudwatch_agent
  include profile::cis_hardening
}
```

### 2. Automated User Management (SRE)

```puppet
users::user { 'devops_engineer':
  ensure     => present,
  uid        => '1050',
  groups     => ['sudo', 'docker'],
  ssh_keys   => ['ssh-rsa AAAA...'],
  managehome => true,
}
```

### 3. Multi-Cloud Resource Tagging (AWS & Azure)

```puppet
# AWS EC2 Tagging
aws_tag { 'Environment':
  resource_id => 'i-0abcd1234',
  value       => 'production',
}

# Azure VM Tagging
azure_vm_tag { 'web-vm':
  resource_group => 'prod-rg',
  tags           => { 'Owner' => 'SRE', 'CostCenter' => '1234' },
}
```

### 4. Integrating Puppet with CI/CD (GitHub Actions)

```yaml
name: Puppet Validate & Deploy
on: [push]
jobs:
  puppet:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate Puppet code
        run: |
          gem install puppet-lint
          puppet-lint manifests/
      - name: Deploy with r10k
        run: |
          gem install r10k
          r10k deploy environment -p
```

## Best Practices for DevOps & SRE (2025)

- Use roles/profiles for code organization
- Integrate Puppet runs with CI/CD pipelines
- Store secrets in Hiera or external vaults
- Monitor agent runs and failures (e.g., with Prometheus)
- Use resource collectors for dynamic infrastructure
- Test modules with rspec-puppet and puppet-lint
- Prefer declarative over imperative code

## Common Pitfalls

- Not using version control for manifests
- Hardcoding secrets in code
- Ignoring resource dependencies (ordering)
- Not monitoring agent failures
- Overusing exec resources (prefer native types)

## Troubleshooting

Common issues and their solutions:

1. **Certificate Issues:**
   - Clean SSL on agent
   - Regenerate certificates
   - Check time synchronization

2. **Resource Ordering:**
   - Use proper dependencies
   - Implement proper require/before statements
   - Use resource collectors wisely

3. **Performance Issues:**
   - Check JVM heap size
   - Optimize agent runs
   - Monitor PuppetDB performance

## Resources

- [Official Puppet Documentation](https://puppet.com/docs)
- [Puppet Forge](https://forge.puppet.com)
- [Community Support](https://puppet.com/community)
- [Puppet Learning VM](https://puppet.com/try-puppet/puppet-learning-vm)

---

> **Puppet Joke:**
> Why did the SRE break up with Puppet? Too many strings attached!

