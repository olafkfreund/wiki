# Dependency and Container Scanning (2025)

Modern dependency and container scanning leverages AI/ML capabilities to detect vulnerabilities, analyze dependencies, and provide intelligent remediation suggestions. This guide covers current best practices and tools for securing your container ecosystem.

## Why Dependency and Container Scanning

In cloud-native environments, container security is critical due to:
- Complex dependency chains
- Supply chain attacks
- Zero-day vulnerabilities
- Compliance requirements
- Runtime security risks
- AI/ML model dependencies

## Modern Scanning Approaches

### 1. AI-Enhanced Scanning
```python
# filepath: /scripts/security/ai_scanner.py
from anthropic import Anthropic
from google.cloud import aiplatform
import json

class AISecurityScanner:
    def __init__(self):
        self.claude = Anthropic()
        self.gemini = aiplatform.init()
        
    async def analyze_dependencies(self, sbom_data: dict):
        prompt = f"""
        Analyze this software bill of materials (SBOM):
        {json.dumps(sbom_data, indent=2)}

        Identify:
        1. Critical vulnerabilities
        2. Supply chain risks
        3. Dependency conflicts
        4. License compliance issues
        5. Security best practices
        """

        # Get multiple AI perspectives
        claude_analysis = await self.claude.messages.create(
            model="claude-3-opus-20240229",
            temperature=0,
            messages=[{"role": "user", "content": prompt}]
        )

        gemini_analysis = await self.gemini.generate_content(prompt)

        return self._combine_analyses(claude_analysis, gemini_analysis)
```

### 2. NixOS Container Security

```nix
# filepath: /etc/nixos/container-security.nix
{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      features = {
        buildkit = true;
      };
      securityOpts = [
        "no-new-privileges"
        "seccomp=unconfined"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    trivy
    grype
    syft
    docker-compose
    crane
    cosign
  ];

  security.lockKernelModules = true;
  security.protectKernelImage = true;
}
```

### 3. WSL2 Security Integration

```powershell
# filepath: /scripts/setup-wsl-security.ps1
# Configure WSL for secure container scanning
$wslConfig = @"
[wsl2]
memory=8GB
processors=4
kernelCommandLine = vsyscall=emulate
nestedVirtualization=true

[experimental]
networkingMode=mirrored
dnsTunneling=true
firewall=true
"@

Set-Content -Path "$env:USERPROFILE\.wslconfig" -Value $wslConfig

# Install security tools in WSL
wsl -d Ubuntu-22.04 bash -c '
# Add security repositories
curl -fsSL https://pkg.snyk.io/key | sudo gpg --dearmor -o /usr/share/keyrings/snyk-archive-keyring.gpg

# Install tools
sudo apt update && sudo apt install -y \
  trivy \
  grype \
  syft \
  snyk \
  docker.io \
  python3-pip

# Install AI tools
pip3 install anthropic google-cloud-aiplatform openai'
```

## Modern Scanning Tools (2025)

### 1. Container Scanning
- **Trivy AI** - AI-enhanced vulnerability scanner
- **Grype** - Smart dependency analyzer
- **Syft** - SBOM generator with LLM integration
- **Snyk Container** - Advanced container security

### 2. Dependency Analysis
- **Mend Renovate** - Automated dependency updates
- **Dependabot X** - GitHub's next-gen dependency manager
- **OSV-Scanner** - Open Source Vulnerability scanner

### 3. Supply Chain Security
- **Sigstore** - Digital signature verification
- **Cosign** - Container signing and verification
- **SLSA Framework** - Supply chain integrity

## Automated Scanning Pipeline

```yaml
# filepath: /.github/workflows/container-scan.yml
name: Container Security Scan
on:
  push:
    paths:
      - 'Dockerfile'
      - 'package.json'
      - 'requirements.txt'
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate SBOM
        uses: anchore/syft-action@v2
        with:
          image: ${{ github.repository }}:${{ github.sha }}
          
      - name: Vulnerability Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ github.repository }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          
      - name: AI Analysis
        uses: security/ai-analysis@v2
        with:
          sbom: ${{ steps.syft.outputs.sbom }}
          scan-results: trivy-results.sarif
          models: ['claude-3', 'gemini-pro']
```

## Best Practices (2025)

1. **Base Image Security**
   - Use minimal base images
   - Regular security updates
   - Verified sources only
   - Automated rebuilds
   - Version pinning

2. **Dependency Management**
   - SBOM generation
   - License compliance
   - Version control
   - Automated updates
   - Impact analysis

3. **Runtime Security**
   - Immutable containers
   - Least privilege
   - Resource limits
   - Network policies
   - Security contexts

4. **Supply Chain Security**
   - Digital signatures
   - Chain of custody
   - Build provenance
   - Artifact verification
   - Trusted registries

## Monitoring and Response

```python
# filepath: /scripts/security/container_monitor.py
class ContainerSecurityMonitor:
    def __init__(self):
        self.client = Anthropic()
        
    async def monitor_containers(self):
        containers = self._get_running_containers()
        for container in containers:
            vulnerabilities = await self._scan_container(container)
            if vulnerabilities:
                await self._analyze_with_llm(vulnerabilities)
                
    async def _analyze_with_llm(self, vulnerabilities):
        prompt = f"""
        Analyze these container vulnerabilities:
        {json.dumps(vulnerabilities, indent=2)}
        
        Provide:
        1. Risk assessment
        2. Immediate actions
        3. Long-term fixes
        4. Prevention strategies
        """
        
        response = await self.client.messages.create(
            model="claude-3-opus-20240229",
            temperature=0,
            messages=[{"role": "user", "content": prompt}]
        )
        
        await self._handle_response(response.content)
```

Remember to:
- Regularly update scanning tools
- Monitor for new threats
- Validate AI/LLM results
- Maintain security policies
- Train teams on security
- Document findings
- Review and update procedures
