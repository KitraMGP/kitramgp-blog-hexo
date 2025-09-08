# Hexo博客自动部署说明

本文档说明了如何使用PowerShell脚本自动部署Hexo博客到远程服务器。

## 环境要求

### 使用PuTTY工具包
1. 安装PuTTY工具包
   - 下载地址：https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
   - 将pscp.exe和psftp.exe添加到系统PATH中

## 环境变量设置

在部署之前，需要设置以下环境变量：

```powershell
# 服务器登录信息 (格式：用户名@IP地址)
$env:BLOG_SERVER_SSH_LOGIN = "kitra@127.0.0.1"

# 服务器SSH端口 (可选，默认22)
$env:BLOG_SERVER_PORT = "22"

# 服务器上传路径
$env:BLOG_SERVER_UPLOAD_PATH = "/var/www/kitrablog/blog"
```

### 永久设置环境变量

在Windows 11中永久设置环境变量：

1. 按 `Win + I` 打开设置
2. 选择"系统" → "关于" → "高级系统设置"
3. 点击"环境变量"
4. 在"用户变量"中点击"新建"，添加上述环境变量

## 使用方法

### 部署前准备

确保已经生成了静态文件：
```powershell
hexo generate
```

### 使用脚本

```powershell
.\upload.ps1
```

## 脚本功能

### 配置验证
- 检查必要的环境变量
- 验证服务器登录信息格式
- 检查public目录是否存在

### 部署流程
1. 显示当前配置信息
2. 请求输入SFTP密码
3. 连接到远程服务器
4. 清空远程目录内容
5. 上传本地public目录中的所有文件
6. 显示部署结果

### 安全特性
- 密码输入时使用安全字符串
- 脚本执行完成后自动清理密码变量
- 支持SSH主机密钥验证
