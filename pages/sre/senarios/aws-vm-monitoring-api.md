# SRE Scenario: Monitoring Application Logs on AWS VM with a Golang API

## Scenario Description

Your team operates a critical service running on EC2 instances in AWS, but your current monitoring infrastructure lacks visibility into application-specific logs. The traditional approaches of installing agents or shipping logs aren't feasible due to security restrictions. You need a lightweight solution that can expose application logs through a secure API to integrate with your existing monitoring stack.

## Problem Statement

- Application logs are stored locally on EC2 instances
- Security policies restrict installing third-party agents
- Need real-time access to logs for monitoring and alerting
- Solution must be lightweight and secure
- Must integrate with existing monitoring tools (Prometheus, Grafana, etc.)

## Solution: Log Exposition API in Golang

We'll create a lightweight HTTP API server in Golang that:

1. Reads application logs from configurable local paths
2. Exposes the logs via secure HTTP endpoints
3. Provides filtering capabilities
4. Includes authentication
5. Offers metrics collection points for Prometheus

## Implementation

### Complete Golang API Code

Here's the complete implementation of our log exposition API:

```go
// File: logapi/main.go
package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Configuration holds application settings
type Configuration struct {
	LogPaths     []string          `json:"log_paths"`
	APIPort      int               `json:"api_port"`
	APIToken     string            `json:"api_token"`
	MaxLogSize   int               `json:"max_log_size"`
	MetricsPort  int               `json:"metrics_port"`
	AlertKeywords map[string]string `json:"alert_keywords"`
}

// LogEntry represents a single log entry
type LogEntry struct {
	Timestamp time.Time `json:"timestamp"`
	File      string    `json:"file"`
	Line      string    `json:"line"`
	Level     string    `json:"level,omitempty"`
}

var (
	config         Configuration
	configPath     string
	logsMutex      sync.RWMutex
	recentLogs     []LogEntry
	
	// Prometheus metrics
	logsReadTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "logapi_logs_read_total",
			Help: "Total number of log entries processed",
		},
		[]string{"file", "level"},
	)
	
	apiRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "logapi_requests_total",
			Help: "Total number of API requests",
		},
		[]string{"endpoint", "status"},
	)
	
	errorLogsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "logapi_error_logs_total",
			Help: "Total number of error logs detected",
		},
		[]string{"file", "keyword"},
	)
)

func init() {
	// Register prometheus metrics
	prometheus.MustRegister(logsReadTotal)
	prometheus.MustRegister(apiRequestsTotal)
	prometheus.MustRegister(errorLogsTotal)
	
	// Parse command line flags
	flag.StringVar(&configPath, "config", "/etc/logapi/config.json", "Path to configuration file")
	flag.Parse()
}

func main() {
	// Load configuration
	if err := loadConfig(); err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}
	
	// Initialize log buffer
	recentLogs = make([]LogEntry, 0, config.MaxLogSize)
	
	// Start log reader goroutines
	for _, path := range config.LogPaths {
		go monitorLogs(path)
	}
	
	// Setup API router
	router := mux.NewRouter()
	router.Use(authMiddleware)
	router.HandleFunc("/logs", getLogsHandler).Methods("GET")
	router.HandleFunc("/logs/{file}", getFileLogsHandler).Methods("GET")
	router.HandleFunc("/health", healthCheckHandler).Methods("GET")
	
	// Setup metrics server on separate port
	metricsRouter := http.NewServeMux()
	metricsRouter.Handle("/metrics", promhttp.Handler())
	
	// Start servers
	go func() {
		log.Printf("Starting metrics server on :%d", config.MetricsPort)
		if err := http.ListenAndServe(fmt.Sprintf(":%d", config.MetricsPort), metricsRouter); err != nil {
			log.Fatalf("Metrics server failed: %v", err)
		}
	}()
	
	log.Printf("Starting API server on :%d", config.APIPort)
	if err := http.ListenAndServe(fmt.Sprintf(":%d", config.APIPort), router); err != nil {
		log.Fatalf("API server failed: %v", err)
	}
}

func loadConfig() error {
	file, err := os.Open(configPath)
	if err != nil {
		return err
	}
	defer file.Close()
	
	decoder := json.NewDecoder(file)
	if err := decoder.Decode(&config); err != nil {
		return err
	}
	
	// Set defaults if not provided
	if config.APIPort == 0 {
		config.APIPort = 8080
	}
	if config.MetricsPort == 0 {
		config.MetricsPort = 9090
	}
	if config.MaxLogSize == 0 {
		config.MaxLogSize = 10000
	}
	
	return nil
}

func monitorLogs(logPath string) {
	filename := filepath.Base(logPath)
	log.Printf("Starting to monitor log file: %s", logPath)
	
	for {
		file, err := os.Open(logPath)
		if err != nil {
			log.Printf("Error opening log file %s: %v", logPath, err)
			time.Sleep(5 * time.Second)
			continue
		}
		
		// Seek to end of file for new logs only
		file.Seek(0, io.SeekEnd)
		
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			addLogEntry(filename, line)
		}
		
		if err := scanner.Err(); err != nil {
			log.Printf("Error reading log file %s: %v", logPath, err)
		}
		
		file.Close()
		time.Sleep(1 * time.Second)
	}
}

func addLogEntry(filename, line string) {
	// Simple log level detection
	level := "info"
	lowerLine := strings.ToLower(line)
	
	if strings.Contains(lowerLine, "error") {
		level = "error"
	} else if strings.Contains(lowerLine, "warn") {
		level = "warning"
	} else if strings.Contains(lowerLine, "debug") {
		level = "debug"
	}
	
	// Check for alert keywords
	for keyword, severity := range config.AlertKeywords {
		if strings.Contains(lowerLine, strings.ToLower(keyword)) {
			errorLogsTotal.WithLabelValues(filename, keyword).Inc()
			// In a real implementation, you might want to send alerts here
		}
	}
	
	entry := LogEntry{
		Timestamp: time.Now(),
		File:      filename,
		Line:      line,
		Level:     level,
	}
	
	logsMutex.Lock()
	defer logsMutex.Unlock()
	
	// Add to circular buffer, remove oldest if full
	if len(recentLogs) >= config.MaxLogSize {
		recentLogs = recentLogs[1:]
	}
	recentLogs = append(recentLogs, entry)
	
	// Update metrics
	logsReadTotal.WithLabelValues(filename, level).Inc()
}

func authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Skip auth for health check
		if r.URL.Path == "/health" {
			next.ServeHTTP(w, r)
			return
		}
		
		token := r.Header.Get("X-API-Token")
		if token != config.APIToken {
			apiRequestsTotal.WithLabelValues(r.URL.Path, "401").Inc()
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}
		
		next.ServeHTTP(w, r)
	})
}

func getLogsHandler(w http.ResponseWriter, r *http.Request) {
	level := r.URL.Query().Get("level")
	limit := 100 // Default limit
	
	logsMutex.RLock()
	defer logsMutex.RUnlock()
	
	var filteredLogs []LogEntry
	
	// Apply filters
	for i := len(recentLogs) - 1; i >= 0 && len(filteredLogs) < limit; i-- {
		entry := recentLogs[i]
		if level == "" || entry.Level == level {
			filteredLogs = append(filteredLogs, entry)
		}
	}
	
	apiRequestsTotal.WithLabelValues("/logs", "200").Inc()
	json.NewEncoder(w).Encode(filteredLogs)
}

func getFileLogsHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	filename := vars["file"]
	level := r.URL.Query().Get("level")
	limit := 100 // Default limit
	
	logsMutex.RLock()
	defer logsMutex.RUnlock()
	
	var filteredLogs []LogEntry
	
	// Apply filters
	for i := len(recentLogs) - 1; i >= 0 && len(filteredLogs) < limit; i-- {
		entry := recentLogs[i]
		if entry.File == filename && (level == "" || entry.Level == level) {
			filteredLogs = append(filteredLogs, entry)
		}
	}
	
	apiRequestsTotal.WithLabelValues("/logs/"+filename, "200").Inc()
	json.NewEncoder(w).Encode(filteredLogs)
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	apiRequestsTotal.WithLabelValues("/health", "200").Inc()
	w.Write([]byte("OK"))
}
```

