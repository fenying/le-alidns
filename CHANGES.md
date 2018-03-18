# Change logs

## v0.3.0

- 支持 ACMEv2 的通配符证书申请。

## v0.2.3

- 修复域名中带横线“-”时无法识别的 Bug。（Issue #2）

## v0.2.2

- 配置文件添加 `certbot-root` 配置项以允许使用自定义的 Certbot 的命令名称。（Issue #1）

## v0.2.1

- 修复 LE-AliDNS 脚本路径，

## v0.2.0

- 完善使用教程
- 配置文件添加 `no-auto-upgrade`  配置项以禁止 certbot 自动更新，**默认开启**。
- 增加根据证书存储目录，检测域名是否已经签发证书。
