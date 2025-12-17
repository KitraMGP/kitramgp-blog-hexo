---
title: IoTDB导入和导出表结构SQL和数据的方法
date: 2025-12-17 21:39:02
tags: IoTDB,SQL
---

最近我在用 IoTDB 做工业大数据项目，而整个系统的核心就是 IoTDB。让 IoTDB 新用户头疼的一大问题就是不知道如何导入和导出表结构，以及不了解如何导入和导出数据。实际上 IoTDB 为这些操作都提供了专门的脚本，这里我整理了一下我学习到的 IoTDB 导入导出表结构或数据的方式。

## 1. 表结构导入导出

表结构的导入导出使用 IoTDB 安装目录中的 `tools/schema/` 中的 `import-schema.sh` 和 `export-schema.sh`，在终端直接运行这些脚本即可查看帮助。

> 供 Windows 使用的 .bat 脚本位于 'tools/windows/schema' 中。

示例命令：
```bash
# 导出 intelliwindfarm 数据库的表结构到当前目录（SQL 方言为表模型）
# 若为树模型，则不需要 -sql_dialect 和 -db 参数
./export-schema.sh -sql_dialect table -t . -db intelliwindfarm

# 导入使用 import-schema.sh，具体用法可以直接查看脚本输出的帮助信息
```

## 2. 数据导入导出

数据导入导出使用 IoTDB 安装目录中的 `tools/` 目录中的 `import-data.sh` 和 `export-data.sh`。导入导出数据的格式可以为 `tsfile`、`csv` 或 `sql`，导出数据时还可以使用 `-q` 参数执行 SQL 查询语句。具体的使用方法可参见这些脚本输出的帮助信息，示例命令在此省略。

> 供 Windows 使用的 .bat 脚本位于 'tools/windows/' 中。