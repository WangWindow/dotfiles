# Ubuntu 配置指南

- 基础工具安装

```shell
sudo apt install gnome-tweaks gnome-shell-extension-manager
sudo apt install fcitx5 fcitx5-chinese-addons
```

- 卸载snap
```shell
#snap循环卸载应用
seq 1 3 | while read j; do { \
snap list | awk '{print $1}'  | tail -n +2 | while read k ; do ( echo $k && sudo snap remove $k ;); done \
}; done

#停止snapd服务，禁止开机启动
sudo systemctl stop snapd
sudo systemctl disable --now snapd.socket

#循环卸载snap
for m in /snap/core/*; do ( sudo umount $m ;) ; done
#或者#ls /snap/core/ | while read k ; do ( sudo umount /snap/core/$k ;) ; done

#卸载snapd及其的依赖
sudo apt autoremove --purge snapd


#删除snap目录
rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd

#禁止 apt 安装 snapd
sudo sh -c "cat > /etc/apt/preferences.d/no-snapd.pref" << EOL
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOL

#禁用 snap Firefox 的更新
sudo sh -c "cat > /etc/apt/preferences.d/no-firefox.pref" << EOL
Package: firefox
Pin: release a=*
Pin-Priority: -10
EOL
```

- 安装Firefox
```
# 创建一个保存 APT 库密钥的目录：
sudo install -d -m 0755 /etc/apt/keyrings

# 导入 Mozilla APT 密钥环：
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# 密钥指纹应该是 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3。你可以用以下命令检查：
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'

# 把 Mozilla APT 库添加到源列表中：
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# 配置 APT 优先使用 Mozilla 库中的包：
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# 更新软件列表并安装 Firefox .deb 包：
sudo apt update
sudo apt install firefox
```

- 换源配置

在 `/etc/apt/sources.list.d/ubuntu.sources` 中添加以下内容：

```
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

- VS Code
```
# 安装必要的依赖：
sudo apt install software-properties-common apt-transport-https

# 导入微软的 GPG 密钥：
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# 添加 Visual Studio Code 仓库：
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d

# 更新软件包列表并安装 VS Code：
sudo apt update
sudo apt install code
```