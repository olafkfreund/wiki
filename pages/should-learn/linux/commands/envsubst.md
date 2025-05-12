# envsubst

`envsubst` is a Unix-based command-line tool that replaces environment variables in text files. It is designed to simplify the process of substituting environment variables in configuration files and other text documents. In this wiki page, we will provide an introduction to `envsubst` and how it can be used in Azure deployment pipelines.

### Introduction to envsubst

`envsubst` is a tool that replaces environment variables in text files with their values. It is particularly useful when working with configuration files, where environment variables are commonly used to store configuration values. `envsubst` reads input text from standard input or a file and replaces any occurrences of environment variables in the text with their values.

`envsubst` is a lightweight tool that is easy to use and does not require any complex configuration. It is often used in shell scripts and other automation tools to simplify the process of substituting environment variables in configuration files.

### Using envsubst in Azure Deployment Pipelines

`envsubst` can be used in Azure deployment pipelines to replace environment variables in configuration files and other text documents. For example, you can use `envsubst` to replace environment variables in a Kubernetes deployment file or a configuration file for a web application.

Here are some examples of how to use `envsubst` in Azure deployment pipelines:

#### Example 1: Replacing Environment Variables in a File

Suppose you have a configuration file that contains environment variables that need to be replaced with their values. You can use `envsubst` to replace the environment variables in the configuration file:

```bash
envsubst < config.ini.template > config.ini
```plaintext

This command reads the contents of the `config.ini.template` file, replaces any environment variables in the text with their values, and writes the result to the `config.ini` file.

#### Example 2: Replacing Environment Variables in a Kubernetes Deployment File

Suppose you have a Kubernetes deployment file that contains environment variables that need to be replaced with their values. You can use `envsubst` to replace the environment variables in the deployment file:

```bash
envsubst < deployment.yaml.template | kubectl apply -f -
```plaintext

This command reads the contents of the `deployment.yaml.template` file, replaces any environment variables in the text with their values, and applies the resulting deployment configuration to the Kubernetes cluster.

#### Example 3: Replacing Environment Variables in a Web Application Configuration File

Suppose you have a configuration file for a web application that contains environment variables that need to be replaced with their values. You can use `envsubst` to replace the environment variables in the configuration file:

```bash
envsubst < app.config.template > app.config
```plaintext

This command reads the contents of the `app.config.template` file, replaces any environment variables in the text with their values, and writes the result to the `app.config` file.

### Conclusion

`envsubst` is a lightweight and easy-to-use tool that can simplify the process of replacing environment variables in text files. It is particularly useful when working with configuration files and other text documents. By using `envsubst` in your Azure deployment pipelines, you can automate the process of substituting environment variables in configuration files and make your deployments more efficient.
