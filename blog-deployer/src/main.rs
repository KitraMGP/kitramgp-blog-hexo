use rpassword::prompt_password;
use ssh2::Session;
use std::env;
use std::fs;
use std::io::prelude::*;
use std::net::TcpStream;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 加载.env文件
    dotenvy::dotenv().expect("Failed to load .env file");

    println!("🚀 静态博客部署工具启动...");

    // 1. 读取环境变量
    let ssh_host = env::var("SSH_HOST")
    .expect("请设置 SSH_HOST 环境变量");
    let ssh_port = env::var("SSH_PORT")
    .unwrap_or_else(|_| "22".to_string())
    .parse::<u16>()
    .expect("SSH_PORT 必须是有效的端口号");
    let ssh_username = env::var("SSH_USERNAME")
    .expect("请设置 SSH_USERNAME 环境变量");
    let remote_path = env::var("REMOTE_PATH")
    .expect("请设置 REMOTE_PATH 环境变量");

    // 2. 检查 public 文件夹是否存在
    let local_dir = "../public";

    if !Path::new(local_dir).exists() {
        return Err(format!("本地../public文件夹不存在: {}", local_dir).into());
    }

    // 3. 获取用户输入的密码
    let password = prompt_password("🔑 请输入SSH密码: ")?;

    // 4. 建立 SSH 连接
    println!("📡 正在连接到服务器 {}:{}...", ssh_host, ssh_port);
    let tcp = TcpStream::connect((ssh_host.as_str(), ssh_port))?;
    let mut sess = Session::new()?;
    sess.set_tcp_stream(tcp);
    sess.handshake()?;
    sess.userauth_password(&ssh_username, &password)?;

    if !sess.authenticated() {
        return Err("SSH认证失败，请检查用户名和密码".into());
    }

    println!("✅ SSH连接成功！");

    // 5. 删除远程目录
    println!("🗑️  正在删除远程目录 {}...", remote_path);
    let mut channel = sess.channel_session()?;
    channel.exec(&format!("rm -rf {}", remote_path))?;
    channel.wait_eof()?;
    channel.close()?;
    channel.wait_close()?;

    // 重新创建目录
    let mut channel = sess.channel_session()?;
    channel.exec(&format!("mkdir -p {}", remote_path))?;
    channel.wait_eof()?;
    channel.close()?;
    channel.wait_close()?;

    println!("✅ 远程目录清理完成");

    // 6. 上传本地 public 文件夹
    println!("📤 正在上传public文件夹...");
    let sftp = sess.sftp()?;

    if !Path::new(local_dir).exists() {
        return Err(format!("本地../public文件夹不存在: {}", local_dir).into());
    }

    upload_directory(&sftp, local_dir, &remote_path)?;

    println!("✅ 文件上传完成！");
    println!("🎉 博客部署成功！");

    Ok(())
}

fn upload_directory(
    sftp: &ssh2::Sftp,
    local_path: &str,
    remote_path: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    for entry in fs::read_dir(local_path)? {
        let entry = entry?;
        let path = entry.path();
        let file_name = path.file_name()
        .ok_or("无法获取文件名")?
        .to_string_lossy();

        let remote_file_path = format!("{}/{}", remote_path, file_name);

        if path.is_dir() {
            // 创建远程目录
            sftp.mkdir(Path::new(&remote_file_path), 0o755)?;
            // 递归上传子目录
            upload_directory(sftp, path.to_str().unwrap(), &remote_file_path)?;
        } else {
            // 上传文件
            let mut local_file = fs::File::open(&path)?;
            let mut contents = Vec::new();
            local_file.read_to_end(&mut contents)?;

            let mut remote_file = sftp.create(Path::new(&remote_file_path))?;
            remote_file.write_all(&contents)?;
            println!("   📄 上传: {} -> {}", path.display(), remote_file_path);
        }
    }
    Ok(())
}
