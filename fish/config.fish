if status is-interactive
    # Commands to run in interactive sessions can go here
end
function fish_greeting
end

alias ff fastfetch
alias zed zeditor

set -gx UV_DEFAULT_INDEX "https://mirrors.ustc.edu.cn/pypi/simple"
set -gx UV_PYTHON_INSTALL_MIRROR "https://registry.npmmirror.com/-/binary/python-build-standalone"
set -gx RUSTUP_UPDATE_ROOT "https://mirrors.ustc.edu.cn/rust-static/rustup"
set -gx RUSTUP_DIST_SERVER "https://mirrors.ustc.edu.cn/rust-static"
set -gx HF_ENDPOINT "https://hf-mirror.com"

fish_add_path "$HOME/.local/bin"

# oh-my-posh init fish --config $HOME/my.json | source
