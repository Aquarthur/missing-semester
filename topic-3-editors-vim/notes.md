# Editors (Vim)

Writing English and writing code are very different. When programming, you spend more time switching files, reading, navigating, and editing code compared to writing a long stream. It makes sense that there are specific tools for writing code vs writing English.

As programmers, we spend most of our time reading/editing code, so it's worth mastering an editor that fits your needs. Here's how you learn a new editor:

* Start with a tutorial (ie this lecture, plus resources that we point out)
* Stick with using the editor for all your text editing needs (even if it slows you down initially)
* Look things up as you go: if it seems like there should be a better way to do something, there probably is.

If you follow the above:

* In an hour or two, you'll learn basic editor functions such as opening and editing files, save/quit, and navigating buffers.
* Once you're 20 hours in, you should be as fast as you were with your old editor.
* After that, the benefits start: you'll have enough knowledge and muscle memory that using the new editor saves you time.

Modern text editors are fancy and powerful tools, so the learning never stops: you'll get even faster as you learn more.

## Which editor to learn?

Programmers have strong opinions about their text editors. According to Stack Overflow, though, Visual Studio Code is the most popular editor while Vim si the most popular command-line-based editor.

### Vim

Vim originated from the Vi editor (1976) and is still being developed today. Vim is probably worth learning even if you end up switching to another text editor.

It's not possible to teach all of Vim in 50 mins, so focus will be on philosophy, teaching the  basics, and showing some more advanced functionality.

## Philosophy of Vim

When  programming, you spend most of your time reading/editing, not writing. For this reason, Vim is a *modal* editor: it has different modes for inserting text vs manipulating text.

Vim is programmable, and Vim's interface itself is a programming language: keystrokes (with mnemonic names) are commands, and these commands are composable.

Vim avoids the use of the mouse, because it's too slow. It even avoids using arrow keys because it requires too much movement.

The end result is an editor that can match the speed at which you think.

## Modal editing

Vim's design is based on the idea that a lot of programmer time is spent reading, navigating, and making small edits, as opposed to writing long streams of text. For this reason, Vim has multiple operating modes:

* **Normal**: for moving around a file and making edits
* **Insert**: for inserting text
* **Replace**: for replacing text
* **Visual** (plain, line, or block): for selecting blocks of text
* **Command-line**: for running a command

Keystrokes have different meanings in different operating modes. For example, in Insert mode, `x` will just insert a literal character 'x', but in Normal mode, it will delete the character under the cursor, and in Visual mode, it will delete the selection.

In its default configuration, Vim shows the current mode in the bottom left. The initial/default mode is Normal mode. You'll generally spend most of your time between Normal mode and Insert mode.

You change modes by pressing `Esc` to switch from any mode back to Normal mode. From normal mode, enter:

* Insert mode with `i`,
* Replace mode with `R`,
* Visual mode with `v`,
* Visual Line mode with `V`,
* Visual Block mode with `Ctrl-V`, and
* Command-line mode with `:`.

You use the `Esc` key a lot in Vim - consider remapping Caps Lock to Escape!

## Basics

### Inserting text

From Normal mode, press `i` to enter Insert mode. In Insert mode, Vim behaves like any other text editor, until you press `Esc` to return to Normal mode. This, along with the basics explained above, are all you need to start editing files using Vim (though not particularly efficiently).

### Buffers, tabs, and windows

Vim maintains a set of open files called *buffers*. A Vim session has a number of tabs, each of which has a number of windows (split panes). Each window show a single buffer. Unlike other programs, there is not a 1-to-1 correspondence between buffers and windows; windows are merely views. A given buffer may be open in *multiple* windows, even within the same tab. This can be quite handy, for example, to view two different parts of a file at the same time.

By default, Vim opens with a single tab, which contains a single window.

### Command-line

Command mode can be entered by typing `:` in Normal mode. Your cursor will jump to the command line at the bottom of the screen upon pressing `:`. This mode has many functionalities, including opening, saving, and closing files (and quitting Vim!).

* `:q` quit (close window)
* `:w` save ("write")
* `:wq` save and quit
* `:e {name of file}` open file for editing
* `:ls` show open buffers
* `:help {topic}` open help
  * `:help :w` opens help for the `:w` command
  * `:help w` opens help for the w movement

## Vim's Interface is a programming language

The most important idea in Vim is that Vim's interface itself is a programming language. Keystrokes (with mnemonic names) are commands, and these commands *compose*. This enables efficient movement and edits, especially once muscle memory kicks in.

### Movement

You should spend most of your time in Normal mode, using movement commands to navigate the buffer. Movements in Vim are also called *nouns*, because they refer to chunks of text.

