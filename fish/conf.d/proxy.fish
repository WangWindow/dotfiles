
function set-proxy
    set -gx http_proxy "http://127.0.0.1:7897"; set -gx https_proxy "http://127.0.0.1:7897"
    echo "http: $http_proxy"
    echo "https: $https_proxy"
end
function unset-proxy
    set -e http_proxy ; set -e https_proxy
    echo "http: $http_proxy"
    echo "https: $https_proxy"
end
function set-gproxy
    git config --global http.proxy "http://127.0.0.1:7897"
    git config --global https.proxy "http://127.0.0.1:7897"
    echo "set OK!"
end
function unset-gproxy
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo "unset OK!"
end
