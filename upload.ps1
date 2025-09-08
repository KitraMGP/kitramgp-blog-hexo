<#
.SYNOPSIS
    Hexo博客简单部署脚本
.DESCRIPTION
    使用PSCP直接上传public目录到远程服务器
.NOTES
    需要设置以下环境变量：
    - BLOG_SERVER_SSH_LOGIN: 服务器登录信息 (格式: user@hostname)
    - BLOG_SERVER_PORT: 服务器SSH端口 (可选，默认22)
    - BLOG_SERVER_UPLOAD_PATH: 服务器上传路径
#>

# 设置错误处理
$ErrorActionPreference = "Stop"

# 读取环境变量
$sshLogin = $env:BLOG_SERVER_SSH_LOGIN
$serverPort = if ($env:BLOG_SERVER_PORT) { $env:BLOG_SERVER_PORT } else { "22" }
$uploadPath = $env:BLOG_SERVER_UPLOAD_PATH

# 检查必要的环境变量
if (-not $sshLogin) {
    Write-Host "错误: 未设置环境变量 BLOG_SERVER_SSH_LOGIN" -ForegroundColor Red
    Write-Host "示例: kitra@127.0.0.1" -ForegroundColor Yellow
    exit 1
}

if (-not $uploadPath) {
    Write-Host "错误: 未设置环境变量 BLOG_SERVER_UPLOAD_PATH" -ForegroundColor Red
    Write-Host "示例: /var/www/kitrablog" -ForegroundColor Yellow
    exit 1
}

# 检查PSCP是否可用
try {
    $pscpPath = Get-Command pscp.exe -ErrorAction Stop
    Write-Host "找到PSCP: $($pscpPath.Source)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "错误: 未找到pscp.exe" -ForegroundColor Red
    Write-Host "请安装PuTTY工具包并确保pscp.exe在PATH中" -ForegroundColor Yellow
    exit 1
}

# 检查public目录是否存在
$publicDir = Join-Path $PSScriptRoot "public"
if (-not (Test-Path $publicDir)) {
    Write-Host "错误: 未找到public目录，请先运行 hexo generate" -ForegroundColor Red
    exit 1
}

# 显示配置信息
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Hexo博客简单部署脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "配置信息:" -ForegroundColor Green
Write-Host "服务器地址: $sshLogin" -ForegroundColor White
Write-Host "端口: $serverPort" -ForegroundColor White
Write-Host "上传路径: $uploadPath" -ForegroundColor White
Write-Host "本地目录: $publicDir" -ForegroundColor White
Write-Host ""

# 请求输入密码
$password = Read-Host "请输入SFTP密码" -AsSecureString

try {
    Write-Host "正在上传文件..." -ForegroundColor Yellow
    
    # 转换密码
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
	$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # 构建PSCP命令
    $pscpArgs = @(
        "-r",                          # 递归复制目录
        "-P", $serverPort,             # 端口
        "-pw", $plainPassword,              # 密码（明文）
        "-q",                          # 静默模式，减少输出
        "$publicDir\*",                # 本地目录内容
        "$sshLogin`:$uploadPath"        # 远程路径
    )
    
    # 执行PSCP命令
    $output = & pscp.exe $pscpArgs 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "上传完成！" -ForegroundColor Green
        
        # 只显示错误和警告信息
        foreach ($line in $output) {
            if ($line -match "pscp:|fatal|error|warning") {
                Write-Host $line -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "部署成功完成！" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
    } else {
        Write-Host "错误: 上传失败" -ForegroundColor Red
        Write-Host "错误信息:" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # 清理密码变量
    if ($plainPassword) {
        $plainPassword = $null
    }
    if ($BSTR) {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
    $password = $null  # SecureString对象
}