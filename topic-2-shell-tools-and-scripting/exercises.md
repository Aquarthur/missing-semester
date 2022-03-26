# Exercises

## Exercise 1

Read `man ls` and write  an `ls` command that lists files in the following manner:

* Includes all files, including hidden files
* Sizes are listed in human readable format (e.g. 454M instead of 454279954).
* Files are ordered by recency
* Output is colorized

### Solution

* `-a` includes hidden files.
* `-l` includes information additional info about the file, include size, permissions, and last modification time.
* `-h`, when used with `-l`, uses unit suffixes: Byte, Kylobyte, Megabyte, etc.
* `-t` sorts by time modified.
  * `-U` uses time of of file creation, maybe use this one?
* To colorize, set `-G`. It's equivalent to defining CLICOLOR in the environment, which uses LSCOLORS to color `ls` output. To set the `LSCOLORS` environment, use the guide below.
  * `LSCOLORS` is a string with 11 properties that each include 2 charactes - the first for foreground color, the second for background color. These are the properties, in order:
    1. directory. Default is 'ex' - blue foreground, default background.
    2. symbolic link. Default is 'fx' - magenta foreground, default background.
    3. socket. Default is 'cx' - green foreground, default background.
    4. pipe. Default is 'dx' - brown foreground, default background.
    5. executable. Default is 'bx' - red foreground, default background.
    6. block special. Default is 'eg' - blue foreground, cyan background.
    7. character special. Default is 'ed' - blue foreground, brown background.
    8. executable with setuid bit set. Default is 'ab' - black foreground, red background.
    9. executable with setgid bit set. Default is 'ag' - black foreground, cyan background.
    10. directory writable to others, with sticky bit. Default is 'ac' - black foreground, green background.
    11. directory writable to others, without sticky bit. Default is 'ad' - black foreground, brown background.

The command below will fulfill all the conditions and color directories as red (I've kept the other values as default).

```sh
LSCOLORS="bxfxcxdxbxegedabagacad" ls -althG
```

## Exercise 2

Write bash functions `marco` and `polo` that do the following. Whenever you execute `marco` the current working directory should be saved in some manner, then when you execute `polo`, no matter what directory you are in, `polo` should `cd` you back to the directory where you executed `marco`. For ease of debugging you can write the code in a file `marco.sh` and (re)load the definitions to your shell by executing `source marco.sh`.

### Solution

See `marco.sh`.

## Exercise 3

Say you have a command that fails rarely. In order to debug it you need to capture its output but it can be time consuming to get a failure run. Write a bash script that runs the following script until it fails and capture its standard output and error streams to files and prints everything at the end. Bonus points if you can also report how many runs it took for the script to fail.

```sh
#!/usr/bin/env bash

n=$(( RANDOM % 100 ))

if [[ n -eq 42 ]]; then
  echo "Something went wrong"
  >&2 echo "The error was using magic numbers"
  exit 1
fi

echo "Everything went according to plan"
```

### Solution

The above script was stored in `magic-number.sh`. The solution is in `exercise-3.sh`. Use `source <script>` to (re)load them in your current shell.

## Exercise 4

As we covered in the lecture `find`'s `-exec` can be very powerful for performing operations over the files we are searching for. However, what if we want to do something with **all** the files, like creating a zip file? As you have seen so far commands will take input from both arguments and STDIN. When piping commands, we are connecting STDOUT to STDIN, but some commands like `tar` take inputs from arguments. To bridge this disconnect there's the `xargs` command which will execute a command using STDIN as arguments. For example `ls | xargs rm` will delete the files in the current directory.

Your task is to write a command that recursively finds all HTML files in the folder and makes a zip with them. Note that your command should work even if the files have spaces (hint: check `-d` flag for `xargs`).

If you're on macOS, note that the default BSD `find` is different from the one included in `GNU coreutils`. You can use `-print0` on `find` and the `-0` flag on `xargs`. As a macOS user, you should be aware that command-line utilities shipped with macOS may differ from the GNU counterparts; you can install the GNU versions if you like by using brew.

### Solution

Using `-print0` and `-0` means we can accept filenames with spaces. `-print0` tells `find` to print the pathname of the current file to stdout, followed by an ASCII NUL character. `-0` tells `xargs` to expect ASCII NUL characters as separators, instead of spaces and newlines.

```sh
find . -type f -name '*.html' -print0 | xargs -0 tar -czf out.tar.gz
```

## Exercise 5

(Advanced) Write a command or script to recursively find the most recently modified file in a directory. More generally, can you list all files by recency?

### Solution

#### Using `ls`

```sh
# Using this command, ls will print out everything by time modified sorted in descending order and add `/` as a suffix for directories
# grep will then remove any of `ls`'s outputs with `/` in it.
# Use a combination of `head` and `tail` to ignore the `total` line included by ls -l
ls -tlp | grep -v / | head -2 | tail -1
```

#### Using `find`

I tried to format the date from the `stat` command by using eg `stat -t '%d/%m/%Y %H:%M' -f '%Sm %N'`, but couldn't figure out how to sort properly using those formatted dates. Sticking with the unix timestamp since it's easier to sort.

```sh
find ~/Downloads -type f -print0 | xargs -0 stat -f '%m %N' | sort -r
```
