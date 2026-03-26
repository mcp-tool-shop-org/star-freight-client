<p align="center">
  <a href="README.md">English</a> | <a href="README.zh.md">中文</a> | <a href="README.es.md">Español</a> | <a href="README.fr.md">Français</a> | <a href="README.hi.md">हिन्दी</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Godot 4.6を使用した、[Star Freight](https://github.com/mcp-tool-shop-org/star-freight)という宇宙商人RPGのグラフィカルクライアント。キャラクター、クリーチャー、敵キャラクターを、[Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry)のパイプラインから提供されるピクセルスプライトパックを使用してレンダリングします。

Pythonエンジンが真実の源です。このクライアントはレンダリングエンジンであり、エンジンからJSON-RPCを介してstdioで受信した情報を表示します。

> Pythonエンジンのパッケージは、現状では`portlight`として維持されています。
> ユーザー向けの製品名は**Star Freight**です。
> 名前空間の変更は、必要に応じて、後で別のリファクタリングで行います。

## アーキテクチャ

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

- **エンジンブリッジ**: JSON-RPC 2.0をstdio経由で使用します。Godotは`starfreight rpc`をサブプロセスとして起動します。
- **パックローダー**: インポートされたスプライトパックから`manifest.json`を読み込みます。CanvasTextures（アルベド + ノルマル）を生成します。
- **キャラクターノード**: Sprite2Dのラッパーで、8方向への向き変更と、ノーマルマップによるライティングをサポートします。

## 前提条件

- [Godot 4.6.1](https://godotengine.org/download) (標準ビルド、.NET非対応)
- `star-freight`がインストールされたPython 3.11以降
- Windows 11 (主要な開発プラットフォーム)

## クイックスタート

1. Godot 4.6でこのプロジェクトを開きます。
2. F5キーを押して実行します。ロスターシーンがロードされ、3つのキャラクターパックが表示されます。
3. 操作方法:
- **A/D**キーまたは矢印キー: 選択したキャラクターの向きを回転させます。
- **Tab**キー: キャラクターを切り替えます。
- **Space**キー: すべてのキャラクターを回転させます。
- **B**キー: Pythonエンジンに接続します (事前に`starfreight`をインストールする必要があります)。
- **Esc**キー: 終了します。

## スプライトパックのインポート

スプライトパックは`assets/characters/`ディレクトリに格納されています。 Foundryからインポートするには:

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## RPCメソッド

| メソッド | パラメータ | 戻り値 |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | クルーメンバーの辞書 |
| `get_campaign` | — | キャンペーンの概要 |
| `shutdown` | — | `{status}` |

## エクスポート契約

スプライトパックは、frozen foundryのエクスポート契約（v1.0.0）に準拠しています。

- 8方向: 正面、左正面、左、左背面、背面、右背面、右、右正面
- 3レイヤー: アルベド、ノーマル、深度 (すべて48x48の透過PNG)
- ピボット: センターボトム
- マニフェスト: `manifest.json`に、各ファイルに対するSHA-256チェックサムが含まれています。

## 検証

```bash
bash verify.sh
```

プロジェクトの構造、アセットパックのマニフェスト（JSON + スキーマバージョン）、GDScriptの有効性、シーン参照を確認します。

## セキュリティと信頼性

このクライアントは**ローカルでのみ動作します**:

- **アクセスするデータ**: ローカルのPNGスプライトファイル（読み取り専用）、JSONマニフェスト（読み取り専用）、ローカルのPythonサブプロセスへのJSON-RPCメッセージ
- **アクセスしないデータ**: クラウドサービス、ユーザーアカウント、ネットワークへの送信
- **テレメトリは収集または送信されません**。
- **機密情報は読み込まれたり、保存されたり、送信されたりしません**。
- **サブプロセス**: `starfreight rpc`を、stdio経由でローカルの子プロセスとして起動します。

詳細については、[SECURITY.md](SECURITY.md)を参照してください。

## ライセンス

MIT

[MCP Tool Shop](https://mcp-tool-shop.github.io/)によって作成されました。
