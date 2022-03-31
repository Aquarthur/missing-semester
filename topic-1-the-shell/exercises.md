# Exercises

## Exercise 1

For this course, you need to be using a Unix shell like Bash or ZSH. If you are on Linux or macOS, you don’t have to do anything special. If you are on Windows, you need to make sure you are not running cmd.exe or PowerShell; you can use Windows Subsystem for Linux or a Linux virtual machine to use Unix-style command-line tools. To make sure you’re running an appropriate shell, you can try the command echo `$SHELL`. If it says something like `/bin/bash` or `/usr/bin/zsh`, that means you’re running the right program.

### Solution

```sh
echo $SHELL
# prints /bin/zsh
```

## Exercise 2

Create a new directory called `missing` under `/tmp`.

### Solution

```sh
# I changed it from /tmp to ./tmp to avoid issues
mkdir -p ./tmp/missing
```

## Exercise 3

Look up the `touch` program. The `man` program is your friend.

### Solution

```sh
man touch
```

## Exercise 4

Use `touch` to create a new file called `semester` in `missing`.

### Solution

```sh
touch ./tmp/missing/semester
```

## Exercise 5

Write the following into that file, one line at a time:

```sh
#!/bin/sh
curl --head --silent https://missing.csail.mit.edu
```

The first line might be tricky to get working. It’s helpful to know that `#` starts a comment in Bash, and `!` has a special meaning even within double-quoted (`"`) strings. Bash treats single-quoted strings (`'`) differently: they will do the trick in this case. See the Bash quoting manual page for more information.

### Solution

```sh
echo '#!/bin/sh' >> ./tmp/missing/semester # alternatively, echo "#\!/bin/sh" >> ./tmp/missing/semester
echo "curl --head --silent https://missing.csail.mit.edu" >> ./tmp/missing/semester
```

## Exercise 6

Try to execute the file, i.e. type the path to the script (`./semester`) into your shell and press enter. Understand why it doesn’t work by consulting the output of `ls` (hint: look at the permission bits of the file).

### Solution

This breaks because we didn't add the `x` permission.

## Exercise 7

Run the command by explicitly starting the `sh` interpreter, and giving it the file `semester` as the first argument, i.e. `sh semester`. Why does this work, while `./semester` didn’t?

### Solution

sh is a POSIX-compliant command interpreter (shell).  It is implemented by re-execing as either bash(1), dash(1), or zsh(1) as determined by the symbolic link located at /private/var/select/sh.

With `sh`, I'm running the `sh` command, for which I have `+x` permissions, and providing the file as an argument. If I try to run locally, it will check the file's permissions which currently doesn't have +x permissions.

## Exercise 8

Look up the `chmod` program (e.g. use `man chmod`).

### Solution

```sh
man chmod
```

## Exercise 9

Use `chmod` to make it possible to run the command `./semester` rather than having to type `sh semester`. How does your shell know that the file is supposed to be interpreted using `sh`? See this page on the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) line for more information.

### Solution

```sh
chmod +x ./tmp/missing/semester
```

## Exercise 10

Use `|` and `>` to write the “last modified” date output by `semester` into a file called `last-modified.txt` in your home directory.

### Solution

```sh
./tmp/missing/semester | grep "last-modified" > ./tmp/last-modified.txt
```

## Exercise 11

Write a command that reads out your laptop battery’s power level or your desktop machine’s CPU temperature from `/sys`. Note: if you’re a macOS user, your OS doesn’t have sysfs, so you can skip this exercise.

### Solution

I'm using macOS, so skipping!
