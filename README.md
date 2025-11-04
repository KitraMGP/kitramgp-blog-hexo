# kitramgp-blog-hexo

本仓库托管 Kitra 的博客源代码。

## 构建

博客使用 Hexo 构建，[Hexo文档](https://hexo.io/zh-cn/docs/)

根据教程安装好 pnpm 和 Hexo 命令行工具后，在仓库根目录依次执行以下操作：

下载依赖：

```bash
pnpm i
```

构建博客静态站点：

```bash
pnpm run generate
```

> 如果要实时监测文件更改，需要使用 hexo generate --watch

运行本地预览：

```bash
pnpm run server
```

## 部署到远程服务器

首先确保安装了 Rust，且 cargo 可以使用。

在 `blog-deployer` 目录创建 `.env` 文件，编辑：

```plaintext
SSH_HOST=<SSH主机>
SSH_PORT=22
SSH_USERNAME=<用户名>
REMOTE_PATH=/var/www/kitrablog/blog（远程地址，本地public目录中的文件会被上传到blog目录中）
```

在根目录执行：

```bash
pnpm run deploy
```
