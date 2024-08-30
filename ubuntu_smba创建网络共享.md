
### ubuntu服务器配置
```shell
$ export SHARE_DIR=/home/zhangningboo/disk/sda2/net_share_dir
$ mkdir ${SHARE_DIR} && chmod 755 ${SHARE_DIR}
$ sudo apt install samba samba-common-bin
$ sudo vim /etc/samba/smb.conf
## 添加如下配置
[net_share_dir]
valid users = zhangningboo
path = /home/zhangningboo/disk/sda2/net_share_dir
browseable = yes
writable = yes
create mask = 0664
directory mask = 0755
# 测试配置
$ testparm /etc/samba/smb.conf
# 配置登陆网络文件夹的密码，和主机密码不同
$ sudo smbpasswd -a zhangningboo
# 重启服务
$ sudo /etc/init.d/samba-ad-dc restart
```

### mac客户端
- `访达` -> `连接服务器`
- 输入地址格式：`smb://ip/net_share_dir`
- 输入用户名：`zhangningboo`，密码：`新创建的密码，不是主机密码`
