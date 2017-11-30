# LE-AliDNS

通过阿里云 DNS 为 Let's Encrypt 签发证书提供验证的脚本工具。

## 使用方式

1.  运行脚本 initialize-env.sh 安装 Python 2.7, PIP, Aliyun-CLI, 
    Aliyun-SDK-AliDNS 等组件，并配置 Access-Key 和 Secret-Key。
    > Access-Key 需要 AliyunDNSFullAccess 权限。

2.  复制 default.conf 配置文件为 /etc/le-alidns.conf

    - 修改 domains 为要签发的域名。（多个用逗号隔开，不要空格）
    - 修改 email 为你的邮箱。（Let's Encrypt 组织登记）
    - 修改 certbot-root 为 certbot 的安装目录。（尾部带 `/`）

3.   执行 sign-all.sh 即可为 domains 里配置的所有域名都签发证书。

## 作者

Angus.Fenying <[i.am.x.fenying@gmail](mailto:i.am.x.fenying@gmail)>

## License

本项目基于 [MIT 协议](./LICENSE)开源，可自由使用，如果使用过程中发生任何意外，本人
不承担任何责任。
