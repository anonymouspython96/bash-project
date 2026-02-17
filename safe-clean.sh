#!/usr/bin/env bash

set -euo pipefail

readonly PROTECTED_PATHS=(
    "/"
    "/home"
    "/root"
    "/etc"
    "/usr"
    "/bin"
    "/sbin"
    "/lib"
    "/lib64"
    "/boot"
    "/dev"
    "/proc"
    "/sys"
    "/var"
)

die() {
    echo "Error: $*" >&2
    exit 1
}

usage() {
    echo "Usage: safe-clean.sh [--dry-run] [--force] <directory>" >&2
    exit 2
}

is_protected_path() {
    local path="$1"

    for protected in "${PROTECTED_PATHS[@]}"; do
        if [[ "$path" == "$protected" ]] || [[ "$path" == "$protected/"* ]]; then
            return 0
        fi
    done

    return 1
}

main() {
    local dry_run=false
    local force=false
    local target=""

    # -------- Argument Parsing --------
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run)
                dry_run=true
                ;;
            --force)
                force=true
                ;;
            --*)
                die "Unknown option: $1"
                ;;
            *)
                if [ -n "$target" ]; then
                    usage
                fi
                target="$1"
                ;;
        esac
        shift
    done

    if [ -z "$target" ]; then
        usage
    fi

    # -------- Canonical Path Resolution --------
    if ! target="$(realpath "$target" 2>/dev/null)"; then
        die "Invalid directory: $target"
    fi

    # -------- Must Be Directory --------
    if [ ! -d "$target" ]; then
        die "Not a directory: $target"
    fi

    # -------- Protected Path Check --------
    if is_protected_path "$target"; then
        die "Refusing to operate on protected path: $target"
    fi

    # -------- Empty Directory Check --------
    if [ -z "$(ls -A "$target")" ]; then
        echo "Directory is empty. Nothing to clean."
        exit 0
    fi

    # -------- Dry Run --------
    if [ "$dry_run" = true ]; then
        echo "[DRY RUN] Would remove contents of: $target"
        ls -A "$target"
        exit 0
    fi

    # -------- Confirmation (unless forced) --------
    if [ "$force" = false ]; then
        read -r -p "Are you sure you want to delete all contents of '$target'? (y/N): " answer
        if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    # -------- Deletion --------
    rm -rf -- "$target"/* "$target"/.[!.]* "$target"/..?* 2>/dev/null || true

    echo "Cleanup completed for: $target"
}

main "$@"