### Configuration File Example

```json
{
  "log_paths": [
    "/var/log/application/app.log",
    "/var/log/application/error.log"
  ],
  "api_port": 8080,
  "metrics_port": 9090,
  "api_token": "your-secure-api-token-here",
  "max_log_size": 10000,
  "alert_keywords": {
    "exception": "critical",
    "crashed": "critical",
    "timeout": "warning"
  }
}
```

## Deployment Guide

### Prerequisites

- Go 1.18 or higher
- AWS EC2 instance with your application running
- Access to install and run services on the EC2 instance

### Building the API

1. Create a project directory on your development machine:

```bash
mkdir -p ~/projects/logapi
cd ~/projects/logapi
```

2. Initialize the Go module:

```bash
go mod init logapi
```

3. Create the main.go file with the code provided above

4. Install dependencies:

```bash
go get github.com/gorilla/mux
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
```

5. Build the binary:

```bash
go build -o logapi main.go
```

### Deploying to AWS EC2

1. Create a configuration directory and file on the EC2 instance:

```bash
sudo mkdir -p /etc/logapi
sudo vim /etc/logapi/config.json
```

2. Copy and modify the example configuration file provided above to match your application's log paths.

3. Copy the compiled binary to the EC2 instance:

```bash
scp -i your-key.pem logapi ec2-user@your-ec2-instance:/tmp/
```

