---
title: 在VSCode中用Rust ch32-hal库开发和调试CH32V303的完整指南
date: 2026-01-18 23:29:00
tags: ch32,rust,嵌入式
---
我在研究 WCH 的 CH32V 系列 RISC-V 单片机的时候，发现了 [ch32-rs](https://github.com/ch32-rs) 这个项目，它提供了用 Rust 实现的 CH32 HAL 库 `ch32-hal`、用 Rust 实现的 CH32 WCH-Link 命令行工具 `wlink` 和 WCH ISP 工具 `wchisp`，`ch32-hal` 让 CH32V 系列单片机程序代码更加简洁、更加安全并支持 `Embassy` 这样的嵌入式异步框架。

`ch32-hal` 库还处于早期开发状态，虽然功能比较完善，但文档资料比较少，缺乏完整的开发调试环境配置教程。我决定把我折腾的成果写成博客，供自己和别人参考，让更多的新手能够快速入手 CH32V Rust 开发。

本教程讲述了如何配置环境并创建基于 `ch32-hal` 库的项目，并使用 SWD 双线调试来烧录和调试。

> 本教程基于 Arch Linux 环境写成，但本教程的方法应该也能在 Windows 正常工作。
> 如果你发现教程存在问题或疑问，请通过邮箱 zijing233@gmail.com 联系我询问。

## 1. 准备工作

首先你需要安装 Rust 开发环境，在 Arch Linux 中你可以使用 pacman 安装 `rustup` 包，在 Windows 中你只需按照官网教程安装即可。安装好 `rustup` 后，你可能需要用 `rustup toolchain install` 命令安装 Rust 工具链。在 VSCode 中写一个简单的程序测试一下，确保编译运行和语法提示功能正常工作，就可以进入下一步。

为了烧录和调试，你还需要购买一个 WCH-LinkE（不推荐购买旧版的 WCH-Link，它支持的单片机型号更少且缺少一些高级功能。WCH-Link 相关的使用文档在官网可下载：[WCH-LinkUserManual.pdf](https://www.wch.cn/uploads/file/20230605/1685928774178004.pdf)，这里面还提到了 WCH-LinkE 和 WCH-Link 的区别。

你需要将单片机 SWDIO 和 SWCLK 连接到 WCH-LinkE 的对应排针来进行 SWD 双线调试。

然后，你需要安装 WCH 官方提供的 MounRiver Studio。你可以在这里面打开 WCH 官方提供的一个示例工程烧录测试你的单片机和 WCH-Link 是否好用，还可以在图形界面中调整单片机和 WCH-Link 的选项。最重要的是，我们需要使用 MounRiver Studio 中的定制工具链（gdb、openocd）才能完成调试工作。

你需要在 VSCode 中安装如下扩展：`
rust-lang.rust-analyzer`（Rust语言支持）、`marus25.cortex-debug`（调试工具），还推荐安装 `tamasfe.even-better-toml`（Cargo.toml语法提示）、`fill-labs.dependi`（依赖项提示）、`
usernamehw.errorlens`（错误高亮提示）。

### 确认你的 wlink 工具能正常工作

如果没有安装 `wlink`，需要先安装，安装教程见 [这里](https://github.com/ch32-rs/wlink?tab=readme-ov-file#install)。

常用命令：

```bash
wlink status # 查看 WCH-Link 状态
wlink erase # 擦除 Flash
wlink flash # 烧录程序
```

完成以上所有工作后，就可以创建项目了。

## 2. 创建项目，并烧录程序

`ch32-hal` 的情况比较特殊，它暂时还没有发布到 crates.io（只有一个 0.0.0 版本的占位项目），你不能直接用 `cargo new` 来方便地创建项目。但这些难不倒我们，官方提供了专门的项目模板 [ch32-hal-template](https://github.com/ch32-rs/ch32-hal-template) 来帮你轻松创建项目。

根据项目 README 中的说明，先安装 `cargo-generate` 工具：

```bash
cargo install cargo-generate
```

在要创建项目的目录执行以下命令创建项目：

```bash
cargo generate ch32-rs/ch32-hal-template
```

项目已经创建完成，切换到创建好的项目目录，执行 `rustup install` 来安装所需的 RISC-V 的 Rust 工具链（如果缺少）。

项目的构建和运行方法见[这里](https://github.com/ch32-rs/ch32-hal-template/blob/main/README-TEMPLATE.md)，`cargo build` 就是编译，`cargo run` 就是编译并烧录运行。

## 3. 配置调试器

你已经能成功编译和烧录程序了，但想要实现断点调试，还需要进行一点配置。

我们使用 OpenOCD 和 gdb 进行调试，由于 CH32V 的特殊性，我们需要使用 MounRiver Studio 中的工具链和配置文件来确保正确调试。

在“运行和调试”菜单中选择创建 `launch.json`，添加 Cortex Debug 提供的 "Debug with OpenOCD" 方案，添加 `configFiles`、`gdbPath` 和 `serverpath` 参数，将配置文件和工具的路径换成 MounRiver Studio 中对应的安装路径，最终的 `launch.json` 示例如下所示。

```json
{
    // 使用 IntelliSense 了解相关属性。 
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "cwd": "${workspaceRoot}",
            // 编译后的程序路径
            "executable": "./target/riscv32imfc-unknown-none-elf/debug/ch32v303-led-toggle",
            "name": "Debug with OpenOCD",
            "request": "launch",
            "type": "cortex-debug",
            "servertype": "openocd",
            // openocd 配置文件路径
            "configFiles": [
                "/usr/share/MRS2/MRS-linux-x64/resources/app/resources/linux/components/WCH/OpenOCD/OpenOCD/bin/wch-riscv.cfg"
            ],
            // gdb 路径
            "gdbPath": "/usr/share/MRS2/MRS-linux-x64/resources/app/resources/linux/components/WCH/Toolchain/RISC-V Embedded GCC12/bin/riscv-wch-elf-gdb",
            // openocd 路径
            "serverpath": "/usr/share/MRS2/MRS-linux-x64/resources/app/resources/linux/components/WCH/OpenOCD/OpenOCD/bin/openocd",
            "searchDir": [],
            "runToEntryPoint": "main",
            "showDevDebugOutput": "none"
        }
    ]
}
```

现在在“运行和调试”菜单应该可以正常启动调试器了，并且可以正常使用断点。需要注意的一点是，你需要将示例代码中的 `hal::println!()` 注释掉，因为它也会通过 SWD 双线调试发送数据，会和调试器冲突导致打印函数一直卡住不能继续运行。

## 4. 后续工作：优化编译参数

你可以修改 `Cargo.toml` 来调整 `dev` 和 `release`构建配置的优化等级，确保调试信息丰富并减小程序尺寸。

例如可以这样修改每个构建配置的 `opt-level` 和 `debug` 参数，修改后的 release 配置的 LED 点灯程序只有 3KB：

```toml
[profile.dev]
opt-level = "s"
debug = 2

[profile.release]
opt-level = 's'
debug = 2
# 省略其他配置项...

```

VSCode 鼠标悬停在每个参数上就可以显示该参数的描述，可以跳转到 Rust 文档网站查看参数所有的取值，建议你不断尝试不同的取值，取得最好的优化效果。

## 后记

Rust 在嵌入式开发中的应用价值正在被逐渐发掘，它的开发体验比 C 更好，框架封装也更加简洁易用，还支持异步（Embassy）和丰富的库。CH32V303 单片机使用自研 RISC-V 架构，价格低廉且功能丰富，还具备完善的工具链和 Linux 开发工具支持。本文讲述了如何用 Rust 开发和调试 CH32V303 单片机，希望能够帮助到你，若你对本教程有任何疑问和建议，请联系我和我交流，感谢你的阅读。