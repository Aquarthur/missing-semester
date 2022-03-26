# Topic 2 - Shell Tolls and Scripting

## Shell Scripting

* So far we've seen how to execute commands in the shell and pipe them together. Here, we'll learn how to perform a series of commands and use control flow expressions.
* Shell scripts are the next step in complexity. Most shells have their own scripting language with variables, control flow and its own syntax.
* What makes shell scripting different from other scripting languages is that it's optimized for performing shell-related tasks.
* Creating command pipelines, saving results into files, and reading from standard input are primitives in shell scripting, making it easier to use than general purpose languages.
* This section focuses on **bash scripting**.

* To assign variables, use the syntax `foo=bar` and access the value of the variable with `$foo`. `foo = bar` will not work since it's interpreted as calling the `foo` program with `=` and `bar` as arguments.
* **In general, in shell scripts the space character will perform argument splitting**.
* Strings in bash can be defined with `'` and `"` delimiters, but they aren't equivalent. Strings with `'` are literal strings and will not substitue variable values (`echo '$foo'` prints `$foo`) where `"` strings will (`echo "$foo"` prints `bar`).

* Bash supports control flow techniques including `if`, `case`, `while`, and `for`. It also has functions that take arguments and can operate with them. Eg:

        mcd () { # creates a dir and cd's into it
          mkdir -p "$1"
          cd "$1"
        }

