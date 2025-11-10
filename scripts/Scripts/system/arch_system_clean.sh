#!/usr/bin/env bash
# Arch cleanup script

set -e

echo "=== Updating system ==="
sudo pacman -Syu

echo "=== Updating Flatpak apps (if installed) ==="
if command -v flatpak &>/dev/null; then
  flatpak update -y
else
  echo "flatpak not found, skipping."
fi

echo "=== Cleaning old package cache ==="
sudo paccache -r

echo "=== Removing orphaned packages (if any) ==="
orphans=$(pacman -Qdtq || true)
if [[ -n "$orphans" ]]; then
  sudo pacman -Rns $orphans
else
  echo "No orphans found."
fi

echo "=== Vacuuming journal to 100M ==="
sudo journalctl --vacuum-size=100M

echo "=== Cleaning AUR cache (if yay available) ==="
if command -v yay &>/dev/null; then
  yay -Sc
else
  echo "yay not found, skipping AUR cache cleanup."
fi

echo "=== Cleaning Snapper snapshots ==="
if command -v snapper &>/dev/null; then
  sudo snapper cleanup number
  sudo snapper cleanup timeline
else
  echo "snapper not found, skipping snapshot cleanup."
fi

echo "=== Done! ==="

