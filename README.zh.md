<p align="center">
  <a href="README.ja.md">日本語</a> | <a href="README.md">English</a> | <a href="README.es.md">Español</a> | <a href="README.fr.md">Français</a> | <a href="README.hi.md">हिन्दी</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Godot 4.6 版本的 [Star Freight](https://github.com/mcp-tool-shop-org/star-freight) 宇宙商人角色扮演游戏的图形客户端。它使用来自 [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry) 流水线的像素精灵包来渲染船员、生物和敌对角色。

Python 引擎是数据源。这个客户端是一个渲染界面，它通过 JSON-RPC 协议，通过标准输入/输出 (stdio) 接收引擎发送的数据并进行显示。

> 目前，Python 引擎的软件包仍然是 `portlight`，以便保持一致性。
> 面向用户的产品名称是 **Star Freight**。
> 如果需要，命名空间迁移将在以后的专门重构中进行。

## 架构

```
star-freight (Python)          star-freight-client (Godot 4.6)
┌──────────────────┐           ┌──────────────────────────┐
│ portlight.engine │──JSON-RPC─│ engine_bridge.gd         │
│ portlight.rpc    │  (stdio)  │ pack_loader.gd           │
│ portlight.content│           │ character_node.gd        │
└──────────────────┘           │ scenes/roster.tscn       │
                               │ assets/characters/       │
                               └──────────────────────────┘
```

- **引擎桥接器**: 使用 JSON-RPC 2.0 协议，通过标准输入/输出 (stdio) 进行通信。Godot 会启动 `starfreight rpc` 作为子进程。
- **精灵包加载器**: 从导入的精灵包中读取 `manifest.json` 文件。构建 CanvasTextures（包含漫反射和法线贴图）。
- **角色节点**: Sprite2D 包装器，具有 8 个方向的切换功能以及法线贴图的照明效果。

## 先决条件

- [Godot 4.6.1](https://godotengine.org/download) (标准构建，非 .NET 版本)
- Python 3.11+，并且已安装 `star-freight`
- Windows 11 (主要开发平台)

## 快速开始

1. 在 Godot 4.6 中打开此项目。
2. 按 F5 运行 — 角色列表场景会加载 3 个角色包。
3. 控制：
- **A/D** 或方向键：旋转选中的角色朝向。
- **Tab**：循环切换角色。
- **空格键**：旋转所有角色。
- **B**：连接到 Python 引擎（必须已安装 `starfreight`）。
- **Esc**：退出。

## 导入精灵包

精灵包被放置在 `assets/characters/` 目录下。要从 foundry 导入，请执行以下操作：

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## RPC 方法

| 方法 | 参数 | 返回值 |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | 船员成员字典 |
| `get_campaign` | — | 战役摘要 |
| `shutdown` | — | `{status}` |

## 导出合同

精灵包遵循 frozen foundry 的导出合同 (v1.0.0)：

- 8 个方向：正面、左前、左侧、左后、背面、右后、右侧、右前
- 3 层：漫反射、法线、深度（均为 48x48 的透明 PNG 图像）
- 锚点：中心底部
- 清单：包含每个文件的 SHA-256 校验和的 `manifest.json` 文件

## 验证

```bash
bash verify.sh
```

检查项目结构、资源包清单（JSON + schema 版本）、GDScript 的有效性以及场景引用。

## 安全与信任

此客户端仅在**本地**运行：

- **访问的数据**: 仅读取本地 PNG 精灵文件、JSON 清单文件，以及发送到本地 Python 子进程的 JSON-RPC 消息。
- **未访问的数据**: 不使用任何云服务、不涉及任何用户帐户、不进行任何网络数据传输。
- **不收集或发送任何遥测数据**。
- **不读取、存储或传输任何密钥**。
- **子进程**: 通过标准输入/输出 (stdio) 仅启动 `starfreight rpc` 作为本地子进程。

请参阅 [SECURITY.md](SECURITY.md) 以获取完整的安全策略。

## 许可证

MIT

由 [MCP Tool Shop](https://mcp-tool-shop.github.io/) 构建。
