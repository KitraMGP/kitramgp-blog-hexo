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
hexo generate
```

> 如果要实时监测文件更改，需要使用 hexo generate --watch

运行本地预览：

```bash
hexo server
```