* Here, `$1` is the first argument to the script/function.
* Bash uses a variety of special variables to refer to arguments, error codes, and other relevant variables. Here are some of them ([here](https://tldp.org/LDP/abs/html/special-chars.html) is a more comprehensive list):
  * `$0` - name of the script
  * `$1` to `$9` - arguments to the script. `$1` is the first argument, etc.
  * `$@` - All the arguments
  * `$#` - Number of arguments
  * `$?` - Return code of the previous command
  * `$$` - Process identification number (PID) for the current script
  * `!!` - Entire last command, including arguments. A common pattern is to execute a command only for it to fail due to missing permissions; you can quickly re-execute the command with `sudo` by doing `sudo !!`
  * `$_` - Last argument from the last command. If you are in an interactive shell, you can also quickly get this value by typing `Esc` followed by `.` or `Alt+.`. (For iTerm, `Esc` then `.`).

* Commands will often return output using `STDOUT`, errors through `STDERR`, and a Return Code to report errors in a more script-friendly manner.
* The return code or exit status is the way scripts/commands have to communicate how execution went.
  * A value of 0 usually means everything went OK;
  * Anything different from 0 means an error occurred.
* Exit codes can be used to conditionally execute commands using `&&` (and operator) and `||` (or operator), both of which are **short-circuiting** operators.
* Commands can also be separated within the same line using a semicolon (`;`).
* The `true` program will always have a 0 return code and the `false` command will always have a 1 return code.
* Some examples:

        false || echo "Oops, fail"
        # Oops, fail

        true || echo "Will not be printed"
        #

        true && echo "Things went well"
        # Things went well

        false && echo "Will not be printed"
        #

        true ; echo "This will always run"
        # This will always run

        false ; echo "This will always run"
        # This will always run

* Another common pattern is wanting to get the output of a command as a variable. This can be done with *command substitution*.
  * Whenever you place `$( CMD )` is will execute `CMD`, get the output and substitute it in place.
  * For example, `for file in $(ls)`, the shell will first call `ls` and then iterate over those values.

* A lesser known feature is *process substitution*.
  * `<( CMD )` will execute `CMD` and place the output in a temporary file and substitue the `<()` with that file's name.
  * This is useful when commands expect values to be passed by file instead of by `STDIN`. For example, `diff <(ls foo) <(ls bar)` will show the differences between files in dirs `foo` and `bar`.

* That was a big info dump! Let's see an example that uses some of the features:

        # !/bin/bash
        echo "Starting program at $(date)" # Date will be substituted
        echo "Running program $0 with $# arguments with pid $$"

        for file in "$@"; do
            grep foobar "$file" > /dev/null 2> /dev/null
            # When pattern is not found, grep has exit status 1
            # We redirect STDOUT and STDERR to a null register since we do not care about them
            if [[ $? -ne 0 ]]; then
              echo "File $file does not have any foobar, adding one"
              echo "# foobar" >> "$file"
            fi
        done

* In the comparison, we tested whether `$?` was not equal to 0. Bash implements many comparisons of this sort - you can find a detailed list via `man test`.
  * When performing comparisons in bash, try to use `[[ ]]` instead of `[]`. Chances of [making mistakes are lower](http://mywiki.wooledge.org/BashFAQ/031) although it won't be portable to `sh`.
  * Short version: `[[` is newer, has more functionality, and doesn't require escaping with `\` a bunch.
  * Use the old syntax is portability/conformance to POSIX is a concern, use the new syntax otherwise.

* When launching scripts, you will often want to provide arguments that are similar. Bash has ways of making this easier by expanding expressions by carrying out filename expansion. These techniques are called shell *globbing*.
  * Wildcards - whenever you want to perform some sort of wildcard matching, you can use `?` and `*` to match one or any amount of characters respectively. For instance, given files `foo`, `foo1`, `foo2`, `foo10` and `bar`, the command `rm foo?` will delete `foo1` and `foo2` whereas rm `foo*` will delete all but `bar`.
    * Side note: `rm foo??` will remove `foo10`.
  * Curly braces `{}` - whenever you have a common substring in a series of commands, you can use curly braces for bash to expand this automatically. This helps when moving/converting files:

        convert image.{png,jpg} # expands to convert image.png  image.jpg
        cp /path/to/project/{foo,bar,baz}.sh /newpath
        mv *{.py,.sh} folder

        mkdir foo bar
        touch {foo,bar}/{a..h}
        touch foo/x bar/y
        diff <(ls foo) <(ls bar)

* Writing `bash` scripts can be tricky/unintuitive. There are tools like [`shellcheck`](https://github.com/koalaman/shellcheck) to help out.
* **Please note**: scripts don't need to be written in bash to be called from the terminal. For example:

        # !/usr/local/bin/python
        import sys
        for arg in reversed(sys.argv[1:]):
            print(arg)

* The kernel knows to execute this script with a python interpreter because we included a *shebang* line at the top of the script.
* It's good practice to write shebang lines using the `env` command that will resolve to where the command lives in the system to make it more portable.
  * To resolve the location, `env` will make use of the `PATH` environment variable.
  * For this example, we could've used `# !/usr/bin/env python` instead.

* Some differences between shell functions and scripts to keep in mind:
  * Functions have to be in the same language as the shell, while scripts can be written in any language. This is why including a shebang is important!
  * Functions are loaded once (when their definition is read). Scripts are loaded every time they're executed. This makes functions slightly faster to load, but whenever you change them you will have to reload their definition.
  * Functions are executed in the current shell environment. Scripts execute in their own process. Thus, functions can modify environment variables, whereas scripts can't. Scripts will be passed, by value, environment variables that have been exported using `export`.
  * Functions are a powerful construct to achieve modularity, code reuse, and clarity of shell code. Often, shell scripts will include their own function definitions.

## Shell tools

### Finding out how to use commands

* Given a command, how do you go about finding out what it does and its different options? You could start googling, but since UNIX predates StackOverflow, there are built-in ways of getting this info.
  * The first-order approach is to call said command with the `-h` or `--help` flags.
  * A more detailed approach is using the `man` command, which provides a manual page (called manpage) for a command you specify, eg. `man rm`.
    * Even non-native commands will have manpage entries if the developer wrote them and included them as part of the installation process.
  * For interactive tools such as the ones based on ncurses, help for the commands can often be accessed within the program using the `:help` command or typing `?`.
  * Sometimes, manpages can be **too** detailed. [TLDR pages](https://tldr.sh) are a nifty complementary solution that focuses on giving example use cases of a command so you can quickly figure out which options to use.

### Finding Files

* One of the most common repetitive tasks every programmer faces is finding files or directories. All UNIX-like systems come packaged with `find`, a great shell tool to find files. `find` will recursivelly search for files matching some criteria. Eg:

        # Find all directories named src
        find . -name src -type d
        # Find all python files that have a folder named test in their path
        find . -path '*/test/*.py' -type f
        # Find all files modified in the last day
        find . -mtime -1
        # Find all zip files with size in range 500k to 10M
        find . -size +500k -size -10M -name '*.tar.gz'

* Beyond listing files, `find` can also perform actions over files that match your query. This can be incredibly helpful to simplify monotonous tasks:

        # Delete all files with .tmp extension
        find . -name '*.tmp' -exec rm {} \;
        # Find all PNG files and convert them to JPG
        find . -name '*.png' -exec convert {} {}.jpg \;

* Despite `find`'s ubiquitousness, its syntax can sometimes be tricky to remember. For instance, to simply find files that match some pattern `PATTERN` you have to execute `find -name '*PATTERN*'` (or `-iname` if you want the pattern matching to be case insensitive).
* You could start building aliases for those scenarios, but part of the shell philosophy is that it is good to explore alternatives. Remember, one of the best properties of the shell is that you are just calling programs, so you can find replacements for some (or write one yourself!)
* For example, [`fd`](https://github.com/sharkdp/fd) is a simple, user-friendly alternatively to `find`.

* Most would agree that `find` and `fd` are good, but some might be wondering about the efficiency of looking for files every time versus compiling some sort of index or database for quickly searching. This is what `locate` is for.
* `locate` uses a database updated via `updatedb`. In most systems, `updatedb` is updated daily via `cron`. Therefore, one trade-off between the two is speed vs freshness. `locate` also only uses the file name, where `find` can find files using attributes such as size, modification time, or file permissions.

### Finding Code

* Often, you want to search based on file *content*, not just its name.
* A common scenario is wanting to search for all files that contain some pattern, along with where in those files said pattern occurs.
  * To achieve this, most UNIX-like systems provide `grep`, a generic tool for matching patterns from the input text.
  * `grep` has many flags that make it a very versatile tool. Some examples:
    * `-C` for getting **C**ontext around the matching line
    * `-v` for in**v**erting the match, ie print all lines that do **not** match the pattern.
    * `-R` will **R**ecursively go into directories and look for files for the matching string.
  * `grep -R` can be improved in many ways, such as ignoring `.git` folders, using multi-CPU support, etc. Many alternatives exist, such as `ack`, `ag`, and `rg`.

### Finding shell commands

* As you start spending more time in the shell, you may want to find specific commands you typed at some point.
  * The first thing to know is that typing the up arrow will give you back your last command, and continuing to press it will go through your shell history.

* The `history` command will let you access your shell history programmatically. It will print you shell history to the standard output.
  * If we want to search there we can pipe that output to `grep` and search for patterns, eg. `history | grep find`.

* In most shells, you can make use of `Ctrl+R` to perform backwards search through your history.
  * After pressing `Ctrl+R`, you can type a substring you want to match for commands in your history. As you keep pressing it, you will cycle through the matches in your history (`zsh` will let you do this with the up/down arrows).
  * A nice addition on top of `Ctrl+R` comes with using [`fzf`](https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings#ctrl-r) bindings. `fzf` is a general-purpose fuzzy finder that can be used with many commands. Here, it is used to fuzzily match through your history and present results in a convenient and visually pleasing manner.

* Another cool history-related trick is **history-based autosuggestions**. First introduced by the `fish` shell, this feature dynamically autocompletes your current shell command with the most recent command that you typed that shares a common prefix with it.
* You can modify your shell's history behavior, like preventing commands with a leading space from being included. This comes in handy when you are typing commands with passwords or other bits of sensitive info. To do this, add `HISTCONTROL=ignorespace` to your `.bashrc` or `setopt HIST_IGNORE_SPACE` to your `.zshrc`. Any mistakes can be scrubbed by editing `.bash_history` or `.zhistory`.

### Directory navigation

* How do you quickly navigate directories? There are many simple ways you could do this, such as writing shell aliases or creating symlinks with `ln -s`, but the truth is that developers have figured out quite clever and sophisticated solutions by now.
* Finding frequent and/or recent files and directories can be done through tools like `fasd` and `autojump`.
  * `fasd` ranks files and directories by *frecency*, that is, by both *frequency* and *recency*. By default, `fasd` adds a `z` command you can use to quickly `cd` using a substring of a *frecent* directory.
  * For example, if you often go to `/home/user/files/cool_project` you can simply use `z cool` to jump there.
  * `autojump` is similar but uses the `j` command instead!

* More complex tools exist:
  * [`tree`](https://linux.die.net/man/1/tree)
  * [`broot`](https://github.com/Canop/broot)
  * [`nnn`](https://github.com/jarun/nnn) - full fledged file manager
  * [`ranger`](https://github.com/ranger/ranger) - full fledged file manager
