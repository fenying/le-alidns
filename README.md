# LE-AliDNS

通过阿里云 DNS 为 Let's Encrypt 签发证书提供验证的脚本工具。

## 功能

- 支持签发多域名证书

## 使用条件

1. 一台能运行 Certbot 的 Linux/Mac 设备
2. 安装有 Python 2.7.x (需自行手动安装)
3. 安装有 Certbot (需自行手动安装)
4. 要签发（续签）的所有证书，域名都是通过阿里云 DNS 管理的。

## 使用方式

### 安装

使用 Git Clone 仓库，例如：

```sh
cd /usr/local
git clone https://github.com/fenying/le-alidns.git
cd le-alidns
find '.' -name '*.sh' -exec chmod 0700 {} \; # 设置 Shell 脚本执行权限
```

### 初始化

> 依赖如下组件： (可以通过 initialize-env.sh 自动安装)
>
> - Pip
> - Aliyun CLI 命令行工具
> - Aliyun AliDNS Python SDK

1.  运行脚本 initialize-env.sh 安装 Python 2.7, PIP, Aliyun-CLI, 
    Aliyun-SDK-AliDNS 等组件，并配置 Access-Key 和 Secret-Key。
    > Access-Key 需要 AliyunDNSFullAccess 权限。

2.  复制 default.conf 配置文件为 /etc/le-alidns.conf，并根据需要配置。

### 签发新证书

执行 `sudo /path/to/sign-all.sh` 即可为 domains 里配置的所有域名都签发证书。

### 续签证书

执行 `sudo /path/to/renew-all.sh` 可以续签所有已经签发的证书（包括手动签发的）。

> 执行前使用 `export LEALIDNS_FORCE=1` 可以强制续签证书，但是一般情况请不要使用。

## 作者

Angus.Fenying <[i.am.x.fenying@gmail](mailto:i.am.x.fenying@gmail)>

## License

本项目基于 [MIT 协议](./LICENSE)开源，可自由使用，如果使用过程中发生任何意外，本人
不承担任何责任。
