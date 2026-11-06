# dotfiles

Dotfiles shared between a work Mac and a personal Linux PC (dolly). `install.sh` symlinks everything into `$HOME`. This repo is **public**.

## Work settings go in `work/`, not here

Anything Multiverse-specific (work env vars, internal plugins, internal hostnames) goes in the `work/` submodule. That is the private repo `drangob/dotfiles-work`. Secrets go in neither repo: they live in `~/.zsh_secrets`, which is never committed.

`work/` is opt-in per machine. `.gitmodules` sets `update = none`, so a plain `git submodule update --init` skips it. `install.sh` asks whether to pull it, or pull it by hand with `git submodule update --init --checkout work`. If `work/` is empty on this machine, don't add work settings here instead. Tell the user.

## Changing files in `work/`

The parent pins `work/` to one commit, so every change there takes two commits:

1. In `work/`: `git -C work switch main` if it's on a detached HEAD, make the change, then commit in `work/`.
2. In the parent: `git add work && git commit -m "bump work dotfiles"`. Commit nothing else with it.

When the user asks to push, push `work/` first (`git -C work push`), then the parent. The parent must never point at a commit GitHub doesn't have.

After a pull on another machine, `git submodule update --checkout work` brings `work/` up to the pinned commit.
