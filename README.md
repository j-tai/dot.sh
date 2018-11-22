# dot

`dot` is a small shell script that symlinks any dotfiles to another
directory. This is useful if you want to sync some of your dotfiles
with services like [Syncthing](https://syncthing.net/) or
[Dropbox](https://www.dropbox.com/).

## Getting started

First, you need to tell `dot` where your dotfiles will be
located. This is done by setting the `$DOTROOT` environment variable:

```bash
$ export DOTROOT=~/Sync/dot
```

Next, in the root directory you just specified, you should create a
file called `dotfiles`. Put one dotfile on each line; for example:

```
.bashrc
.config/mc
.emacs
.emacs.d
```

Now, simply run the shell script with no arguments.

```
$ dot
moving and symlinking ~/.bashrc
moving and symlinking ~/.config/mc
moving and symlinking ~/.emacs
moving and symlinking ~/.emacs.d
```

Now, `~/.bashrc`, `~/.config/mc`, `~/.emacs`, and `~/.emacs.d` will
all be symlinked to the respective files in your `$DOTROOT`. If any of
those files already existed, they were moved into your `$DOTROOT`.

If you ever want to add or remove a dotfile, simply add or remove an
entry from the `dotfiles` text file we created earlier, then run `dot`
again.

```
$ dot
removing ~/.emacs
removing ~/.emacs.d
moving and symlinking ~/.vimrc
```
