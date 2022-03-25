# Topic 1 - The Shell

## What is the shell?

* This lecture focuses on the Bourne Again SHell ("bash").
* One of the most widely used shells, and its syntax is similar to other shells'.
* To open a shell *prompt* you first need a *terminal*.

## Using the shell

* When you launch your terminal, you will see a *prompt* that looks like:

        ~/dev/projects/knowledge-share/missing-semester
        λ 

* This is the main textual interface to the shell. It can give you some information about which machine you're on, which user you are, and which directory you're in (among other things).
* You can type a *command* here (potentially with *arguments*), which will then be interpreted by the shell.
* The shell parses a command by splitting it by whitespace, then runs the program indicated by the first word, supplying each subsequent word as an *argument* that the program can access.
* If you want to provide an argument that contains spaces or other special characters, you can either quote the argument with `'` or `"`, or escape the relevant characters with `\` (`My\ Photos`).
* **The shell is a programming environment**, just like Python or Ruby. It has variables, conditionals, loops, and functions. When you run commands in your shell, you are really writing a small bit of code that your shell interprets.
* If the shell is asked to execute a command that doesn't match of its programming keywords, it consults an *environment variable* called `$PATH` that lists which directories the shell should search for programs when it is given a command.
* We can find out which file is executed for a given program name using the `which` program.
* You can bypass `$PATH` entirely by giving the *path* to the file we want to execute (e.g. `/bin/echo`).

## Navigating in the shell

* A path on the shell is a delimited list of directories separated by `/` on Linux/macOS and `\` on Windows.
* On Linux and macOS, the path `/` is the "root" of the file system. On Windows, there is a root for each disk partition (eg. `C:\`). Generally, this course assumes you're on using a Linux filesystem.
* A path that starts with `/` is called an *absolute path*. Any other path is a *relative* path.
* Relative paths are relative to the current working directory (`pwd` to check, `cd` to change).
* In a path, `.` refers to the current directory, and `..` refers to its parent directory.
* In general, when we run a program, it will operate in the current directory unless we tell it otherwise.
* Most commands accept flags and options (flags with values) that start with `-` to modify their behavior. Usually, `-h` or `--help` will print out some text telling you what flags/options are available.
* A bit about permissions - a `d` at the front indicates a directory. Then follow three groups of three characters (`rwx`). These indicate permissions the owner of the file, the owning group, and everyone else respectively have on the relevant item. A `-` indicates the given principal does not have the given permission. Nearly all the files in `/bin` have the `x` permission set for the lat group, so that anyone can execute those programs.
* Use `man` to find out more info abotu a program.

## Connecting programs

* In the shell, programs have two primary "streams" associated with them: their input stream and their output stream.
* When the program tries to read input, it reads from the input stream, and when it prints something, it prints to its output stream.
* Normally, a program's input and output are both your terminal. That is, your keyboard as input and your screen as output. However, we can rewire those strings!
* The simplest form of redirection is `< file` and `> file`. These let you rewire the input and output streams of a program to a file (respectively).

        ~/dev/projects/knowledge-share/missing-semester
        λ echo hello > hello.txt

        ~/dev/projects/knowledge-share/missing-semester
        λ cat < hello.txt

        ~/dev/projects/knowledge-share/missing-semester
        λ cat < hello.txt > hello2.txt

* You can use `>>` to append to a file.
* Where this kind of input/output really shines is in the use of *pipes*.
* The `|` operator lets you "chain" programs such that the output of one is the input of another.

        ~/dev/projects/knowledge-share/missing-semester
        λ echo hello | cat

* See the lecture on data wrangling for more!

## A versatile and powerful tool

* On most Unix-like systems, one user is special: the "root" user.
* The root user is above (almost) all access restrictions, and can create/read/update/delete any file in the system.
* You will not usually log into your system as root, since it's too easy to accidentally break something. Instead, you can use the `sudo` command.
* `sudo` lets you "do" something "as su" (short for "super user", or "root").
* One thing you need to be root for is writing to the `sysfs` file system mounted under `/sys`.
* `sysfs` exposes a number of kernel parameters as files, so that you can easily reconfigure the kernel on the fly without specialized tools. **Note that it does not exist on Windows or macOS**.
* For example, the brightness of your laptop's screen is exposed through a file called `brightness` under `/sys/class/backlight`. By writing a value into that file, we can change the screen brightness.
* One thing to keep in mind: operations like `|`, `>` and `<` are done *by the shell*, not by the individual program. If you need to `sudo` something, keep it in mind!

        ~/dev/projects/knowledge-share/missing-semester
        λ sudo echo 3 > /sys/class/backlight/thinkpad-screen/brightness
        An error occurred while redirecting file 'brightness' open: Permission denied

        ~/dev/projects/knowledge-share/missing-semester
        λ echo 3 | sudo tee /sys/class/backlight/thinkpad-screen/brightness # works!

## Next steps

* At this point you should know enough to accomplish basic tasks in the shell.
* Next lecture will go over how to perform and automate more complex tasks using the shell and the many handy command-line programs out there.
