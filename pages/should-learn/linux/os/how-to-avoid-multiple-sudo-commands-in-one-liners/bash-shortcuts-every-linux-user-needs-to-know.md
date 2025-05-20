# Bash Shortcuts Every Linux User Needs to Know

Bash shortcuts dramatically improve efficiency for DevOps engineers working in Linux, WSL, or cloud shells (AWS, Azure, GCP). Mastering these will speed up navigation, editing, and process management in any terminal session.

---

## Essential Bash Shortcuts

| Shortcut         | Action & Example |
|------------------|-----------------|
| `Tab`            | **Auto-complete** commands, files, or directories. <br>_Example:_ Type `kubec` then `Tab` to complete to `kubectl`. |
| `Ctrl + r`       | **Reverse search** command history. <br>_Example:_ Press `Ctrl + r`, type `terraform`, find previous Terraform commands. |
| `Ctrl + a`       | Move cursor to **start of line**. |
| `Ctrl + e`       | Move cursor to **end of line**. |
| `Ctrl + u`       | **Delete** from cursor to start of line. |
| `Ctrl + k`       | **Delete** from cursor to end of line. |
| `Ctrl + w`       | **Delete word** before cursor. |
| `Alt + d`        | **Delete word** after cursor. |
| `Ctrl + b`       | Move cursor **back one character**. |
| `Ctrl + f`       | Move cursor **forward one character**. |
| `Alt + b`        | Move cursor **back one word**. |
| `Alt + f`        | Move cursor **forward one word**. |
| `Ctrl + l`       | **Clear** the terminal screen. |
| `Ctrl + c`       | **Cancel** current command/process. |
| `Ctrl + z`       | **Suspend** current process (use `fg` to resume). |
| `Ctrl + d`       | **Logout/exit** shell or delete character under cursor. |
| `Ctrl + _`       | **Undo** last edit (hold `Shift` for underscore). |
| `Ctrl + x, Ctrl + e` | **Edit current command** in `$EDITOR` (great for long or complex commands). |

---

## Bash History Navigation

- `Ctrl + p` / `Up Arrow`: Previous command
- `Ctrl + n` / `Down Arrow`: Next command
- `Ctrl + r`: Search history interactively
- `Ctrl + g`: Exit history search

---

## Process & Job Control

- `Ctrl + c`: Kill current process (SIGINT)
- `Ctrl + z`: Suspend process (background)
- `fg`: Resume suspended process
- `jobs`: List background jobs
- `kill %<job#>`: Kill background job by number

---

## Real-World DevOps Examples

### 1. Run a Command in the Background

```sh
sleep 100 &
```

### 2. View All Running Processes

```sh
ps aux | less
```

### 3. Kill a Running Process

```sh
kill $(pgrep sleep)   # Kill all sleep processes
```

### 4. Edit a Long Command in Your Editor

```sh
# Type a long command, then press Ctrl + x, Ctrl + e to open in $EDITOR
```

---

## Best Practices

- Use `Tab` completion to avoid typos and speed up navigation.
- Use history search (`Ctrl + r`) to quickly repeat complex commands (e.g., `kubectl`, `terraform`, `ansible`).
- Edit long or error-prone commands in your editor (`Ctrl + x, Ctrl + e`).
- Use job control (`&`, `fg`, `bg`, `jobs`) to multitask in the shell.
- Automate repetitive tasks with Bash aliases and functions in your `.bashrc` or `.bash_profile`.

---

## References

- [GNU Bash Manual - Command Line Editing](https://www.gnu.org/software/bash/manual/html_node/Command-Line-Editing.html)
- [Bash Shortcuts Cheat Sheet (Red Hat)](https://www.redhat.com/sysadmin/bash-shortcuts)

---

> **Tip:** Mastering Bash shortcuts is essential for productivity in cloud shells, CI/CD runners, and remote Linux servers.

---

## Add to SUMMARY.md

```markdown
- [Bash Shortcuts Every Linux User Needs to Know](pages/should-learn/linux/os/how-to-avoid-multiple-sudo-commands-in-one-liners/bash-shortcuts-every-linux-user-needs-to-know.md)
