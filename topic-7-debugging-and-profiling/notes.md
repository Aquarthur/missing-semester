# Debugging and Profiling

A golden rule in programming is that code does not do what you expect it to do, but what you tell it to do. Bridging that gap can sometimes be diffuclt feat. In this lecture we're going to cover useful techniques for dealing with buggy and resource hungry code: debugging and profiling

## Debugging

### Printf debugging and logging

> "The most effective debugging tool is still careful thought, coupled with judiciously placed print statements" - Brian Kernighan, *Unix for Beginners*.

A first approach to debug a program is to add print statements where you have detected the problem, and keep iterating until you have extracted enough info to understand the issue.

A second approach is to use logging in your program, instead of ad hoc print statements. Logging is better than regular print statements for several reasonsL

* You can log to files, sockets, or even remote servers instead of standard output.
* Logging supports severity levels (eg. INFO, DEBUG, WARN, ERROR, etc) that allow you to filter the output accordingly.
* For new issues, there's a fair chance that your logs will contain enough information to detect what is going wrong.

One of the lecturer's favorite tips to make logs more readable is to color code them. By now you probably have realized that your terminal uses colors to make things more readable. But how? Programs like `ls` or `grep` are using ANSI escape codes, which are special character sequences to tell your shell to change the color of the output. For example, executing `echo -e "\e[38;2;255;0;0mThis is red\e[0m"` prints the message `This is read` in red on your terminal, as long as it supports true color (macOS's terminall.app doesn't). If it doesn't, use the more universally supported escape codes for 16 color choices, eg. `echo -e "\e[31;1mThis is red\e[0m"`.

The following script shows how to print many RGB colors into your terminal (again, if it supports true color):

```sh
#!/usr/bin/env bash
for R in $(seq 0 20 255); do
    for G in $(seq 0 20 255); do
        for B in $(seq 0 20 255); do
            printf "\e[38;2;${R};${G};${B}m█\e[0m";
        done
    done
done
```

### Third party logs

As you start building larger software systems you will most probably run into dependencies that run as separate programs. Web servers, databases or message brokers are common examples of this kind of dependency. When interacting with these systems it is often necessary to read their logs, since client side error messages may not suffice.

Luckily, most programs write their own logs somewhere in your system. In UNIX systems, it is commonplace for programs to write their logs under `/var/log`. For instance, the NGINX webserver places its logs under `/var/log/nginx`. More recently, systems have started using a **system log**, which is increasingly where all of your log messages go. Most (but not all) Linux systems use `systemd`, a system daemon that controls many things in your system such as which services are enabled and running. `systemd` places the logs under `/var/log/journal` in a specialized format and you can use the `journalctl` command to display the messages. Similarly, on macOS there is still `/var/log/system.log` but an increasing number of tools use the system log (that can be displayed with `log show`). On most UNIX systems you can also use the `dmesg` command to access the kernel log.

For logging under the system logs you can use the `logger` shell program. Here's an example of using `logger` and how to check that the entry made it to the system logs. Most programming languages have bindings to the system log.

```sh
logger "Hello Logs"
# On macOS
log show --last 1m | grep Hello
# On Linux
journalctl --since "1m ago" | grep Hello
```

As we saw in the data wrangling lecture, logs can be verbose and they require some level of processing and filtering to get the info you want. If you find yourself heavily filtering through `journalctl` and `log show` you can consider using their flags, which can perform a first pass of filtering of their output. There are also tools like `lnav` that provide an improved UX for viewing/navigating logfiles.

### Debuggers

When printf debugging is not enough you should use a debugger. Debuggers are programs that let you interact with the execution of a program, allowing the following:

* Halt execution of the program when it reaches a certain line.
* Step through the program one instruction at a time.
* Inspect values of variables after the program crashed.
* Conditionally halt the execution when a given condition is met.
* Much more!

Many programming languages come with some form of debugger. In Python this is the Python Debugger `pdb`.

Here is a brief description of some of the commands `pdb` supports:

* **l**(ist) - displays 11 lines around the current line or continue the previous listing
* **s**(tep) - execute the current line, stop at the first possible occasion
* **n**(ext) - continue execution until the next line in the current function is reached or it returns
* **b**(reak) - set a breakpoint (depending on the argument provided)
* **p**(rint) - evaluate the expression in the current context and print its value. There's also **pp** to display using `pprint` instead.
* **r**(eturn) - continue execution until the current function returns
* **q**(uit) - quit the debugger

