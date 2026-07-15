# kitramgp-blog-hexo

本仓库托管 Kitra 的博客源代码。

## 构建

博客使用 Hexo 构建，[Hexo文档](https://hexo.io/zh-cn/docs/)

根据教程安装好 pnpm 后，在仓库根目录依次执行以下操作：

下载依赖：

```bash
pnpm i
```

构建博客静态站点：

```bash
pnpm run build
```

> 如果要实时监测文件更改，需要使用 hexo generate --watch

运行本地预览：

```bash
pnpm run server
```

## 部署到远程服务器

部署使用 `rsync` 通过 SSH 将构建结果同步到服务器。请先确保：

- 本地和服务器均已安装 `rsync`
- SSH 公钥已经添加到服务器用户 `kitra` 的 `authorized_keys`
- 用户 `kitra` 对 `/var/www/kitrablog/blog` 有写权限

在仓库根目录执行：

```bash
pnpm run deploy
```

该命令会清理并重新生成 `public` 目录，然后同步到：

```text
kitra@kitramgp.cn:/var/www/kitrablog/blog/
```

SSH 仅使用本机密钥认证，不会退回账户密码。如果私钥设置了口令，部署时会在终端提示输入。同步使用 `--delete`，服务器目标目录中不存在于本地 `public` 目录的文件将被删除。
