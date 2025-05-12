# WSL2

### Prerequisites <a href="#prerequisites" id="prerequisites"></a>

You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11 to use the commands below. If you are on earlier versions, please see [the manual install page](https://learn.microsoft.com/en-us/windows/wsl/install-manual).

### Install WSL command <a href="#install-wsl-command" id="install-wsl-command"></a>

You can now install everything you need to run WSL with a single command. Open PowerShell or Windows Command Prompt in **administrator** mode by right-clicking and selecting "Run as administrator", enter th`e wsl --install` command, then restart your machine.

PowerShellCopy

```powershell
wsl --install
```plaintext

This command will enable the features necessary to run WSL and install the Ubuntu or Fedora distribution of Linux.
