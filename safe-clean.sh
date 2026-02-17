#!/usr/bin/env bash

set -euo pipefail

readonly PROTECTED_PATH=( 
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
    echo "Usage: safe-clean.sh [ --dry-run ] [ --force ] <directory>"
    exit 2
}

main() {
    local dry_run=false
    local force=false
    local target=""

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

    # Resolve canonical absolute path
    if ! target="$(realpath "$target" 2>/dev/null)"; then
        die "Invalid directory: $target"
    fi

    echo "Dry run: $dry_run"
    echo "Force: $force"
    echo "Target: $target"

}

main "$@"