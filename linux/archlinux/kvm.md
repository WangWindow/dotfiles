# KVM
https://www.cnblogs.com/suxiuf/p/17586593.html

```shell
sudo pacman -Syy
sudo pacman -S archlinux-keyring
sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode
sudo pacman -S ebtables iptables
sudo pacman -S libguestfs
```

- 启动KVM libvirt服务
```shell
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

systemctl status libvirtd.service
```

- 配置普通用户可以使用KVM

打开/etc/libvirt/libvirtd.conf文件进行编辑。
```shell
sudo vim /etc/libvirt/libvirtd.conf
```

将UNIX域套接字组所有权设置为libvirt（第85行左右）
```shell
unix_sock_group = "libvirt"
```

为R/W套接字设置UNIX套接字权限（第102行附近）

```shell
unix_sock_rw_perms = "0770"
```

将当前用户帐户添加到libvirt组

```shell
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt

sudo systemctl restart libvirtd.service
```

- Linux的KVM虚拟机虚拟网络‘default’NAT未激活解决方法：
```shell
# 查看是否开启
sudo virsh net-list --all
# 开启网络
sudo virsh net-start --network default
```