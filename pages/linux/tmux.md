# Tmux

## _What is_ tmux? <a href="#d777" id="d777"></a>

The official verbiage describes tmux as a screen multiplexer, like GNU [Screen](https://www.gnu.org/software/screen/). That means that tmux lets you tile windowpanes in a command-line environment. This in turn allows you to run, or keep an eye on, multiple programs within one terminal.

Installing tmux:

```bash
brew install tmux
```

```bash
dnf install tmux -y
```

#### Start new named session:

`tmux new -s [session name]`

#### Detach from session:

`ctrl+b d`

#### List sessions:

`tmux ls`

#### Attach to named session:

`tmux a -t [name of session]`

#### Kill named session:

`tmux kill-session -t [name of session]`

#### Split panes horizontally:

`ctrl+b "`

#### Split panes vertically:

`ctrl+b %`

#### Kill current pane:

`ctrl+b x`

#### Move to another pane:

`ctrl+b [arrow key]`

#### Cycle through panes:

`ctrl+b o`

#### Cycle just between previous and current pane:

`ctrl+b ;`

#### Kill tmux server, along with all sessions:

`tmux kill-server`