Use `pdb` to fix the following buggy python code (see lecture video):

```py
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(n):
            if arr[j] > arr[j+1]:
                arr[j] = arr[j+1]
                arr[j+1] = arr[j]
    return arr

print(bubble_sort([4, 2, 1, 8, 7, 6]))
```

Note that since Python is an interpreted language we can use the `pdb` shell to execute commands and to execute instructions. `ipdb` is an improved `pdb` that uses the `IPython` REPL enabling tab completion, syntax highlighting, better tracebacks, and better introspection while retaining the same interface as `pdb`.

For more low level programming you will probably want to look into `gdb` (and its QoL modification `pwndbg`) and `lldb`. They're optimized for C-like language debugging but will let you probe pretty much any process and get its current machine state: registers, stack, program counter, etc.

### Specialized tools

Even if waht you're trying to debug is a block box binary there are tools that can help. Whenever programs need to perform actions that only the kernel can, they use *System Calls*. There are commands that let you trace the syscalls your program makes. In Linux there's `strace` and macOS/BSD have `dtrace`. `dtrace` can be tricky to use because it uses its own `D` languagem but there is a wrapper called `dtruss` that provides an interface more similar to `strace`.

Below are examples of using `strace` or `dtruss` to show `stat` syscall traces for an execution of `ls`.

```sh
# On Linux
sudo strace -e lstat ls -l > /dev/null
4
# On macOS
sudo dtruss -t lstat64_extended ls -l > /dev/null
```

Under some circumstances, you may need to look at the network packets to figure out the issue in your program. Tools like `tcpdump` and WireShark are network packet analyzers that let you read the contents of network packets and filter them based on different criteria.

For web dev, the Chrome/Firefox developer tools are handy. They feature a large number of tools, including:

* Source code - inspect the HTTML/CSS/JS sources of any website
* Live HTML, CSS, JS modification
* JS shell
* Network - analyze the requests timeline
* Storage - look into the cookies and local storage.

### Static analysis

For some issues you don't need to run any code. For example, just by carefulling reading a piece of code you could realize that your loop variable is shadowing an already existing variable or function name, or that a program reads a variable before defining it. Here is where static analysis tools come into play. Static analysis programs take source code as input and analyze it using coding rules to reason about its correctness.

For Python, you can use `pyflakes` to lint, or `mypy` that can check for typing errors. We already covered `shellcheck` which is a linting tool for shell scripts.

Most editors and IDEs support displaying the output of these tools within the editor itself, highlighting the location of warnings and errors. This is often called **code linting** and can be used to display other types of issues such as stylistic violations or insecure constructs.

In vim, the plugins `ale` or `syntastic` will let you do that. For Python, `pylint` and `pep8` are examples of stylistic linters and `bandit` is used to find common security issues. For other languages, check the "Awesome Static Analysis" and "Awesome Linters" repositories on GitHub.

A complimentary tool to stylistic linting are formatters such as `gofmt` or `prettier`. These will autoformat your code.

## Profiling

Even if your code functionally behaves as you would expect, that might not be good enough if it takes all your CPU or memory in the process. Algorithm classes often teach "Big O" notation but not how to find hot spots in your program. Since premature optimization is the root of all evil, you should learn about profilers and monitoring tools. They will help you understand which parts of your program are taking most of the time and/or resources so you can focus on optimizing those parts.

### Timing

Similarly to the debugging case, in many scenarios it can be enough to just print the time it took your code between two points. However, wall clock time can be misleading since your computer might be running other processes at the same time or waiting for events to happen. It is common for tools to make a distinction between *Real*, *User*, and *Sys* time. In general, *User + Sys* tells you how much time your process actually spent in the CPU.

* *Real* - Wall clock elapsed time from start to finish of the program, including the time taken by other processes and time taken while blocked (eg. waiting for I/O or network)
* *User* - amount of time spent in the CPU running user code
* *Sys* - amount of time spent in the CPU running kernel code

For example, try running a command that performs an HTTP request and prefixing it with `time`.

### Profilers

#### CPU

