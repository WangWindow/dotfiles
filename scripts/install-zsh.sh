#!/bin/bash

set -e

echo "🚀 欢迎使用 Zsh + Oh My Zsh 一键配置脚本（无 Powerlevel10k）"
echo "💡 请根据你的系统类型选择对应的选项："

PS3="请选择你的系统类型 [1-5]: "

select SYSTEM_TYPE in \
  "Debian/Ubuntu 系 (apt)" \
  "RedHat/CentOS/Fedora 系 (yum/dnf)" \
  "Arch/Manjaro 系 (pacman)" \
  "openSUSE/SLE 系 (zypper)" \
  "macOS (Homebrew)"; do

  case $REPLY in
    1|2|3|4|5)
      echo "✅ 已选择: $SYSTEM_TYPE"
      break
      ;;
    *)
      echo "❌ 无效选项，请输入 1-5。"
      ;;
  esac
done

# 禁止 root 运行（macOS 除外，但也不推荐）
if [ "$EUID" -eq 0 ]; then
  echo "⚠️  请勿以 root 用户运行此脚本。"
  exit 1
fi

# 初始化命令
UPDATE_CMD=""
INSTALL_CMD=""

case $REPLY in
  1) # Debian/Ubuntu
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install -y"
    ;;
  2) # RedHat/CentOS/Fedora
    if command -v dnf >/dev/null 2>&1; then
      UPDATE_CMD=":"
      INSTALL_CMD="sudo dnf install -y"
    else
      UPDATE_CMD=":"
      INSTALL_CMD="sudo yum install -y"
    fi
    ;;
  3) # Arch/Manjaro
    UPDATE_CMD="sudo pacman -Sy --noconfirm"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    ;;
  4) # openSUSE/SLE
    UPDATE_CMD="sudo zypper refresh"
    INSTALL_CMD="sudo zypper install -y"
    ;;
  5) # macOS
    echo "🍎 检测到 macOS"

    # 安装 Homebrew（如未安装）
    if ! command -v brew >/dev/null 2>&1; then
      echo "📥 正在安装 Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # 加载 brew 环境（兼容 Apple Silicon 和 Intel）
      eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi

    UPDATE_CMD="brew update --quiet"
    INSTALL_CMD="brew install --quiet"
    ;;
  *)
    echo "❌ 未知选项，退出。"
    exit 1
    ;;
esac

# 安装依赖
if [ "$REPLY" -eq 5 ]; then
  echo "📥 安装 Git（Zsh 通常已预装在 macOS）..."
  $UPDATE_CMD
  $INSTALL_CMD git
else
  echo "📥 安装 zsh, git, curl..."
  $UPDATE_CMD
  $INSTALL_CMD zsh git curl
fi

# 安装 Oh My Zsh（使用国内镜像加速）
echo "📥 安装 Oh My Zsh..."
sh -c "$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)" "" --unattended

# 安装插件
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
echo "🔌 安装插件..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone --depth=1 https://gh.llkk.cc/https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || \
  git clone --depth=1 https://github.moeyy.xyz/https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone --depth=1 https://gh.llkk.cc/https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || \
  git clone --depth=1 https://github.moeyy.xyz/https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 生成 .zshrc
ZSHRC="$HOME/.zshrc"
[ -f "$ZSHRC" ] && cp "$ZSHRC" "$ZSHRC.bak.$(date +%Y%m%d%H%M%S)"

cat > "$ZSHRC" << EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z extract web-search zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh

# 用户自定义配置
[ -f ~/.bashrc_custom ] && source ~/.bashrc_custom
EOF

echo "📝 已生成 ~/.zshrc（主题：robbyrussell）"

# 设置默认 shell
echo ""
read -p "🔄 是否将 zsh 设为默认 shell？(需要密码) (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: 使用 dscl 设置 shell
    sudo dscl . -create /Users/"$(whoami)" UserShell "$(which zsh)"
    echo "✅ 默认 shell 已设为 zsh（macOS）。重启终端生效。"
  else
    chsh -s "$(which zsh)"
    echo "✅ 默认 shell 已切换为 zsh（下次登录生效）。"
  fi
fi

echo ""
echo "🎉 安装完成！"
echo "👉 运行 \`exec zsh\` 或打开新终端即可体验增强版 Zsh。"
echo "📚 教程参考：https://www.haoyep.com/posts/zsh-config-oh-my-zsh/"
