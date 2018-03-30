# LE-AliDNS

通过阿里云 DNS 为 Let's Encrypt 签发证书提供验证的脚本工具。

## 功能

-   支持签发多域名证书
-   支持签发 ACMEv2 的通配符证书（配置开启 `acme-version=v2`）

    > 如果此前使用了 ACMEv1 签发的证书，那么建议在升级前将 /etc/letsencrypt 目录备份
    > 例如改个名。

-   支持刷新证书

## 使用条件

1. 一台能运行 Certbot 的 Linux/Mac 设备
2. 安装有 Python 2.7.x (需自行手动安装)
3. 安装有 Certbot (需自行手动安装)
4. 要签发（续签）的所有证书，域名都是通过阿里云 DNS 管理的。

## 使用方式

### 安装

使用 Git Clone 仓库，例如：

```sh
LE_ALIDNS_INSTALL_ROOT=/usr/local
LE_ALIDNS_DIRNAME=le-alidns
LE_ALIDNS_ROOT="${LE_ALIDNS_INSTALL_ROOT}/${LE_ALIDNS_DIRNAME}"
cd $LE_ALIDNS_INSTALL_ROOT
git clone https://github.com/fenying/le-alidns.git $LE_ALIDNS_DIRNAME
cd $LE_ALIDNS_ROOT
find '.' -name '*.sh' -exec chmod 0700 {} \; # 设置 Shell 脚本执行权限
git config --local core.filemode false # 忽略该git仓库的文件权限属性改动
```

### 更新版本

```sh
LE_ALIDNS_INSTALL_ROOT=/usr/local
LE_ALIDNS_DIRNAME=le-alidns
LE_ALIDNS_ROOT="${LE_ALIDNS_INSTALL_ROOT}/${LE_ALIDNS_DIRNAME}"
cd $LE_ALIDNS_ROOT
git config --local core.filemode false
git pull
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
    > Access-Key 需要 AliyunDNSFullAccess 权限。参考：
    [配置命令行工具和 SDK](https://help.aliyun.com/document_detail/43039.html?spm=a2c4g.11186623.6.550.ap6b0e)。

2.  复制 default.conf 配置文件为 /etc/le-alidns.conf，并根据需要配置。

    > LE-AliDNS 默认使用 /etc/le-alidns.conf 为配置文件路径，如果不想使用默认路径，
    > 也可以通过配置环境变量 `export LEALIDNS_CONFIG=/path/to/config-file` 使用。

### 配置 Pip 源

由于某些不可描述的原因，对于在国内使用 Pip 会出现无法下载或者下载极其缓慢的情况。
这个情况请修改 Pip 配置文件（一般是 `~/.pip/pip.conf`），使用清华大学的源：

> 不要使用阿里云的源。

```ini
[global]
index-url=https://pypi.tuna.tsinghua.edu.cn/simple

[install]
trusted-host=pypi.tuna.tsinghua.edu.cn
```

> 参考：https://github.com/certbot/certbot/issues/2516

### 签发新证书

执行 `sudo /path/to/sign-all.sh` 即可为 domains 里配置的所有域名都签发证书。

### 续签证书

执行 `sudo /path/to/renew-all.sh` 可以续签所有已经签发的证书（包括手动签发的）。

> 执行前使用 `export LEALIDNS_FORCE=1` 可以强制续签证书，但是一般情况请不要使用。

### 使用多个阿里云账户

参考 [阿里云官方文档：多账号共用](https://help.aliyun.com/document_detail/30001.html?spm=a2c4g.11186623.6.574.ptIW3j)，手动配置不同账户使用的配置名称。

然后配合环境变量 LEALIDNS_CONFIG 使用不同的 LE-AliDNS 配置文件，并将不同账户的配置
名称写入到对应的 LE-AliDNS 配置文件的 alicli-profile 选项里。

## 作者

Angus.Fenying <[i.am.x.fenying@gmail.com](mailto:i.am.x.fenying@gmail.com)>

## License

本项目基于 [MIT 协议](./LICENSE)开源，可自由使用，如果使用过程中发生任何意外，本人
不承担任何责任。
