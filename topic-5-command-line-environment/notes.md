# Command-line Environment

This lecture goes through ways you can improve your workflow when using the shell. We will learn how to run several processes at the same time while keeping track of them, how to stop or pause a specific process and how to make a process run in the background.

Also, ways to improve your shell and other tools, by defining aliases and configuring them using dotfiles.

## Job Control

In some cases you'll need to interrupt a job while it is executing, for instance if a command is taking too long to complete (such as `find` with a very large directory structure). Most of the time, you can `Ctrl+C` and the command will stop. But how does this actually work and why does it sometimes fail to stop the processs?

### Killing a process

Your shell is using a UNIX communication mechanism called a *signla* to communicate information to the process. When a process receives a signal it stops its execution, deals with the signal and potentially changes the flow of execution based on the information that the signal delivered. For this reason, signals are *software interrupts*.

In our case, when typing `Ctrl+C` this prompts the shell to deliver a `SIGINT` signal to the process.

Here's a minimal Python program that captures `SIGINT` and ignores it, no longer stopping. To kill this program we can now use the `SIGQUIT` signal instead, by typing `Ctrl+\`.

```py
#!/usr/bin/env python
import signal, time

def handler(signum, time):
    print("\nI got a SIGINT, but I am not stopping")

signal.signal(signal.SIGINT, handler)
i = 0
while True:
    time.sleep(.1)
    print("\r{}".format(i), end="")
    i += 1
```

Here's what happens if we send `SIGINT` twice to this program, followed by `SIGQUIT`. Note that `^` is how `Ctrl` is displayed when typed in the terminal.

```sh
$ python sigint.py
24^C
I got a SIGINT, but I am not stopping
26^C
I got a SIGINT, but I am not stopping
30^\[1]    39913 quit       python sigint.py
```

While `SIGINT` and `SIGQUIT` are both usually associated with terminal related requests, a more generic signal for asking a process to exit gracefully is the `SIGTERM` signal. To send this signal we can use the `kill` command, eg. `kill -TERM <PID>`.

### Pausing and backgrounding processses