Most of the time when people refer to *profilers* they actually mean *CPU profilers*, which are the most common. There are two main types of CPU profilers: *tracing* and *sampling* profilers. Tracing profilers keep a record of every function call your program makes whereas sampling profilers probe your program periodically (commonly every millisecond) and record the program's stack. They use these records to present aggregate stats of what your program spent the most time doing.

Most programming languages have some sort of command line profiler that you can use to analyze your code. They often integrate with full fledged IDEs but for this lecture we are going to focus on the command line tools themselves.

In Python we can use the `cProfile` module to profile time per function call. Here's an example using a rudimentary grep in Python.

```py
#!/usr/bin/env python

import sys, re

def grep(pattern, file):
    with open(file, 'r') as f:
        print(file)
        for i, line in enumerate(f.readlines()):
            pattern = re.compile(pattern)
            match = pattern.search(line)
            if match is not None:
                print("{}: {}".format(i, line), end="")

if __name__ == '__main__':
    times = int(sys.argv[1])
    pattern = sys.argv[2]
    for i in range(times):
        for file in sys.argv[3:]:
            grep(pattern, file)
```

We can profile this code using the following command. Analyzing the output we can see that IO is taking most of the time and that compiling the regex takes a fair amount of time as well. Since the regex only needs to be compiled once, we can factor it out the for.

```sh
$ python -m cProfile -s tottime grep.py 1000 '^(import|\s*def)[^,]*$' *.py

[omitted program output]

 ncalls  tottime  percall  cumtime  percall filename:lineno(function)
     8000    0.266    0.000    0.292    0.000 {built-in method io.open}
     8000    0.153    0.000    0.894    0.000 grep.py:5(grep)
    17000    0.101    0.000    0.101    0.000 {built-in method builtins.print}
     8000    0.100    0.000    0.129    0.000 {method 'readlines' of '_io._IOBase' objects}
    93000    0.097    0.000    0.111    0.000 re.py:286(_compile)
    93000    0.069    0.000    0.069    0.000 {method 'search' of '_sre.SRE_Pattern' objects}
    93000    0.030    0.000    0.141    0.000 re.py:231(compile)
    17000    0.019    0.000    0.029    0.000 codecs.py:318(decode)
        1    0.017    0.017    0.911    0.911 grep.py:3(<module>)

[omitted lines]
```

A caveat of Python's `cProfile` profiler (and many profilers for that matter) is that they display time per function call. That can become unintuitive really quickly, especially if you're using 3rd party libraries in your code, since internal function calls are also accounted for. A more intuitive way of displaying profiling information is to include the time taken per line of code, which is what *line profilers* do.

For instance, the following piece of Python code performs a request to the class website and parses the response to get all URLs in the page:

```py
#!/usr/bin/env python
import requests
from bs4 import BeautifulSoup

# This is a decorator that tells line_profiler
# that we want to analyze this function
@profile
def get_urls():
    response = requests.get('https://missing.csail.mit.edu')
    s = BeautifulSoup(response.content, 'lxml')
    urls = []
    for url in s.find_all('a'):
        urls.append(url['href'])

if __name__ == '__main__':
    get_urls()
```

