# Working with Secrets in Source Control

The best way to avoid leaking secrets is to store them in local/private files and exclude these from git tracking with a [.gitignore](https://git-scm.com/docs/gitignore) file. E.g. the following pattern will exclude all files with the extension `.private.config`:

```
# remove private configuration
*.private.config
```

For more details on proper management of credentials and secrets in source control, and handling an accidental commit of secrets to source control.

As an extra security measure, apply credential scanning in your CI/CD pipeline.

\
