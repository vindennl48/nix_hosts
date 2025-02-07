#!/bin/bash

echo "--> Installing Nix Host!"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Use sudo." >&2
  exit 1
fi

# Get script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
hosts_dir="$script_dir/hosts"

# Verify hosts directory exists
if [ ! -d "$hosts_dir" ]; then
  echo "Error: 'hosts' directory not found at $hosts_dir" >&2
  exit 1
fi

# List available hosts
echo "Available hosts:"
hosts_list=()
while IFS= read -r -d $'\0' dir; do
  hosts_list+=("$(basename "$dir")")
done < <(find "$hosts_dir" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)

if [ ${#hosts_list[@]} -eq 0 ]; then
  echo "No hosts found in hosts directory!" >&2
  exit 1
fi

# Display host selection menu
for i in "${!hosts_list[@]}"; do
  printf "%2d) %s\n" $((i+1)) "${hosts_list[$i]}"
done

# Get user selection
read -p "Select host (1-${#hosts_list[@]}): " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#hosts_list[@]} )); then
  echo "Invalid selection!" >&2
  exit 1
fi

selected_host="${hosts_list[$((selection-1))]}"

# Confirm selection
read -p "Install '$selected_host' configuration? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Installation aborted."
  exit 0
fi

# Create backup directory
bak_dir="/etc/nixos/bak"
echo "Creating backup directory: $bak_dir"
mkdir -p "$bak_dir"

# Backup existing files (excluding hardware-configuration.nix)
echo "Backing up existing configuration:"
find /etc/nixos -maxdepth 1 -mindepth 1 \( ! -name "hardware-configuration.nix" ! -name "bak" \) \
  -exec mv -v {} "$bak_dir" \; 2>/dev/null

# Create symlinks
host_config_dir="$hosts_dir/$selected_host"
echo "Creating symlinks for $selected_host configuration:"

find "$host_config_dir" -maxdepth 1 -mindepth 1 \( ! -name "hardware-configuration.nix" \) \
  -exec ln -svf {} /etc/nixos \;

echo "Installation complete! Verify configuration with: nixos-rebuild dry-activate"
