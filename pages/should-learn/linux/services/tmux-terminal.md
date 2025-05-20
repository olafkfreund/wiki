# Tmux terminal

## _What is_ tmux? <a href="#d777" id="d777"></a>

The official verbiage describes tmux as a screen multiplexer, like GNU [Screen](https://www.gnu.org/software/screen/). That means that tmux lets you tile windowpanes in a command-line environment. This in turn allows you to run, or keep an eye on, multiple programs within one terminal.

---

## Installation

**macOS:**

```bash
brew install tmux
```

**Fedora/RHEL:**

```bash
dnf install tmux -y
```

**Debian/Ubuntu:**

```bash
sudo apt-get update && sudo apt-get install -y tmux
```

**NixOS (declarative):**
Add `tmux` to your `environment.systemPackages` in `/etc/nixos/configuration.nix`:

```nix
# ...existing code...
environment.systemPackages = with pkgs; [
  tmux
  # ...other packages...
];
# ...existing code...
```

Then apply the changes:

```sh
sudo nixos-rebuild switch
```

Or install for the current user only:

```bash
nix-env -iA nixos.tmux
```

---

## Common tmux Commands

#### Start new named session

`tmux new -s [session name]`

#### Detach from session

`ctrl+b d`

#### List sessions

`tmux ls`

#### Attach to named session

`tmux a -t [name of session]`

#### Kill named session

`tmux kill-session -t [name of session]`

#### Split panes horizontally

`ctrl+b "`

#### Split panes vertically

`ctrl+b %`

#### Kill current pane

`ctrl+b x`

#### Move to another pane

`ctrl+b [arrow key]`

#### Cycle through panes

`ctrl+b o`

#### Cycle just between previous and current pane

`ctrl+b ;`

#### Kill tmux server, along with all sessions

`tmux kill-server`

---

## Best Practices for DevOps

- Use named sessions for persistent workflows (e.g., `tmux new -s devops`)
- Automate tmux startup with scripts for common DevOps tasks
- Store tmux configuration in dotfiles for reproducible environments
- Use tmux with SSH for resilient remote sessions (especially in cloud/WSL)

---

## References

- [tmux GitHub](https://github.com/tmux/tmux)
- [NixOS tmux package](https://search.nixos.org/packages?channel=unstable&show=tmux)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)

> **Tip:** Combine tmux with tools like Ansible, Terraform, and cloud CLIs for efficient multi-tasking in cloud and automation workflows.
