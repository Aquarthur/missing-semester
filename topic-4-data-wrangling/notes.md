# Data Wrangling

This lecture is about massaging data, whether in text or binary format, until you end up with exactly what you wanted.

We've already seen some basic data wrangling. Anytime you use the `|` operator, you're performing some kind of data wrangling. Consider a command like `journalctl | grep -i intel`. It finds all system log entries that mention Intel (case insensitive). You may not think of it as wrangling data, but it's going from one format (your entire system log) to a format that is more useful to you (just the intel log entries). Most data wrangling is about knowing what tools you have at your disposal, and how to combine them.

To wrangle data, you need two things: data to wrangle, and something to do with it. Logs often make for a good use-case, because you often want to investigate things about them, and reading the whole thing isn't feasible.

`less` gives us a "pager" that allows us to scroll up and down through the long output.

One of the most powerful tools in your toolkit is `sed`.

* `sed` is a "stream editor" that builds on top of the old `ed` editor.
* In it, you basically give short commands for how to modify the file, rather than manipulate its contents directly (although you can do that too).
* There are tons of commands, but one of the most common is `s`: substituation. For example:

        ssh myserver journalctl
         | grep sshd
         | grep "Disconnected from"
         | sed 's/.*Disconnected from //'

What we just wrote was a simple *singular expression*, a powerful construct that lets you match against patterns. The `s` command is written on the form: `s/REGEX/SUBSTITUTION/`, where `REGEX` is the regular expression you want to search for, and `SUBSTITUTION` is the text you want to substitute matching text with.

> Vim uses syntax similar to `sed` for searching and replacing!

### Regular Expressions

Regular expressions are common/useful enough that it's worth spending the time to understand how they work. Let's start by looking at the one we used above: `/.*Disconnected from /`. Regular expressions are usually (though not always) surrounded by `/`. Most ASCII characters just carry their normal meaning, but some have "special" matching behavior (which, frustratingly, can vary between implementations of regex). Most commonly:

* `.` means "any single character" except newline
* `*` zero or more of the preceding match
* `+` one or more of the preceding match
* `[abc]` any one character of `a`, `b`, and `c`
* `(RX1|RX2)` either something that matches RX1 or RX2
* `^` start of the line
* `$` end of the line

`sed`'s regular expresssions are somewhat weird, and will require you to put a `\` before most of these to give them their special meaning. Or you can pass `-E`.

Looking back at `/.*Disconnected from /`, we see that it matches any text that starts with any number of characters, followed by the literal string "Disconnected from". Which is what we want. But beware, regular expressions are trixy! What if someone tried to log in with the username "Disconnected from"? We'd get something we didn't want.

> By default, `*` and `+` are greedy. In different implementations of regex, you can use `?` (eg. `/.?*Disconnected from /`) to make `*` and `?` non-greedy, which would solve the issue.

To "keep" data from a regex, you can use "capture groups". Any text matched by a regex surrounded by parentheses is stored in a numbered capture group. These are available in the substituion as `\1`, `\2`, etc.

Take time to learn how to use `regex`!

### Back to data wrangling

`sed` can do all sorts of other interesting things, like injecting text (with the `i` command), explicitly printing lines (with the `p` command), selecting lines by index, and lots of other things.

`sort` will sort its input. `sort -n` will sort in numberic (instead of lexicographic) order. `sort -k1,1` means "sort only by the first whitespace-separated column". The `,n` part says "sort until the `n`th field, where the default is the end of the line. `sort -r` will sort in reverse order.

`head` and `tail` grab the first `n` lines at the start/end of the file, respectively.

`uniq -c` will collapse consecutive lines that are the same into a single line, prefixed with a count of the number of occurrences.

`paste` lets you combine lines (`-s`) by a given single-character delimiter (`-d`; `,` in this case - `paste -sd,`).

### awk - another editor

`awk` is a programming language that just happens to be really good at processing text streams. There is *a lot* to say about `awk` if you were to learn it properly, but we'll just go through the basics.

`awk` programs take the form of an optional pattern plus a bloc saying what to do if the pattern matches a given line. The default patter matches all lines. Inside the block, `$0` is set to the entire line's contents, and `$1` through `$n` are set to the `n`th *field* of that line, when separated by the `awk` field separator (whitespace by default, change with `-F`). In the case of `awk '{print $2}'`, we're saying that for every line, print the contents of the second field. The stuff that goes before `{...}` is the pattern.

Read up on `awk` - it could replace `grep` and `sed` entirely!

### Analyzing data

You can do math directly in your shell using `bc`, a calculator that can read from STDIN!

        echo "1 + 1 + 1" | bc

You can use `R` and`gnuplot` to perform some simple plotting.

### Data wrangling to make arguments

Sometimes you want to do data wrangling to find things to install or remove based on some longer list. The data wrangling we've talked about can be powerful in combination with `xargs`.

### Wrangling binary data

So far, we've mostly talked about wrangling textual data, but pipes are just as useful for binary data. For example, we can use `ffmpeg` to capture an image from our camera, convert it to grayscale, compress it, send it to a remote machine over SSH, decompress it there, make a copy, and then display it:

        ffmpeg -loglevel panic -i /dev/video0 -frames 1 -f image2 -
         | convert - -colorspace gray -
         | gzip
         | ssh mymachine 'gzip -d | tee copy.jpg | env DISPLAY=:0 feh -'
