function fish_greeting
end

function set-proxy
    git config --global http.proxy "http://127.0.0.1:7897"
    git config --global https.proxy "http://127.0.0.1:7897"
    echo "set OK!"
end

function unset-proxy
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo "unset OK!"
end

set -x UV_DEFAULT_INDEX 'https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple'
set -x RUSTUP_UPDATE_ROOT 'https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup'
set -x RUSTUP_DIST_SERVER 'https://mirrors.tuna.tsinghua.edu.cn/rustup'