* Basic movement: `hjkl` (left, down, up, right)
* Words: `w` (next word), `b` (beginning of word), `e` (end of word)
* Lines: `0` (beginning of line), `^` (first non-blank character), `$` (end of line)
* Screen: `H` (top of screen), `M` (middle of screen), `L` (bottom of screen)
* Scroll: `Ctrl+u` (up), `Ctrl-d` (down)
* File: `gg` (beginning of file), `G` (end of file)
* Line numbers: `:{number}<CR>` or `{number}G` (line {number})
* Misc: `%` (corresponding item)
* Find: `f{character}`, `t{character}`, `F{character}`, `T{character}`
  * find/to forward/backward {character} on the current line
  * `,`/`;` for navigating matches
* Search: `/{regex}`, `n`/`N` for navigating matches

### Selection

Visual modes:

* Visual: `v`
* Visual Line: `V`
* Visual Block: `Ctrl-v`

Use movement keys to make selection.

### Edits

Everything that you used to do with the mouse, you now do with the keyboard using editing commands that compose with movement commands. Here's where Vim's interface starts to look like a programming language. Vim's editing commands are also called *verbs*, because verbs act on nouns.

* `i` enter Insert mode
  * but for manipulating/deleting text, want to use something more than backspace
* `o`/`O` insert line below/above.
* `d{motion}` delete {motion}
  * eg. `dw` is delete word, `d$` is delete to end of line, `d0` is delete to beginning of line
* `c{motion}` change {motion}
  * eg. `cw` is change word
  * like `d{motion}` followed by `i`
* `x` delete character (equal to `dl`)
* `s` substitute character (equal to `xi`)
* Visual mode + manipulation
  * select text, `d` to delete it or `c` to change it
* `u` to undo, `Ctrl-r` to redo
* `y` to copy/"yank" (some other commands like `d` also copy)
* `p` to paste
* Lots more to learn: eg. `~` flips the case of a character

### Counts

You can combine nouns and verbs with a count, which will perform a given action a number of times.

* `3w` move 3 words forward
* `5j` move 5 lines down
* `7dw` delete 7 words

### Modifiers

You can use modifiers to change the meaning of a noun. Some modifiers are `i`, which means inner" or "inside", and `a`, which means "around".

* `ci(` change the contents inside the current pair of parentheses
* `ci[` change the contents inside the current pair of square brackets
* `da'` delete a single-quoted string, including the surrounding single quotes

## Demo

Watch the lecture to see the demo.

## Customizing Vim

Vim is customized through a plain-text configuration file in `~/.vimrc` (containing Vimscript commands). There are probably lots of basic settings that you want to turn on.

This course provides a starting config to download and use.

Vim is heavily customizable, and it's worth spending time exploring your options.

## Extending Vim

There are tons of plugins for extending Vim. Contrary to outdated advice that you might find on the internet, you do *not* need to use a plugin manager for Vim (since 8.0). Instead, you can use the built-in package management system. Simply create the directory `~/.vim/pack/vendor/start/` and put plugins in there via `git clone`.

Some of their favorite plugins:

* `ctrlp.vim` - fuzzy file finder
* `ack.vim` - code search
* `nerdtree` - file explorer
* `vim-easymotion` - magic motions

Check `vim-awesome` for more Vim plugins!

## Vim-mode in other programs

Many tools support Vim emulation.

### Shell

If you're a Bash user, use `set-o vi`. If you use Zsh, `bindkey -v`. No matter what shell you use, you can `export EDITOR=vim`. This is the environment variable used to decide which editor is launched when a program wants to start an editor.

### Readline

Many programs use the GNU Readline library for their command-line interface. Readline supports (basic) Vim emulation too, which can be enabled by adding the following line to the `~/.inputrc` file:

```sh
set editing-mode vi
```

With this setting, for example, the Python REPL will support Vim bindings.

### Others

There are vim keybinding extensions for web browsers, jupyter notebooks, IDEs, etc.

## Advanced Vim

### Search and replace

`:s` (substitute) command

* `%s/foo/bar/g`
  * replace foo with bar globally in file
* `%s/\[.*\](\(.*\_))/\1/g`
  * replace named Markdown links with plain URLs

### Multiple windows

* `:sp` / `:vsp` to split windows
* Can have multiple views of the same buffer

### Macros

* `q{character}` to start recording a macro in register `{character}`
* `q` to stop recording
* `@{character}` replays the macro
* Macro execution stops on error
* `{number}@{character}` executes a macro {number} times
* Macros can be recursive
  * first clear the macro with `q{character}q`
  * record the macro, with `@{character}` to invoke the macro recursively (will be a no-op until recording is complete)
