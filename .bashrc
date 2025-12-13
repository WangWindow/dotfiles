#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export QT_AUTO_SCREEN_SCALE_FACTOR=1
export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:$XDG_DATA_DIRS
export PATH=$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH
export UV_DEFAULT_INDEX='https://mirrors.ustc.edu.cn/pypi/simple'
export RUSTUP_UPDATE_ROOT='https://mirrors.ustc.edu.cn/rust-static/rustup'
export RUSTUP_DIST_SERVER='https://mirrors.ustc.edu.cn/rust-static'
export DOTNET_CLI_TELEMETRY_OPTOUT=1

#eval "$(oh-my-posh init bash --config $HOME/my.json)"

if [[ -e "/usr/bin/fish" \
      && $(ps --no-header --pid=$PPID --format=comm) != "fish" \
      && -z ${BASH_EXECUTION_STRING} \
      && (${SHLVL} < 5) ]]
then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish $LOGIN_OPTION
fi
