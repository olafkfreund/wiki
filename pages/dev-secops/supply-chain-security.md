# Supply Chain Security (2024+)

## SLSA Framework Implementation

### Build Level Requirements

```yaml
# Example SLSA Level 3 Build Definition
steps:
  - name: Build with provenance
    uses: slsa-framework/slsa-github-generator@v1
    with:
      base-image: 'alpine:3.19'
      provenance-name: 'multiple'
      private-key: ${{ secrets.SLSA_PRIVATE_KEY }}
```

## Binary Authorization

### Admission Controller Configuration

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: SignedImages
metadata:
  name: require-signed-images
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
  parameters:
    authorities:
    - keyless:
        url: "spiffe://cluster.local/ns/cosign-system/sa/cosign"
        identities: ["*"]
```

## Artifact Signing

### Cosign Implementation

```bash
# Generate keypair
cosign generate-key-pair

# Sign container image
cosign sign --key cosign.key ${IMAGE_URI}

# Verify signature
cosign verify --key cosign.pub ${IMAGE_URI}
```

## Software Bill of Materials (SBOM)

### Syft Integration

```yaml
name: Generate SBOM
on:
  push:
    branches: [ main ]
jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate SBOM
        uses: anchore/syft-action@v0.7.0
        with:
          image: ${{ env.IMAGE_NAME }}
          format: spdx-json
          output: sbom.json
```

## Secure Build Systems

### Reproducible Builds

* Deterministic compilation
* Source verification
* Build environment isolation
* Artifact provenance

### Attestation Management

* In-toto attestations
* Policy enforcement
* Chain of custody
* Trust boundaries

## Best Practices

1. **Dependency Management**
   * Use private artifact repositories
   * Implement dependency pinning
   * Regular vulnerability scanning
   * Automated updates

2. **Build Security**
   * Hermetic builds
   * Build reproducibility
   * Environment isolation
   * Resource integrity

3. **Artifact Management**
   * Signature verification
   * SBOM generation
   * Provenance tracking
   * Policy enforcement
