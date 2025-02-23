# Nix Hosts

This repo is to store various NixOS host configurations and notes about Nix.
Things can get a tad confusing so this has proven to be extremely helpful :).

## How to Install

Start a shell with git:

```
nix-shell -p git
```

Clone this repo down into your home directory:

```
cd ~
git clone https://github.com/vindennl48/nix_hosts
```

Then activate the install script:

```
cd nix_hosts
sudo chmod a+x install.sh
sudo ./install.sh
```

The script will allow you to select which host to install.

Thats it!
