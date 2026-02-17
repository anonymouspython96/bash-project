# safe-clean

A secure directory cleanup utility written in Bash.

## Features

- Prevents accidental deletion of critical system paths
- Supports `--dry-run` mode
- Supports `--force` mode (skip confirmation)
- Uses strict Bash mode (`set -euo pipefail`)
- Safe path canonicalization using `realpath`

## Usage

```bash
./safe-clean.sh [--dry-run] [--force] <directory>
