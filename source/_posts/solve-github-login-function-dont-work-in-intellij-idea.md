---
title: 解决IntelliJ IDEA的GitHub登录功能无效，不能推送代码的问题
date: 2025-12-12 16:52:31
tags: git,github,idea,jetbrains
---
我在使用IntelliJ IDEA的时候，一旦需要向我的私有仓库推送代码，IDEA就会请求我使用GitHub登录。但每次我完成登录后，推送仍然会失败（如图）：

![IDEA GitHub推送失败的截图](image1.png)


这里提示仓库找不到，这是Git未正确登录或未授权访问仓库的表现。因为我如果在终端中使用`git push origin create-tests-20251110`命令，即可正常推送。

根据我的了解，我的朋友们也经常遇到这种问题，他们通常只能被迫在终端中输入`git push`命令来推送，这个问题在Linux和Windows上都会出现。但我认为，既然IDEA提供了较为完整的Git功能，就有办法将它好好用上。

## 问题分析

我使用`git`命令可以正常推送，原因是我利用GitHub CLI的登录功能完成了HTTPS鉴权。

对GitHub CLI的简易介绍：

> GitHub CLI可以在命令行中完成GitHub账号的登录，并将登录信息存入Git Credential Helper，让`git`命令能够正常访问用户的仓库，这是Linux上配置GitHub HTTPS鉴权的重要工具。安装好GitHub CLI后，使用`gh auth login`命令即可进行GitHub登录。

>  Git Credential Helper在Windows里也有，Windows里使用`git`命令的时候弹出的GitHub登录窗口就是它提供的功能。

我查看了IDEA Git控制台输出的信息：

```
16:41:37.979: [/home/kitra/Projects/HNUSTIntelligentWindfarm/backend] git /usr/bin/git -c credential.helper= -c core.quotepath=false -c log.showSignature=false push --progress --porcelain origin refs/heads/create-tests-20251110:create-tests-20251110
remote: Repository not found.
fatal: repository 'https://github.com/KitraIntelligentWindfarm/backend.git/' not found
```

我注意到控制台命令中`credential.helper=`这一段，这代表**IDEA此时没有使用Git Credential Helper**，这就是IDEA的Git功能不能推送的原因了。

## 问题解决

![在设置中勾选使用凭据帮助程序选项的截图](image2.png)

在IDEA的Git设置中勾选“使用凭据帮助程序”即可解决问题。

如果你尚未使用GitHub CLI进行登录，只需安装好GitHub CLI，然后使用`gh auth login`命令登录即可。

## 后记：如果你使用的是SSH鉴权

如果使用GitHub SSH鉴权，你不会遇到本文章所讲述的问题。但是SSH鉴权最主要的缺点是没法使用HTTP代理服务器来加速，这会显著影响GitHub仓库的访问速度。如果你受SSH访问速度慢问题的困扰，建议使用GitHub CLI来实现HTTP鉴权，这样就可以使用HTTP代理加速拉取和推送，获得和Windows上一样的体验。
