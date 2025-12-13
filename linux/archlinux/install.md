
# ArchLinux
- archlinuxcn
```
# Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
# 使用方法：在 /etc/pacman.conf 文件末尾添加以下两行：

[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch

# 初始化 keyring
sudo pacman -S haveged
sudo systemctl start haveged
sudo systemctl enable haveged
rm -fr /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux

# 之后通过以下命令安装 archlinuxcn-keyring 包导入 GPG key。
sudo pacman -Sy archlinuxcn-keyring
sudo pacman-key --lsign-key "farseerfc@archlinux.org"

# 执行完毕后再次安装archlinuxcn-keyring
sudo pacman -Sy archlinuxcn-keyring

#然后执行下一条命令
sudo pacman-key --populate archlinuxcn
```

- environment
```
#
# This file is parsed by pam_env module
# etc/environment
# Syntax: simple "KEY=VAL" pairs on separate lines
#

GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
```

- fcitx
```shell
sudo pacman -S fcitx5-im fcitx5-chinese-addons fcitx5-configtool
sudo pacman -S fcitx5-pinyin-zhwiki fcitx5-pinyin-moegirl
```

- font
```shell
pacman -S ttf-jetbrains-mono-nerd noto-fonts-cjk noto-fonts-emoji
```

- arch 音频处显示没有输入或输出设备
```shell
paru -S sof-firmware
```
