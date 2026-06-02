---
title: "导入torch报错：ImportError: libtorch_cpu.so: cannot enable executable stack as shared object requires: Invalid argument解决方法"
date: 2026-03-08 20:07:00
tags: linux,pytorch
---
# 问题描述
使用Conda部署PyTorch环境的时候，发现`torch`包无法导入，导入会报错，错误如下：
```
kitra@LAPTOP-KITRA-ARCH ~/P/D/InformerWtFaultForecast> conda activate wt-informer-forecast                                                                       main!?
(wt-informer-forecast) kitra@LAPTOP-KITRA-ARCH ~/P/D/InformerWtFaultForecast> python                                                                             main!?
Python 3.10.19 (main, Oct 21 2025, 16:43:05) [GCC 11.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/kitra/.conda/envs/wt-informer-forecast/lib/python3.10/site-packages/torch/__init__.py", line 416, in <module>
    from torch._C import *  # noqa: F403
ImportError: libtorch_cpu.so: cannot enable executable stack as shared object requires: Invalid argument
>>>
```

# 问题原因
`cannot enable executable stack as shared object requires: Invalid argument`错误出现的原因是`glibc 2.40`及更高版本引入了一项安全变更，导致系统不再允许某些共享库（`.so`文件）启用可执行栈。

简单来说，可以这样理解：你的Linux系统更新了核心库`glibc`，它现在会对所有共享库进行更严格的检查。如果一个共享库被标记为“需要可执行栈”（这通常是老旧的程序或编译时的问题），新版的`glibc`会直接拒绝加载并报出你看到的这个错误，而不是像以前那样悄悄允许，以此来防范潜在的安全风险。

# 解决方法
推荐的解决方法是用`patchelf`工具对出现错误的库进行处理：
```
patchelf --clear-execstack /home/kitra/.conda/envs/wt-informer-forecast/lib/python3.10/site-packages/torch/lib/libtorch_cpu.so
```
将路径替换为你的`libtorch_cpu.so`的实际路径，执行命令后，`import torch`报错的问题应该可以得到解决。