# 产品包清单与文件结构

> xugu-exporter v1.1.0 成品包（`scripts/build-release.sh 1.1.0` 生成于 `dist/xugu-exporter-1.1.0/`）

## 产品包文件结构

```
xugu-exporter-1.1.0/
├── README.md                          # 项目总览与快速开始
├── bin/                               # 六平台二进制（纯 Go 静态编译，免依赖）
│   ├── xugu-exporter-linux-386        #   Linux x86 32位
│   ├── xugu-exporter-linux-amd64      #   Linux x86_64（最常用）
│   ├── xugu-exporter-linux-arm64      #   Linux ARM64（飞腾/鲲鹏等）
│   ├── xugu-exporter-windows-amd64.exe#   Windows x86_64
│   ├── xugu-exporter-darwin-amd64     #   macOS Intel
│   └── xugu-exporter-darwin-arm64     #   macOS Apple Silicon
├── configs/
│   ├── xugu-exporter.yml              # 运行配置模板（DSN/开关/性能三层控制，注释即文档）
│   └── metrics-default.yml            # 内置指标定义副本（外置覆盖的起点，44 采集域）
├── dashboards/
│   └── xugu-overview.json             # Grafana 仪表盘（9 分区 65 面板，导入即用）
├── rules/
│   └── xugu-alerts.yml                # Prometheus 告警规则（25 条，中文说明）
├── scripts/
│   └── diagnose-stuck-sql.sh          # 卡死 SQL 一键诊断（读取执行中语句的 OS 线程号并 pstack）
├── deploy/
│   ├── docker-compose.yml             # 一键演示栈（exporter+Prometheus+Grafana+node-exporter）
│   ├── Dockerfile
│   ├── prometheus.yml                 # Prometheus 配置模板（含 server 资源 job）
│   ├── grafana/provisioning/          # Grafana 自动装配（数据源+仪表盘）
│   └── systemd/xugu-exporter.service  # Linux 生产部署单元模板
└── docs/
    ├── deployment-guide.md            # 部署说明手册
    ├── 产品手册.md                     # 产品手册（功能规格/使用说明/告警规格）
    ├── metrics-reference.md           # 指标清单与 SQL 对照（自动生成）
    ├── metrics-design.md              # 指标设计说明与版本迁移对照
    ├── test-report.md                 # 测试报告
    ├── field-validation-matrix.md     # 系统字典字段有效性参考
    ├── xugudb-reference-notes.md      # XuguDB 系统字典与运行行为参考
    ├── package-manifest.md            # 本清单
    └── screenshots/                   # 功能图示（产品手册引用，7 张）
```

## 仓库中额外的开发资产（不随包分发）

```
cmd/ internal/            Go 源码（主程序/采集引擎/主机指标/配置）
tools/verify              验证工具（101 用例自动化，含 8 场景编排）
tools/gen_dashboard.py    面板生成器（改面板的唯一入口，含指标引用自检）
tools/check_dashboard_queries.py  面板 PromQL 逐条连 Prometheus 验证
tools/gen_metrics_reference.py    指标参考手册生成器
tools/probe|xsql|loadgen|lockgen  探查/SQL/负载/锁场景工具
scripts/build-release.sh  多平台构建+打包脚本
always-sql/               常用运维 SQL 库 + 验证分类报告
docs/screenshots/         功能截图
docs/schema/              系统虚表结构探查存档
```

## 版本与校验

- 版本注入：二进制 `--version` 输出构建版本（-ldflags -X main.version）。
- 完整性：发布时建议附 `sha256sum bin/*` 清单。
- 升级说明见 deployment-guide.md §5；指标变更历史见 metrics-design.md §4。