Signals can do other things beyond killing a process. For instance, `SIGSTOP` pauses a process. In the terminal, typing `Ctrl+Z` will prompt the shell to send a `SIGTSTP` signal, short for Terminal Stop (ie the terminal's version of `SIGSTOP`).

We can then continue the paused job in the foreground or in the background using `fg` or `bg`, respectively.

The `jobs` command lists the unfinished jobs associated with the current terminal session. You can refer to those jobs using their pid (you can use `pgrep` to find that out). More intuitively, you can also refer to a process using the percent symbol followed by its job number (displayed by `jobs`). To refer to the last backgrounded job you can use the `$!` special parameter.

One more thing to know is that the `&` suffix (eg. `echo "hello" &`) in a command will run the command in the background, giving you the prompt back, although it will still use the shell's STDOUT which can be annoying (use shell redirections in that case).

To background an already running program you can do `Ctrl+Z` followed by `bg`. Note that backgrounded processes are still children processes of your terminal and will die if you close the terminal (this will send yet another signal, `SIGHUP`). To prevent that from happening you can run the program with `nohup` (a wrapper to ignore `SIGHUP`), or use `disown` if the process has already been started. Alternatively, you can use a terminal multiplexer as we will see in the next section.

Demonstration:

```sh
$ sleep 1000
^Z
[1]  + 18653 suspended  sleep 1000

$ nohup sleep 2000 &
[2] 18745
appending output to nohup.out

$ jobs
[1]  + suspended  sleep 1000
[2]  - running    nohup sleep 2000

$ bg %1
[1]  - 18653 continued  sleep 1000

$ jobs
[1]  - running    sleep 1000
[2]  + running    nohup sleep 2000

$ kill -STOP %1
[1]  + 18653 suspended (signal)  sleep 1000

$ jobs
[1]  + suspended (signal)  sleep 1000
[2]  - running    nohup sleep 2000

$ kill -SIGHUP %1
[1]  + 18653 hangup     sleep 1000

$ jobs
[2]  + running    nohup sleep 2000

$ kill -SIGHUP %2

$ jobs
[2]  + running    nohup sleep 2000

$ kill %2
[2]  + 18745 terminated  nohup sleep 2000

$ jobs
```

A special signal is `SIGKILL` since it cannot be captured by the process and it will always terminate it immediately. However, it can have bad side effects such as leaving orphaned children processes. Laern more by typing `man signal` or `kill -l`.

## Terminal Multiplexers

When using the CLI you will often want to run more than one thing at once. For instance, you might want to run your editor and your program side by side. Although this can be achieved by opening new terminal windows, using a terminal multiplexer is a more versatile solution.

Terminal multipllexers like `tmux` allow you to multiplex terminal windows using panes and tabs so you can interact with multiple shell sessions. Moreover, terminal multiplexers let you detach a current terminal session and reattach at some point later in time. This can make your workflow much better when working with remote machines since it avoids the need to use `nohup` and similar tricks.

The most popular terminal multiplexer these days is `tmux`. `tmux` is highly configurable and by using the associated keybindings you can create multiple tabs and panes and quickly navigate through them.

`tmux` expects you to know its keybindings, and they all have the form `<Ctrl+b> x` where that means (1) press `Ctrl+b`, (2) release `Ctrl+b`, and then (3) press `x`. `tmux` has the following hierarchy of objects:

* **Sessions** - a session is an independent workspace with one or more windows
  * `tmux` starts a new session
  * `tmux new -s NAME` starts it with that name
  * `tmux ls` lists the current sessions
  * Within `tmux` typing `<Ctrl+b> d` detaches the current session
  * `tmux a` attaches the last session. You can use the `-t` to specify which session.
* **Windows** - Equivalent to tabs in editors or browsers, they are visually separate parts of the same session
  * `<Ctrl+b> c` creates a new window. To close it you can just terminal the shells doing `<Ctrl+d>`.
  * `<Ctrl+b> N` goes to the `N`th window. Note that windows are numbered.
  * `<Ctrl+b> p` goes to the previous window
  * `<Ctrl+b> n` goes to the next window
  * `<Ctrl+b> ,` renames the current window
  * `<Ctrl+b> w` lists current windows
* **Panes** - like Vim splits, panes let you have multiple shells in the same visual display.
  * `<Ctrl+b> "` Split the current pane horizontally
  * `<Ctrl+b> %` Split the current pane vertically 
  * `<Ctrl+b> <direction>` Move to the pane in the specified *direction* (arrow keys)
  * `<Ctrl+b> z` toggle zoom for the current pane
  * `<Ctrl+b> [` Start scrollback. You can then press `<space>` to start a sellection and `<enter>` to copy that selection
  * `<Ctrl+b> <space>` Cycle through pane arrangements.

Go through `tmux` tutoials to learn it. Familiarize yourself with the `screen` command.

## Aliases

It can become tiresome typing long commands that involve many flags and verbose options. For this reason, most shells support *aliasing*. An alias is a short form for another command that your shell will replace automatically for you.

They have many convenient features:

```sh
# Make shorthands for common flags
alias ll="ls -lh"

# Save a lot of typing for common commands
alias gs="git status"
alias gc="git commit"
alias v="vim"

# Save you from mistyping
alias sl=ls

# Overwrite existing commands for better defaults
alias mv="mv -i"           # -i prompts before overwrite
alias mkdir="mkdir -p"     # -p make parent dirs as needed
alias df="df -h"           # -h prints human readable format

# Alias can be composed
alias la="ls -A"
alias lla="la -l"

# To ignore an alias run it prepended with \
\ls
# Or disable an alias altogether with unalias
unalias la

# To get an alias definition just call it with alias
alias ll
# Will print ll='ls -lh'
```

Note that aliases do not persist shell sessions by default. To make an alias persistent you need to include it in shell startup files, like `.bashrc` or `.zshrc`, which we're going to introduce in the next section.

## Dotfiles

Many programs are configured using plain-text files known as *dotfiles* (names start with a `.` so they are hidden by default).

Shells are one example of programs configured with such files. On startup, your shell will read many files to load its configuration. Depending on the shell, whether you are starting a login and/or interactive the entire process can be quite complex.

For `bash`, editing your `.bashrc` or `.bash_profile` will work in most systems. Here you can include commands that you want to run on startup, like the aliases we just went over or modifications to your `PATH` variable.

Some examples of tools that can be configured through dotfiles are:

* `bash` - `.bashrc`, `.bash_profile`
* `git` - `.gitconfig`
* `vim` - `.vimrc` and `.vim/`
* `ssh` - `.ssh/config`
* `tmux` - `.tmux.conf`

You should organize your dotfiles! They should be in their own folder, under version control, and **symlinked** into place using a script. This has the benefits of:

* **Easy installation**: if you log into a new machine, applying your configs will take a sec
* **Portability**: your tools will work the same everywhere
* **Synchronization**: you can update your dotfiles anywhere and keep them all in sync
* **Change tracking**: you're probably going to be maintaining your dotfiles for your entire programming career, so version history is nice to have!

Spend time researching other people's dotfiles, the tools you're using, and use `man` pages to define your own.

### Portability

A common pain with dotfiles is that the configs might not work when working with several machines (eg different OS's). Sometimes you also want some config to be applied to a single machine.

There are several tricks for making this easier. If the configuration file supports it, use the equivalent of `if` statements to apply machine specific customizations, eg:

```sh
if [[ "$(uname)" == "Linux" ]]; then {do_something}; fi

# Check before using shell-specific features
if [[ "$SHELL" == "zsh" ]]; then {do_something}; fi

# You can also make it machine-specific
if [[ "$(hostname)" == "myServer" ]]; then {do_something}; fi
```

If the configuration file supports it, make use of includes! For example:

```sh
[include]
  path = ~/.gitconfig_local
```

And then on each machine, `~/.gitconfig_local` can contain machine-specific settings. You could even track these in their own repo!

The idea is also useful if you want different programs to share some config. For example, to load the same aliases in `zsh` and `bash`:

```sh
# Test if ~/.aliases exists and source it
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
```

## Remote Machines

It has become more and more common for programmers to use remote servers in their everyday work. If you need to use remote servers in order to deploy backend software or you need a server with higher compute power, you'll end up using a Secure Shell (SSH). As with most tools covered, SSH is highly configurable so is worth learning!

To `ssh` into a server you execute eg:

```sh
ssh foo@bar.mit.edu
```

Here we are trying to ssh as user `foo` in server `bar.mit.edu`. The server can be specified with a URL (llike `bar.mit.edu`) or an IP (something like `foobar@192.168.1.42`). Later we will see that if we modify ssh config you can access with something like `ssh bar`!

### Executing commands

An often overlooked feature of `ssh` is the ability to run commands directly. `ssh foobar@server ls` will execute `ls` in the home folder of foobar. It works with pipes, so `ssh foobar@server ls | grep PATTERN` will grep remotely the local output of `ls`.

### SSH Keys

Key-based authentication explots public-key cryptography to prove to the server that the client owns the secret private key without revealing the key. This way you do not need to reenter your password every time. Nevertheless, the private key (often `~/.ssh/id_rsa` and more recently `~/.ssh/id_ed25519`) is effectively your password, treat it like so!

#### Key Generation

To generate a key pair you can run `ssh-keygen`.

```sh
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

You should choose a passphrase, to avoid someone who gets hold of your private key accessing authorized servers. Use `ssh-agent` or `gpg-agent` so you don't have to type your passphrase every time.

To check if you have a passphrase and validate it you can run `ssh-keygen -y -f /path/to/key`.

#### Key based authentication

`ssh` will look into `.ssh/authorized_keys` to determine which clients it should let in. To copy a public key over you can use:

```sh
cat .ssh/id_ed25519.pub | ssh foobar@remote 'cat >> ~/.ssh/authorized_keys'
```

A simpler solution can be achieved with `ssh-copy-id` where available:

```sh
ssh-copy-id -i .ssh/id_ed25519 foobar@remote
```

#### Copying files over SSH

There are many ways to copy files over ssh:

* `ssh+tee`, the simplest is to use `ssh` command execution and `STDIN` input by doing `cat localfile | ssh remote_server tee serverfile`. Recall  that `tee` writes the output from STDIN to a file.
* `scp` when copying large amounts of files/directories, the secury copy `scp` is more convenient since it can easily recurse over paths. The syntax is `scp path/to/local_file remote_host:path/to/remote_file`.
* `rsync` improves upon `scp` by detecting identical files in local and remote, and preventing copying them again. It also provides more fine grained control over symlinks, permissions, and has extra features like the `--partial` flag that can resume from a previously interrupted copy. `rsync` has a similar syntax to `scp`.

#### Port Forwarding

In many scenarios you will run into software that listens to specific ports in the machine. When this happens in your local machine you can type `localhost:PORT` or `127.0.0.1:PORT`, but what do you do with a remote server that doesn't have its ports directly available through the network.internet?

This is called *port forwarding* and it comes in two flavors: **Local Port Forwarding** and **Remote Port Forwarding**. Check this [StackExchange thread](https://unix.stackexchange.com/questions/115897/whats-ssh-port-forwarding-and-whats-the-difference-between-ssh-local-and-remot) for more info.

The most common scenario is local port forwarding, where a service in the remote machine lsitens in a port and you want to link a port in your local machine to forward to the remote port. For example, if we execute `jupyter notebook` in the remote server that listens to the port `8888`. Thus, to forward that to the local port `9999`, we would do `ssh -L 9999:localhost:8888 foobar@remote_server` and then navigate to `localhost:9999` in our local machine.

#### SSH Configuration

We have covered many many arguments that we can pass. A tempting alternative is to create shell aliases. However, there is a better alternative using `~/.ssh/config`.

```sh
Host vm
    User foobar
    HostName 172.16.174.141
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 9999 localhost:8888

# Configs can also take wildcards
Host *.mit.edu
    User foobaz
```

An additional advantage of using this over aliases is that other programs like `scp`, `rsync`, `mosh`, etc are able to read it as well and convert the settings into the corresponding flags.

Note that the `~/.ssh/config` file can be considered a dotfile, but think about the info you're potentially provided strangers! Be thoughtful.

Server side configuration is usually specified in `/etc/ssh/sshd_config`. Here you can make changes like disabling password authentication, changing ssh ports, enabling X11 forwarding, etc. You can specify config settings on a per user basis.

#### Miscellaneous

A common pain when connecting to a remote server are disconnections due to shutting down/sleeping your computer or changing a network. Moreover if one has a connection with significant lag using ssh can become frustrating. `Mosh`, the mobile shell, improves upon ssh, allowing roaming connections, intermittent connectivity and providing intelligent local echo.

Sometimes it is convenient to mount a remote folder. `sshfs` can mount a folder on a remote server locally, and then you can use a local editor.

## Shells & Frameworks

During shell tool and scripting we covered `bash` because it's by far the most ubiquitous shell and most systems have it as default. Nevertheless, there are other options.

For example, the `zsh` shell is a superset of `bash` and provides many convenient features out of the box such as:

* Smarter globbing, `**`
* Inline globbing/wildcard expansion
* Spelling correction
* Better tab completion/selection
* Path expansion (`cd /u/lo/b` will expand as `/usr/local/bin`)

**Framewors** can improve your shell as well. Oh-my-zsh, prezto, and other smaller ones that focus on specific features such as zsh-syntax-highlighting. Shells like `fish` include many of these user-friendly features by default. Some of the features include:

* Right prompt
* Command syntax highlighting
* History substring search
* manpage based flag completions
* Smarter autocompletion
* Prompt themes

One thing to note is these may slow down your shell, especially if the code they run is not properly optimized or it is too much code. You can always profile it and disable the features that you do not use often or value over speed.

## Terminal Emulators

Along with customizing your shell, it's worth spending some time figuring out your choice of **terminal emulator** and its settings. There are many many terminal emulators out there.

Since you might be spending hundreds to thousands of hours in your terminal it pays off to look into its settings. Some of the aspects you may want to modify:

* Font choice
* Color scheme
* Keyboard shortcuts
* Tab/Pane support
* Scrollback configuration
* Performance
