#!/bin/bash
# Setup host symlinks for AI coding CLI tool credentials and git config
# Runs at container startup (supervisord priority=750)
# Only symlinks config directories/files (credentials); binaries are installed in the container

set -e

# Symlink config directories for AI coding CLI tools
for config_dir in .claude .gemini .qoder; do
    host_dir="/host-share/$config_dir"
    container_dir="/root/$config_dir"
    if [ -d "$host_dir" ]; then
        if [ -L "$container_dir" ]; then
            echo "[setup-host-symlinks] ~/$config_dir already symlinked, skipping"
        else
            rm -rf "$container_dir" 2>/dev/null || true
            ln -sf "$host_dir" "$container_dir"
            echo "[setup-host-symlinks] Linked ~/$config_dir -> /host-share/$config_dir"
        fi
    else
        echo "[setup-host-symlinks] /host-share/$config_dir not found, skipping"
    fi
done

# Symlink .gitconfig for git delegation (allows Manager to commit with correct author)
gitconfig_host="/host-share/.gitconfig"
gitconfig_container="/root/.gitconfig"
if [ -f "$gitconfig_host" ]; then
    if [ -L "$gitconfig_container" ]; then
        echo "[setup-host-symlinks] ~/.gitconfig already symlinked, skipping"
    else
        rm -f "$gitconfig_container" 2>/dev/null || true
        ln -sf "$gitconfig_host" "$gitconfig_container"
        echo "[setup-host-symlinks] Linked ~/.gitconfig -> /host-share/.gitconfig"
    fi
else
    echo "[setup-host-symlinks] /host-share/.gitconfig not found, skipping"
fi

echo "[setup-host-symlinks] Done"
