# How to avoid multiple sudo commands in one-liners

We all love one-liners but soon one-liner like this will destroy the coolness of using oneliners

```

sudo apt-get update && sudo apt-get upgrade -y
```

\
Use Here strings

A here string in bash is a type of redirection that allows a string to be passed (<) to standard input (stdin) of a command. It is denoted by a << followed by a delimiter that is used to identify the end of the string. The string can span multiple lines and can contain variables and special characters. This means that we can redirect all commands to sudo at once!

_Example: one line_

This command will ask for sudo once, which makes the command sorter since we dont repeat the sudo command

```bash
$ sudo -s <<< 'apt update -y && apt upgrade -y'
```

_Example: Command span in many lines_

In case that the commands span in multiple lines we can do the following, pressing enter after the first command will not execute the command, will wait for the commands to end with the `'` character to execute them

```bash
$ sudo -s <<< 'apt update -y
> apt upgrade -y'
```

\