4. Set up the service on the EC2 instance:

```bash
sudo mv /tmp/logapi /usr/local/bin/
sudo chmod +x /usr/local/bin/logapi
```

5. Create a systemd service file:

```bash
sudo tee /etc/systemd/system/logapi.service > /dev/null << 'EOF'
[Unit]
Description=Log Exposition API
After=network.target

[Service]
ExecStart=/usr/local/bin/logapi --config=/etc/logapi/config.json
Restart=always
User=root
Group=root
Environment=PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
WorkingDirectory=/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF
```

6. Start and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable logapi
sudo systemctl start logapi
```

7. Verify the service is running:

```bash
sudo systemctl status logapi
```

### Security Configuration

To secure the API:

1. Configure a secure API token in the config.json file
2. Set up an AWS security group to only allow traffic from your monitoring systems
3. Consider setting up an HTTPS proxy with Nginx or similar if needed

## Integration with Monitoring Systems

### Prometheus Integration

Add this configuration to your Prometheus scrape configs:

```yaml
scrape_configs:
  - job_name: 'logapi'
    scrape_interval: 15s
    static_configs:
      - targets: ['your-ec2-instance:9090']
```

### Grafana Dashboard

Create a dashboard to visualize the metrics:

1. Add a Prometheus data source in Grafana
2. Create panels for metrics like:
   - `logapi_logs_read_total` (by file, by level)
   - `logapi_error_logs_total` (by keyword)
   - `logapi_requests_total` (by endpoint, status)

### API Usage Examples

To fetch logs from your monitoring system:

```bash
# Get recent logs
curl -H "X-API-Token: your-secure-api-token-here" http://your-ec2-instance:8080/logs

# Get only error logs
curl -H "X-API-Token: your-secure-api-token-here" http://your-ec2-instance:8080/logs?level=error

# Get logs from a specific file
curl -H "X-API-Token: your-secure-api-token-here" http://your-ec2-instance:8080/logs/app.log
```

## Troubleshooting

### Common Issues

1. **API returns "Unauthorized"**:
   - Verify the API token in your request matches the one in config.json

2. **No logs appearing**:
   - Check that the log paths in config.json are correct
   - Verify the service has permission to read those log files

3. **Service won't start**:
   - Check logs with `sudo journalctl -u logapi`
   - Verify the logapi binary has execution permissions

4. **High CPU usage**:
   - Increase the polling interval in the monitorLogs function
   - Consider reducing the number of monitored log files

## Future Enhancements

1. Add support for TLS/HTTPS
2. Implement log rotation handling
3. Add support for structured log formats (JSON, etc.)
4. Implement alerting capabilities directly from the API
5. Add support for distributed log collection across multiple instances