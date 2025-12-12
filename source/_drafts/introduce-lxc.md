---
title: 利用LXC容器在没有root权限的Linux环境中获得root环境
date: 2025-11-17 23:08:22
tags:
---
今天水群的时候，我聊到“Linux 多用户情况下，若其他用户没有 root 权限，则不得不请管理员用包管理器安装某些需要用的软件，或者使用 Podman 容器运行程序”。然而一位大佬 [z3475](https://z3475.work/) 表示，没人愿意用一个没有 sudo 的 Linux。他表示应该用 LXC 容器来让非特权用户获取一个有 root 的容器。

在这篇文章里，我就记录一下使用非特权用户创建 LXC 容器的方法。

首先请参阅 Arch Linux 百科对 LXC 的介绍：[Linux 容器 - ArchWiki](https://wiki.archlinux.org.cn/title/Linux_Containers#)

未完待续…