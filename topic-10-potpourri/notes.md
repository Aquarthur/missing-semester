# Potpourri

## Keyboard remapping

As a programmer, your keyboard is your main input method. As with anything else on your computer, it's configurable.

The most basic change is to remap keys. This usually involves some software that is listening and, whenever a certain key is pressed, intercepts the event and replaces it with another event corresponding to a different key. Eg:

* Remap Caps Lock to Ctrl or Escape. The course highly encourages this setting since Caps Lock has a very convenient location but is rarely used.
* Remapping PrtSc to Play/Pause music. Most OSes have play/pause keys.
* Swapping Ctrl and the Meta (Windows or Command) key.

You can also map keys to arbitrary commands of your choosing. This is useful for common tasks that you perform. Here, the software listens for a specific key combo and executes some script when that even is detected:

* Open a new terminal or browser window
* Insert some specific text, eg. your long email address
* Sleeping the computer or displays

There are even more complex mods you can configure:

* Remapping sequences of keys, eg. pressing shift five times toggles Caps Lock
* Remapping on top vs on hold, eg Caps Lock key is remapped to Esc if you quickly tap it, but is remapped to Ctrl if you hold it and use it as a modifier.
* Having remaps being keyboard or software specific.

Some software resources to get started:

* macOS - [karabiner-elements](https://pqrs.org/osx/karabiner/), [skhd](https://github.com/koekeishiya/skhd) or [BetterTouchTool](https://folivora.ai/)
* Linux - [xmodmap](https://wiki.archlinux.org/index.php/Xmodmap) or [Autokey](https://github.com/autokey/autokey)
* Windows - Builtin in Control Panel, [AutoHotkey](https://www.autohotkey.com/) or [SharpKeys](https://www.randyrants.com/category/sharpkeys/)
* If your keyboard supports custom firmware you can use [QMK](https://docs.qmk.fm/) to configure the hardware device itself so the remaps work on any machine.

## Daemons

You are probably already familiar with the notion of daemons, even if the word seems new. Most computers have a series of processes that are always running in the background rather than waiting for a user to launch them and interact with them. These processes are called daemons and the programs that run as daemons often end with a `d` to indicate so. For example, `sshd`, the SSH daemon, is the program responsible for listening to incoming SSH requests and checking that the remote user has the necessary credentials to log in.

In Linux, `systemd` (the system daemon) is the most common solution for running and setting up daemon processes. You can run `systemctl status` to list the current running daemons. Most of them might sound unfamiliar but are responsible for core parts of the system such as managing the network, solving DNS queries or displaying the graphical interface for the system. Systemd can be interacted with the `systemctl` command in order to `enable`, `disable`, `start`, `stop`, `restart` or check the `status` of services.

More interestingly, `systemd` has a fairly accessible interface for configuring and enabling new daemons (or services). Below is an example of a daemon for running a simple Python app.

```
# /etc/systemd/system/myapp.service
[Unit]
Description=My Custom App
After=network.target

[Service]
User=foo
Group=foo
WorkingDirectory=/home/foo/projects/mydaemon
ExecStart=/usr/bin/local/python3.7 app.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Also, if you just want to run some program with a given frequency there's no need to build a custom daemon. You can use `cron`, a daemon your system already runs to perform scheduled tasks.

## FUSE

Modern software systems are usually composed of smaller building blocks that are composed together. Your OS supports using different filesystem backends because there is a common language of what operations a filesystem supports. For instance, when you run `touch` to create a file, it performs a system call to the kernel to create the file and the kernel performs the appropriate filesystem call to create the given file. A caveat is that UNIX filesystems are traditionally implemented as kernel modules and only the kernel is allowed to perform filesystem calls.

*FUSE* (filesystem in User Space) allows filesystems to be implemented by a user program. FUSE lets users run user space code for filesystem calls and then bridges the necessary calls to the kernel interfaces. In practice, this means that users can implement arbitrary functionality for filesystem calls.

For exaple, FUSE can be used so whenever you perform an operation in a virtual filesystem, that operation is forwarded through SSH to a remote machine, performed there, and the output is returned back to you. This way, local programs can see the file as if it was in your computer while in reality it's in a remote server. This is effectively what `sshfs` does.

Some interesting examples of FUSE filesystems:

* `sshfs` - open remote files/folder locally through an SSH connection
* `rclone` - mount cloud storage services like Dropbox/Drive/S3 and open data locally.
* `gocryptfs` - encrypted overlay system. Files are stored encrypted but once the FS is mounted they appear as plaintext in the mountpoint
* `kbfs` - distributed filesystem with E2E encryption. You can have private, shared and public folders.
* `borgbackup` - mount your deduplicated, compressed and encrypted backups for ease of browsing.

## Backups

* Any data that isn't backed up is data that could be gone at any moment, forever.
* It's easy to copy  data around, it's hard to reliably backup data.
* A copy of the data in the same disk is not a backup.
* An external drive in your home is also a weak backup since it could be lost in a fire/robbery/etc.
* An off-site backup is a recommended practice.
* Synchronization solutions are not backups. When data is erased or corrupted they propagate the change.
* For the same reason, disk mirroring solutions like RAID are not backups.
* Some core features of good backup solutions are versioning, deduplication and security.
* Versioning backups ensure that you can access your history of changes and efficiently recover files.
* Deduplication is used to only store incremental changes and reduce storage overhead (and increase efficiency!).
* With security, you should ask yourself what someone would need to know/have in order to read your data, and more importantly, to delete your data and associated backups.
* Blindly trusting backups is a terrible idea and you should verify that you can use them to recover data regularly.
* Backups go beyond local files on your computer. Large amounts of data are stored in the cloud (eg. email, social media photos, etc). Having an offline copy of this info is the way to go. Find online tools to help with this.

## APIs

You can use APIs that let you programmatically access data and accomplish tasks *remotely*. Most of these APIs have a similar format. They are structured URLs, where the path and query parameters indicate what data you want to read or what action you want to perform. The response is usually a JSON, which you can then process via a tool like `jq` to massage into what you care about.

Some APIs require authentication, and this usually takes the form of some sort of secret *token* you need to include in the request headers. You should read the API's documentation to find out exact details, but **OAuth** is a protocol you'll see often.

At its heart, OAuth is a wayto give tokens that can "act as you" on a given service, and can only be used for particular purposes. Keep in mind these tokens are *secret* - anyone who gains access to them can do whatever your the token is allowed to be used for!

[IFTTT](https://ifttt.com/) is a website and service centered around the idea of APIs. Check it out!

## Common CLI flags/patterns

* Most tools support some kind of `--help` flag
* Many tools that can cause irrevocable change support the notion of a "dry run" in which they only print what they *would have done*, but don't actually perform the change. Similarly, they often have an "interactive" flag that will prompt you for each destructive action.
* You can usually use `--version` or `-V`.
* Almost all tools have a `--verbose` or `-v` flag. Similarly, many tools have a `--quiet` flag.
* In many tools, `-` in place of a file name means "standard input" or "standard output" depending on the argument.
* Possibly destructive tools are generally not recursive by default, but support a recursive flag (usually `-r`) to make them recurse.
* Sometimes you want to pass something that *looks* like a flag as a normal argument. For example, imagine you wanted to remove a file called `-r`. Or you want to run one program "through" another, like `ssh machine foo`, and you want to pass a flag to the "inner" program (`foo`). The special argument `--` makes a program *stop* processing flags and options (things start with `-`) in what follows, letting you pass things that look like flags without them being interpreted as such: `rm -- -r` or `ssh machine --for-ssh -- foo --for-foo`.

## Window managers

You're most likely using a "drag and drop" window manager, like what Windows, macOS and Ubuntu use by default (called a *floating* window manager). There are many others, especially on Linux.

A common alternative is a *tiling* window manager. In these, windows never overlap, and are instead arranged as tiles on your screen, sort of like panes in `tmux`. With a tiling window manager, the screen is always filled by whatever windows are open, arranged according to some *layout*. One window takes up the full screen. If another is opened, the original window shrinks to make room for it. If a third is opened, the other windows will again shrink to accommodate the new window. Just like with `tmux` panes, you can navigate around, resize, and move these tiled windows with just your keyboard.

## VPNs

A VPN, in the best case, is *really* just a way for you to change your ISP as far as the internet is concerned. All your traffic will look like it's coming from the VPN provider instead of your "real" location, and the network you're connected to will only see encrypted traffic.

While that may seem attractive, all you're really doing is shifting your trust from your current ISP to the VPN hosting company. Whatever your ISP *could* see, the VPN provider now sees instead. At an airport, it may make sense, but at home, the trade-off isn't as clear.

You should also know that these days, much of your traffic (at least of a sensitive nature) is *already* encrypted through HTTPS or TLS more generally. In that case, it usually matters klittle whether you're on a "bad" network or not - the network operator will only learn what servers you talk to, but nothing about the data being exchanged.

It isn't unheard of for VPN providers to accidentally misconfigure their software so the encryption is weak or disabled. Some VPN providers are malicious or opportunist, and will log/sell your traffic.

If you going to roll your own VPN, give [WireGuard](https://www.wireguard.com/) a look.

## Markdown

Not going to take notes about this section, but essentially - use Markdown.

## Hammerspoon (desktop automation on macOS)

[Hammerspoon](https://www.hammerspoon.org/) is a desktop automation framework for macOS. It letsyou write Lua scripts that hook into OS functionality, allowing you to interact with the keyboard/mouse, windows, displays, filesystem and much more.

Some examples of things you can do:

* Bind hotkeys to move windows to specific locations
* Create a menu bar button that automatically lays out windows in a specific layout
* Mute your speaker when you arrive somewhere (by detecting the WiFi network)
* Show a warning if you've taken the wrong power supply.

At a high level, Hammerspoon lets you run arbitrary Lua code, bound to menu buttons, key presses or events, and Hammerspoon provides an extensive library for interacting with the system, so there's basically no limit to what you can do with it.

## Booting + Live USBs

When your machine boots up, before the OS is loaded, the BIOS/UEFI initializes the system. During this process, you can press a key combination to configure this layer of software.

Live USBs are USB flash drives containing an OS. You can create one of these by downloading an OS and burning it to the flash drive.

## Docker, Vagrant, VMs, CLoud, OpenStack

VMs and similar tools like containers let you emulate a whole computer system, including the OS. This can be useful for creating an isolated environment for testing, development, or exploration.

Vagrant is a tool that lets you describe machine configurations (OS, services, packages, etc.) in code, and then instantiate VMs with a simple `vagrant up`. Docker is conceptually similar but uses containers instead.

You can also rent VMs on the cloud. AWS, GCloud, Azure, DigitalOcean, etc.

## Notebook Programming

Notebook programming environments can be really handy for doing certain types of interactive or exploratory development. Perhaps the most popular notebook programming environment today is Jupyter, for Python.

## GitHub

Gist of this is: use GitHub to discover and contribute to projects.
