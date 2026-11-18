#!/usr/bin/env bash
# Regenerate grammars.json for the Helix revision pinned in default.nix
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
flake="$(git -C "$dir" rev-parse --show-toplevel)"

src="$(nix build --no-link --print-out-paths "$flake#helix-git.unwrapped.src")"

nix shell --inputs-from "$flake" nixpkgs#nurl nixpkgs#nix-prefetch-git nixpkgs#python3 -c \
  python3 -I "$dir/generate-grammars.py" "$src/languages.toml" "$dir/grammars.json"
