# GitHub Copilot CLI

This guide covers the GitHub Copilot Command Line Interface (CLI), a powerful tool that brings AI-assisted coding to your terminal.

## Overview

GitHub Copilot CLI enhances your command line experience with:

- Natural language explanations of shell commands
- Command generation from natural language descriptions
- Shell command transformations and improvements
- Git operations assistance

## Installation

### Prerequisites

- Node.js 16 or higher
- npm or yarn
- GitHub CLI (`gh`)
- GitHub Copilot subscription

### Standard Installation

```bash
# Install GitHub Copilot CLI
npm install -g @githubnext/github-copilot-cli

# Authenticate
gh auth login
gh copilot auth login
```

### Verification

After installation, verify that the CLI works correctly:

```bash
gh copilot explain "ls -la | grep '^d'"
```

You should receive an explanation of the command, which lists directories in the current location.

## Core Commands

GitHub Copilot CLI offers three primary commands:

### 1. `gh copilot explain`

Explains what a command does in natural language.

```bash
# Basic usage
gh copilot explain "find . -type f -name '*.js' -mtime -7"

# With alias
gh explain "docker ps --filter 'status=exited'"
```

Example output:
```
This command finds all JavaScript files (*.js) modified in the last 7 days in the current directory and its subdirectories.
```

### 2. `gh copilot suggest`

Generates shell commands from natural language descriptions.

```bash
# Basic usage
gh copilot suggest "create a tar archive of the logs directory"

# With alias
gh suggest "find all PNG files larger than 1MB"
```

Example output:
```
I'll help you create a tar archive of the logs directory.

$ tar -czvf logs.tar.gz logs/

This command creates a compressed tar archive named 'logs.tar.gz' containing the contents of the logs directory.

Would you like me to run this command? [Y/n]
```

### 3. `gh copilot what-the-shell` (or `wts`)

Transforms one command into another based on your needs.

```bash
# Basic usage
gh copilot what-the-shell "curl https://api.github.com/repos/cli/cli/releases/latest" --flags "--include rate limit info"
```

Example output:
```
I'll help transform your command to include rate limit info.

$ curl -I https://api.github.com/repos/cli/cli/releases/latest

This command performs a HEAD request to show only the headers, which will include rate limit information.

Would you like me to run this command? [Y/n]
```

## Advanced Usage

### Environment Variables

Customize Copilot CLI behavior with environment variables:

```bash
# Disable automatic command execution
export GITHUB_COPILOT_NO_AUTO_EXECUTE=1

# Change the model used by Copilot (expert users)
export GITHUB_COPILOT_MODEL=gpt-4
```

### Creating Aliases

Set up aliases in your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Shorter aliases for common commands
alias explain="gh copilot explain"
alias suggest="gh copilot suggest"
alias wts="gh copilot what-the-shell"
```

### Integration with Shell History

Use Copilot CLI to improve previous commands:

```bash
# Get the last command from history and explain it
gh copilot explain "$(history | tail -n 1 | sed 's/^[0-9 ]*//')"

# Transform your last command
gh copilot what-the-shell "$(history | tail -n 1 | sed 's/^[0-9 ]*//')" --flags "make it verbose"
```

## Real-World DevOps Scenarios

### Scenario 1: Kubernetes Troubleshooting

```bash
# Get suggestions for troubleshooting a pod
gh suggest "how to check if a pod is stuck in pending state"

# Possible output:
# $ kubectl describe pod <pod-name> -n <namespace>
```

### Scenario 2: Complex Log Analysis

```bash
# Get help creating a complex log analysis command
gh suggest "find errors in nginx logs from the last hour and count occurrences by IP address"

# Possible output:
# $ grep "ERROR" /var/log/nginx/error.log | grep -E "$(date -d '1 hour ago' +'%d/%b/%Y:%H')" | awk '{print $1}' | sort | uniq -c | sort -nr
```

### Scenario 3: Infrastructure Deployment

```bash
# Get suggestions for AWS CLI commands
gh suggest "create an AWS EC2 instance with t3.micro type and Amazon Linux 2"

# Possible output:
# $ aws ec2 run-instances --image-id ami-0323c3dd2da7fb37d --instance-type t3.micro --key-name MyKeyPair --security-group-ids sg-903004f8 --count 1
```

## Tips for Effective Use

1. **Be Specific**: The more detailed your description, the more accurate the suggestions.

2. **Learn from Explanations**: Use the `explain` command to learn unfamiliar commands.

3. **Iterate on Suggestions**: If the initial suggestion isn't quite right, refine your request.

4. **Combine with Traditional Tools**: Use Copilot CLI alongside traditional command line tools like `man`, `tldr`, and `--help`.

5. **Review Before Executing**: Always review suggested commands before running them, especially for destructive operations.

## Security Considerations

1. **Command Review**: Always review suggested commands before execution.

2. **Sensitive Information**: Avoid including sensitive information in your requests.

3. **System Access**: Remember that executed commands have the same permissions as your current user.

4. **Network Connectivity**: All queries are sent to GitHub's servers, requiring internet connectivity.

## Troubleshooting

### Common Issues

1. **Authentication Problems**
   - Run `gh auth status` to check GitHub CLI authentication
   - Try re-authenticating with `gh auth login` followed by `gh copilot auth login`

2. **Command Not Found**
   - Ensure Node.js is installed and in your PATH
   - Verify installation with `npm list -g @githubnext/github-copilot-cli`

3. **Poor Suggestions**
   - Be more specific in your requests
   - Try rephrasing the request
   - Ensure you're using English for best results

4. **API Rate Limits**
   - If you encounter rate limits, wait before making more requests
   - Consider upgrading your GitHub plan for higher limits

### Getting Help

- Visit [GitHub Copilot CLI Repository](https://github.com/githubnext/github-copilot-cli)
- Run `gh copilot --help` for command-line help
- Check the [GitHub Community Forum](https://github.community/)
