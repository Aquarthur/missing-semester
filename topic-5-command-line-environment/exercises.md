# Exercises

## Job control

### Exercise 1

From what we have seen, we can use some `ps aux | grep` commands to get our jobs' pids and then kill them, but there are better ways to do it. Start a `sleep 10000` job in a terminal, background it with `Ctrl+Z` and continue its execution with `bg`. Now use `pgrep` to find its pid and `pkill` to kill it without ever typing the pid itself. (Hint: use the `-af` flags).

### Exercise 2

Say you don’t want to start a process until another completes. How would you go about it? In this exercise, our limiting process will always be `sleep 60 &`. One way to achieve this is to use the `wait` command. Try launching the sleep command and having an `ls` wait until the background process finishes.

However, this strategy will fail if we start in a different bash session, since `wait` only works for child processes. One feature we did not discuss in the notes is that the `kill` command’s exit status will be zero on success and nonzero otherwise. `kill -0` does not send a signal but will give a nonzero exit status if the process does not exist. Write a bash function called `pidwait` that takes a pid and waits until the given process completes. You should use `sleep` to avoid wasting CPU unnecessarily.

## Terminal Multiplexer

### Exercise 3

Follow this [`tmux` tutorial](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) and then learn how to do some basic customizations using [these steps](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/).

## Aliases

### Exercise 4

Create an alias `dc` that resolves to `cd` for when you mistype it.

### Exercise 5

Run `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10` to get your top 10 most used commands and consider writing shorter aliases for them. Note: if you're using `zsh`, use `history 1` instead of just `history`.

## Dotfiles

### Exercise 6

Create a folder for your dotfiles and set up version control.

### Exercise 7

Add a configuration for at least one program, e.g. your shell, with some customization (to start off, it can be as simple as customizing your shell prompt by setting `$PS1`).

### Exercise 8

Set up a method to install your dotfiles quickly (and without manual effort) on a new machine. This can be as simple as a shell script that calls `ln -s` for each file, or you could use a specialized utility.

### Exercise 9

Test your installation script on a fresh virtual machine.

### Exercise 10

Migrate all of your current tool configurations to your dotfiles repository.

### Exercise 11

Publish your dotfiles on GitHub

## Remote Machines

Install a Linux virtual machine for this exercise.

### Exercise 12

Got to `~/.ssh/` and check if you have a pair of SSH keys there. If not, generate them with `ssh-keygen -o -a 100 -t ed25519`.

### Exercise 13

Edit `.ssh/config` to have the following entry:

```sh
 Host vm
     User username_goes_here
     HostName ip_goes_here
     IdentityFile ~/.ssh/id_ed25519
     LocalForward 9999 localhost:8888
```

### Exercise 14

Use `ssh-copy-id vm` to copy your ssh key to the server.

### Exercise 15

Start a webserver in your VM by executing `python -m http.server 8888`. Access the VM webserver by navigating to `http://localhost:9999` in your machine.

### Exercise 16

Edit your SSH server config by doing `sudo vim /etc/ssh/sshd_config` and disable password authentication by editing the value of `PasswordAuthentication`. Disable root login by editing the value of `PermitRootLogin`. Restart the `ssh` service with `sudo service sshd restart`. Try sshing in again.

### Exercise 17 (Challenge)

Install `mosh` in the VM and establish a connection. Then disconnect the network adapter of the server/VM. Can mosh properly recover from it?

### Exercise 18 (Challenge)

Look into what the `-N` and `-f` flags do in `ssh` and figure out a command to achieve background port forwarding.