# Puppet

Puppet is an open-source configuration management tool that helps automate the provisioning and management of IT infrastructure using a declarative, model-driven approach.

## Overview

Puppet uses a master-agent architecture where configurations are defined as code (Infrastructure as Code) and automatically enforced across the infrastructure. It follows a declarative approach where you specify the desired state of your systems, and Puppet ensures that state is maintained.

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

## Installation and Setup

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

## Real-Life Examples

### Basic Node Configuration

```puppet
node 'webserver' {
  class { 'nginx':
    manage_repo    => true,
    service_ensure => running,
  }

  nginx::resource::server { 'example.com':
    listen_port => 80,
    www_root    => '/var/www/example',
  }
}
```

### Cloud Infrastructure Management

#### AWS Example

```puppet
class profile::aws {
  ec2_instance { 'web_server':
    ensure    => running,
    region    => 'us-west-2',
    image_id  => 'ami-0123456789',
    instance_type => 't2.micro',
    tags      => {
      'Environment' => 'production',
      'Role'        => 'webserver'
    }
  }

  route53_record { 'www.example.com':
    ensure => present,
    zone   => 'example.com',
    type   => 'A',
    ttl    => 300,
    values => ['10.0.0.1']
  }
}
```

#### Azure Example

```puppet
azure_resource_group { 'production-rg':
  ensure   => present,
  location => 'westus2',
}

azure_vm { 'web-vm':
  ensure              => present,
  resource_group     => 'production-rg',
  location           => 'westus2',
  size               => 'Standard_B1s',
  image              => 'Ubuntu:18.04-LTS:latest',
  admin_username     => 'adminuser',
  admin_password     => 'Password123!',
  network_interface  => 'web-vm-nic'
}
```

## Best Practices

1. **Code Organization:**
   - Use the roles and profiles pattern
   - Keep modules focused and single-purpose
   - Use version control for your Puppet code
   - Implement proper testing

2. **Security:**
   - Use Hiera for sensitive data
   - Implement proper certificate management
   - Regular security audits
   - Follow the principle of least privilege

3. **Performance:**
   - Optimize agent run intervals
   - Use PuppetDB for stored configurations
   - Implement proper caching strategies
   - Regular performance monitoring

## Common Workflows

### Certificate Management

```bash
# On Puppet master
puppetserver ca list
puppetserver ca sign --certname agent.example.com

# On Puppet agent
puppet ssl clean
puppet agent -t
```

### Module Development

```puppet
# Basic module structure
my_module/
├── manifests/
│   ├── init.pp
│   └── params.pp
├── templates/
├── files/
├── lib/
├── spec/
└── metadata.json
```

## Integration with DevOps Tools

### CI/CD Pipeline Example (GitHub Actions)

```yaml
name: Puppet CI
on: [push]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run puppet-lint
        run: |
          gem install puppet-lint
          puppet-lint manifests/
      - name: Run rspec tests
        run: |
          bundle install
          bundle exec rake spec
```

### Monitoring Integration

```puppet
class profile::monitoring {
  class { 'prometheus::node_exporter':
    extra_options => '--collector.systemd'
  }

  class { 'grafana':
    cfg => {
      server => {
        domain => 'monitoring.example.com'
      }
    }
  }
}
```

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

