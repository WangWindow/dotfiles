Set-Alias ll ls
Set-Alias code code-insiders

function set-proxy {
    git config --global http.proxy "http://127.0.0.1:7897"
    git config --global https.proxy "http://127.0.0.1:7897"
    echo "set OK!"
}

function unset-proxy {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo "unset OK!"
}

function set-vs {
    ."C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat"
}

# Install-Module -Name Terminal-Icons -Repository PSGallery
# Import-Module -Name Terminal-Icons

# oh-my-posh init pwsh --config $env:POSH_THEMES_PATH\montys.omp.json | Invoke-Expression