If we used `cProfile` we'd get over 2500 lines of output, and even with sorting it'd be hard to understand where time is being spent. A quick run with [`line_profiler`](https://github.com/pyutils/line_profiler) shows the time taken per line:

```sh
$ kernprof -l -v a.py
Wrote profile results to urls.py.lprof
Timer unit: 1e-06 s

Total time: 0.636188 s
File: a.py
Function: get_urls at line 5

Line #  Hits         Time  Per Hit   % Time  Line Contents
==============================================================
 5                                           @profile
 6                                           def get_urls():
 7         1     613909.0 613909.0     96.5      response = requests.get('https://missing.csail.mit.edu')
 8         1      21559.0  21559.0      3.4      s = BeautifulSoup(response.content, 'lxml')
 9         1          2.0      2.0      0.0      urls = []
10        25        685.0     27.4      0.1      for url in s.find_all('a'):
11        24         33.0      1.4      0.0          urls.append(url['href'])
```

#### Memory

In languages like C or C++ memory leaks can cause your program to never release memory that it doesn't need anymore. TO help in the process of memory debugging you can use tools like Valgrind that will help you identify memory leaks.

In garbage collected languages like Python it is still useful to use a memory profiler because as long as you have pointers to objects in memory they won't be garbage collected. Here's an example program and its associated output when running it with [`memory-profiler`](https://pypi.org/project/memory-profiler/) (note the decorator).

```py
@profile
def my_func():
    a = [1] * (10 ** 6)
    b = [2] * (2 * 10 ** 7)
    del b
    return a

if __name__ == '__main__':
    my_func()
```

```sh
$ python -m memory_profiler example.py
Line #    Mem usage  Increment   Line Contents
==============================================
     3                           @profile
     4      5.97 MB    0.00 MB   def my_func():
     5     13.61 MB    7.64 MB       a = [1] * (10 ** 6)
     6    166.20 MB  152.59 MB       b = [2] * (2 * 10 ** 7)
     7     13.61 MB -152.59 MB       del b
     8     13.61 MB    0.00 MB       return a
```

#### Event Profiling

As was the case for `strace` for debugging, you might want to ignore the specifics ofthe code that you are running and treat it like a black box when profiling. The `perf` command abstracts CPU differences away and does not report time or memory, but instead reports system events related to your programs. For example, `perf` can easily report poor cache locality, high amounts of page faults or livelocks. Here is an overview:

* `perf list` - list the events that can be traced with perf
* `perf stat COMMAND ARG1 ARG2` - gets counts of different events related to a process or command
* `perf record COMMAND ARG1 ARG2` - records the run of a command and saves the statistical data into a file called `perf.data`.
* `perf report` - formats and prints the data collected in `perf.data`

#### Visualization

Profiler ouput for real world programs will contain large amounts of info because of the inherent complexity of software projects. Humans are visual creatures and are quite terrible at reading large amounts of numbers and making sense of them. Thus, there are many tools for displaying a profiler's output in an easier-to-parse way.

One common way to display CPU profiling information for sampling profilers is to use a *Flame Graph*, which will display a hierarchy of function calls across the Y axis and time taken proportional to the X axis. They're also interactive, letting you zoom into specific parts of the program and get their stack traces.

Call graphs or control flow graphs display the relationships between subroutines within a program by including functions as nodes and function calls between them as directed edges. When coupled with profiling information such as the number of calls and time taken, call graphs can be quite useful for interpreting the flow of a program. In Python you can use the `pycallgraph` library to generate them.

### Resource Monitoring

Sometimes, the first step towards analyzing the performance of your program is to understand what its actual resource consumption is. Programs often run slowly when they are resource constrained, eg. without enough memory or on a slow network connection. There are a variety of CLI tools for probing/displaying different system resources.

* **General monitoring** - `htop`, which is an improved version of `top`. See also `glances` and `dstat`.
* **I/O operations** - `iotop`.
* **Disk usage** - `df` and `du`. See also `ncdu`.
* **Memory usage** - `free`.
* **Open files** - `lsof`.
* **Network connections and config** - `ss`, `ip`. `netstat` and `ifconfig` were deprecated for these tools.
* **Network usage** - `nethogs` and `iftop`.

If you want to test these tools you can also artifically impose loads on the machine using the `stress` command.

### Specialized tools

Sometimes, black box benchmarking is all you need to determine what software to use. Tools like `hyperfine` let you quickly benchmark command line programs. For instance, in the shell tools and scripting lecture we recommended `fd` over `find`. We can use `hyperfine` to compare them in the tasks we run often, eg:

```sh
$ hyperfine --warmup 3 'fd -e jpg' 'find . -iname "*.jpg"'
Benchmark #1: fd -e jpg
  Time (mean ± σ):      51.4 ms ±   2.9 ms    [User: 121.0 ms, System: 160.5 ms]
  Range (min … max):    44.2 ms …  60.1 ms    56 runs

Benchmark #2: find . -iname "*.jpg"
  Time (mean ± σ):      1.126 s ±  0.101 s    [User: 141.1 ms, System: 956.1 ms]
  Range (min … max):    0.975 s …  1.287 s    10 runs

Summary
  'fd -e jpg' ran
   21.89 ± 2.33 times faster than 'find . -iname "*.jpg"'
```

Browsers also come with a good set of tools for profiling webpage loading, letting you figure out where time is being spent.
