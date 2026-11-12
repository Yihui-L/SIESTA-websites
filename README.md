# SIESTA Websites

SIESTA-lyh 程序手册和 W7-X 算例的公开网站，无需登录。手册、可编辑文档、SIESTA-lyh 源码快照及算例文件随本仓库提供，浏览网站无需连接私有源码仓库或运行求解器。

| 目录 | 内容 | 网站 |
| --- | --- | --- |
| [Source-Code](Source-Code/README.md) | 物理原理、输入与输出、编译运行、源码改动及验证范围；包含 [SIESTA-lyh 源码快照](Source-Code/SIESTA-lyh/) | [程序手册](https://yihui-l.github.io/SIESTA-websites/Source-Code/) |
| [SIESTA-lyh-example](SIESTA-lyh-example/README.md) | W7-X EIM 的 0.8% 与约 5% β 固定、自由边界算例；包含输入、已归档输出、图表及说明 | [算例入口](https://yihui-l.github.io/SIESTA-websites/SIESTA-lyh-example/) |

## 仓库结构

```text
SIESTA-websites/
├── Source-Code/
│   ├── SIESTA-lyh/
│   └── … 程序手册、可编辑文档及网页资源
├── SIESTA-lyh-example/
│   └── W7X/
│       ├── beta008-fixed/
│       ├── beta008-free/
│       ├── beta5-fixed/
│       └── beta5-free/
├── README.md
└── .nojekyll
```

`Source-Code/` 收录由原 `Documents/` 迁移的可编辑文档，并将公开的 SIESTA-lyh 源码置于 `Source-Code/SIESTA-lyh/`。各算例目录保留已有输入、计算输出、图表、诊断记录、许可说明和文件校验清单。β 定义、数据来源、运行版本及停止原因见各算例文档。

## 本机预览

在仓库根目录运行：

```bash
python3 -m http.server 8765 --bind 127.0.0.1
```

打开 [本机手册](http://127.0.0.1:8765/Source-Code/) 或 [本机算例入口](http://127.0.0.1:8765/SIESTA-lyh-example/)。这些地址仅供运行该 HTTP 服务的机器使用；对外访问请使用上表中的网站链接。

## 维护

源码快照、通用技术文档和算例资料分别在对应目录维护。更新程序版本时核对源码快照与文档中的版本说明；已归档算例继续注明其实际使用的源码版本，迁移网页不改变其计算结果。源码改动清单面向当前版本按 item 维护，同一内容并入已有条目，独立内容新增条目。

GitHub Pages 从 `main` 分支根目录发布；`.nojekyll` 保留静态文件的原样发布。网页入口位于 `Source-Code/` 和 `SIESTA-lyh-example/` 各自目录内。网站浏览与文档展示不替代物理验证，达到设定迭代步数也不代表平衡已经收敛。
