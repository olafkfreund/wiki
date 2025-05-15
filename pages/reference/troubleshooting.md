# Advanced DevOps/SRE Troubleshooting Guide

## Shell-Based Diagnostics

### Process Investigation
```bash
# Advanced process tree analysis with resource usage
ps auxf | awk '{if($3>0.0 || $4>0.0) print $0}'

# Find processes causing high I/O
iotop -o -b -n 2

# Trace system calls with stack traces
perf trace -p $(pgrep process_name) -s

# Advanced strace filtering
strace -e trace=network,ipc -f -p $(pgrep process_name)
```

### System Performance
```bash
# Quick performance profile using perf
perf record -F 99 -a -g -- sleep 30
perf report --stdio

# Memory leak investigation
valgrind --leak-check=full --show-leak-kinds=all ./program

# System-wide performance snapshot
sudo sysdig -c spectrogram 'evt.type=switch and evt.dir=>>'
```

## Network Diagnostics

### Advanced Network Troubleshooting
```bash
# TCP connection analysis
ss -tan 'sport = :80' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c

# Network packet capture with advanced filtering
tcpdump -i any -A -s0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# DNS troubleshooting with specific nameservers
dig @8.8.8.8 +trace example.com

# Advanced MTR with JSON output
mtr -j --report google.com
```

### Container Networking
```bash
# Debug Kubernetes DNS
kubectl run -it --rm --restart=Never --image=gcr.io/kubernetes-e2e-test-images/dnsutils dnsutils

# Get container network namespace
nsenter --target $(docker inspect --format '{{.State.Pid}}' container_name) --net ip addr

# Trace container network path
kubectl exec -it pod-name -- tcptraceroute service-name 80
```

## Cloud Platform Issues

### AWS Troubleshooting
```bash
# Check EC2 instance metadata with IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/

# Debug EKS node issues
aws eks get-token --cluster-name cluster-name | kubectl describe node $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# CloudWatch Logs Insights query
aws logs start-query \
  --log-group-name /aws/lambda/function-name \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/'
```

### Azure Diagnostics
```bash
# Get detailed VM diagnostics
az vm diagnostics get-default-config

# Advanced AKS troubleshooting
az aks kollect -g resourceGroup -n clusterName --storage-account storageAccount

# Network Watcher packet capture
az network watcher packet-capture create -g resourceGroup -n capture1 --vm vmName
```

## Container Orchestration

### Kubernetes Deep Dive
```bash
# Debug node issues
crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -a

# Analyze etcd directly
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Advanced pod debugging
kubectl debug node/node-name -it --image=ubuntu
```

## Performance Analysis

### Resource Profiling
```bash
# CPU profiling with flamegraphs
git clone https://github.com/brendangregg/FlameGraph
perf record -F 99 -a -g -- sleep 60
perf script | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > cpu.svg

# Memory analysis
vmstat -w 1 | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}'

# I/O latency analysis
biolatency -D 30 1
```

## AI/LLM Integration

### Using AI for Troubleshooting

#### GitHub Copilot CLI
```bash
# Generate diagnostic commands
gh copilot suggest "how to find processes using most memory"

# Debug error messages
gh copilot explain "$(kubectl describe pod failing-pod | tail -n 20)"
```

#### OpenAI API Integration
```bash
# Create a shell function for quick log analysis
function analyze_logs() {
  local log_content=$(tail -n 50 "$1")
  curl -s https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"gpt-4\",
      \"messages\": [{
        \"role\": \"system\",
        \"content\": \"Analyze these logs and identify potential issues:\"
      }, {
        \"role\": \"user\",
        \"content\": \"$log_content\"
      }]
    }" | jq -r '.choices[0].message.content'
}
```

#### Using Ollama Locally
```bash
# Set up local LLM for offline troubleshooting
function debug_with_llm() {
  curl -X POST http://localhost:11434/api/generate -d "{
    \"model\": \"codellama\",
    \"prompt\": \"Debug this error: $1\",
    \"stream\": false
  }" | jq -r '.response'
}
```

## Quick Reference: One-Liners

### System Analysis
```bash
# Find processes causing high load
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head

# Track system calls of a process tree
strace -ff -e trace=network,ipc -p $(pgrep -d ',' process_name)

# Monitor file system events in real-time
inotifywait -m -r /path/to/watch -e modify,create,delete
```

### Network Debugging
```bash
# Show real-time network statistics
sar -n DEV 1

# Analyze connection states
netstat -ant | awk '{print $6}' | sort | uniq -c | sort -n

# Track SSL handshakes
tcpdump -i any -w ssl.pcap 'tcp port 443 and (tcp[((tcp[12:1] & 0xf0) >> 2):1] = 0x16)'
```

### Container Management
```bash
# Clean up all unused containers and images
docker system prune -af --volumes

# Show container resource usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# List all images with digests
docker images --digests --no-trunc
```

## Best Practices

1. Always maintain a local troubleshooting toolkit:
```bash
git clone https://github.com/nicolaka/netshoot ~/toolkit
docker pull nicolaka/netshoot
```

2. Set up persistent debug aliases:
```bash
# Add to ~/.zshrc or ~/.bashrc
alias kdebug='kubectl run debug --rm -i --tty --image=nicolaka/netshoot -- /bin/bash'
alias sysdebug='sudo sysdig -c csysdig'
```

3. Use structured logging:
```bash
# JSON log parsing
jq -R 'fromjson? | select(.level == "error")' < application.log

# Parse structured logs with Miller
mlr --json filter '$level == "error"' then sort -nr timestamp application.log
```

## Automation Tips

### Create Self-Documenting Scripts
```bash
function debug_service() {
  local service_name=$1
  echo "=== Debugging $service_name ==="
  
  echo "1. Checking service status..."
  systemctl status "$service_name"
  
  echo "2. Checking recent logs..."
  journalctl -u "$service_name" -n 50 --no-pager
  
  echo "3. Checking resource usage..."
  ps aux | grep "$service_name"
  
  echo "4. Checking open files..."
  lsof -p "$(pgrep -f "$service_name")"
}
```

### Monitoring Setup
```bash
# Prometheus node_exporter with custom collectors
NODE_EXPORTER_ARGS="--collector.textfile.directory=/var/lib/node_exporter \
  --collector.systemd \
  --collector.processes"
```

Remember to regularly update this guide as new tools and techniques emerge.