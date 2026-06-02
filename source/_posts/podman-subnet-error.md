---
title: "Podman创建网络报错Error: could not find free subnet from subnet pools"
date: 2026-03-09 09:41:27
tags:
---
# 发现问题
我使用Podman启动WinBoat的容器的时候，出现了以下错误：
```
kitra@LAPTOP-KITRA-ARCH ~/.winboat> podman compose up -d                                                                                                      
>>>> Executing external compose provider "/usr/bin/podman-compose". Please see podman-compose(1) for how to disable this message. <<<<

Traceback (most recent call last):
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 944, in assert_cnt_nets
    await compose.podman.output([], "network", ["exists", net_name])
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 1572, in output
    raise subprocess.CalledProcessError(p.returncode, " ".join(cmd_ls), stderr_data)
subprocess.CalledProcessError: Command 'podman network exists winboat_default' returned non-zero exit status 1.

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/bin/podman-compose", line 8, in <module>
    sys.exit(main())
             ~~~~^^
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 4256, in main
    asyncio.run(async_main())
    ~~~~~~~~~~~^^^^^^^^^^^^^^
  File "/usr/lib/python3.14/asyncio/runners.py", line 204, in run
    return runner.run(main)
           ~~~~~~~~~~^^^^^^
  File "/usr/lib/python3.14/asyncio/runners.py", line 127, in run
    return self._loop.run_until_complete(task)
           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^
  File "/usr/lib/python3.14/asyncio/base_events.py", line 719, in run_until_complete
    return future.result()
           ~~~~~~~~~~~~~^^
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 4252, in async_main
    await podman_compose.run()
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 2072, in run
    retcode = await cmd(self, args)
              ^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 3170, in compose_up
    podman_args = await container_to_args(compose, cnt, detached=False, no_deps=args.no_deps)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 1182, in container_to_args
    await assert_cnt_nets(compose, cnt)
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 949, in assert_cnt_nets
    await compose.podman.output([], "network", args)
  File "/usr/lib/python3.14/site-packages/podman_compose.py", line 1572, in output
    raise subprocess.CalledProcessError(p.returncode, " ".join(cmd_ls), stderr_data)
subprocess.CalledProcessError: Command 'podman network create --label io.podman.compose.project=winboat --label com.docker.compose.project=winboat winboat_default' returned non-zero exit status 125.
Error: executing /usr/bin/podman-compose up -d: exit status 1
```
可以看到是`podman network create --label io.podman.compose.project=winboat --label com.docker.compose.project=winboat winboat_default`命令发生错误，手动执行该命令后得到以下输出：
```
kitra@LAPTOP-KITRA-ARCH ~/.winboat> podman network create --label io.podman.compose.project=winboat --label com.docker.compose.project=winboat winboat_default        1
Error: could not find free subnet from subnet pools
```

# 解决方法
查阅资料后得知，这个Podman网络创建失败的原因是**Podman的子网地址池耗尽**，解决方法是先用`ip addr命令查看现在所有正在使用的子网地址块`：
```
kitra@LAPTOP-KITRA-ARCH ~/.winboat> ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether e8:9c:25:1e:ee:29 brd ff:ff:ff:ff:ff:ff
    altname enxe89c251eee29
    inet 10.1.15.27/8 brd 10.255.255.255 scope global noprefixroute enp3s0
       valid_lft forever preferred_lft forever
    inet6 fe80::2b00:667e:dccb:ba17/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether a4:f9:33:a3:4c:ab brd ff:ff:ff:ff:ff:ff
6: singbox_tun: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 9000 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none 
    inet 172.18.0.1/30 brd 172.18.0.3 scope global singbox_tun
       valid_lft forever preferred_lft forever
    inet6 fe80::d263:8f66:1338:7b83/64 scope link stable-privacy proto kernel_ll 
       valid_lft forever preferred_lft forever
kitra@LAPTOP-KITRA-ARCH ~/.winboat> 
```
然后，编辑`~/.config/containers/containers.conf`文件（如果`containers`文件夹不存在需要手动创建），添加以下内容：
```
[network]
subnet_pools = [
  {base = "172.20.0.0/16", size = 24},
  {base = "172.21.0.0/16", size = 24},
  {base = "172.22.0.0/16", size = 24},
  {base = "172.23.0.0/16", size = 24},
  {base = "172.24.0.0/16", size = 24}
]
```
这里要求每个地址块都不属于`ip addr`输出的任何地址块，你可以让AI帮你写出出合适的Podman子网地址池配置。

> 注意：不要编辑`/etc/containers/containers.conf`文件，用户空间的无守护进程的Podman不使用这个配置文件。

修改好配置文件后，重新运行相关Podman命令，问题得到解决。