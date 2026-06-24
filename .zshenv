# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Fontconfig
export FONTCONFIG_PATH=/etc/fonts

# Gpu
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Qt wayland
export QT_QPA_PLATFORM="wayland;xcb"

# Editors
export EDITOR="vim"
export VISUAL="vim"

# Pager
export PAGER="less"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# less history
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Browser (fallback)
export BROWSER="zen-browser"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Other Apps
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel 
. "/home/ali/.local/share/cargo/env"
