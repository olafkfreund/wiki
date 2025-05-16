# IoT Edge Computing Patterns (2024+)

## Azure IoT Edge Implementation

### Device Configuration
```yaml
apiVersion: devices.microsoft.com/v1
kind: IoTDevice
metadata:
  name: factory-sensor-001
spec:
  deviceId: sensor-001
  hubName: production-iothub
  capabilities:
    - type: Edge
  authentication:
    type: symmetricKey
  modules:
    - name: temperature-processor
      image: mcr.microsoft.com/azureiotedge-temp-processor:1.0
      env:
        - name: PROCESSING_INTERVAL
          value: "30"
    - name: edge-ml
      image: mcr.microsoft.com/azureiotedge-ml:2.0
      createOptions:
        HostConfig:
          DeviceRequests:
            - Count: -1
              Driver: nvidia
              Capabilities: [[gpu]]
```

## AWS IoT Greengrass

### Component Definition
```yaml
---
RecipeFormatVersion: '2020-01-25'
ComponentName: com.example.EdgeProcessor
ComponentVersion: '1.0.0'
ComponentDescription: Edge data processing component
ComponentPublisher: Example Corp
ComponentConfiguration:
  DefaultConfiguration:
    processingInterval: 60
    batchSize: 100
Manifests:
  - Platform:
      os: linux
    Lifecycle:
      Run: |
        python3 {artifacts:path}/edge_processor.py
    Artifacts:
      - URI: s3://bucket/edge_processor.py
        Permission:
          Execute: OWNER
```

## Edge ML Inference

### ONNX Runtime Configuration
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: edge-inference
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ml-inference
  template:
    spec:
      containers:
      - name: inference
        image: inference-engine:1.0
        resources:
          limits:
            nvidia.com/gpu: 1
        env:
        - name: MODEL_PATH
          value: /models/edge-optimized
        - name: INFERENCE_THREADS
          value: "2"
        - name: BATCH_SIZE
          value: "4"
        volumeMounts:
        - name: models
          mountPath: /models
      volumes:
      - name: models
        persistentVolumeClaim:
          claimName: model-storage
```

## Best Practices

1. **Device Management**
   - OTA updates
   - Health monitoring
   - Configuration management
   - Device provisioning

2. **Data Processing**
   - Edge filtering
   - Local aggregation
   - Data compression
   - Batch processing

3. **Security**
   - Device authentication
   - Secure boot
   - Data encryption
   - Network isolation

4. **Reliability**
   - Offline operation
   - Data buffering
   - Conflict resolution
   - Failover handling