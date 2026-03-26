<p align="center">
  <a href="README.ja.md">日本語</a> | <a href="README.zh.md">中文</a> | <a href="README.es.md">Español</a> | <a href="README.fr.md">Français</a> | <a href="README.hi.md">हिन्दी</a> | <a href="README.it.md">Italiano</a> | <a href="README.md">English</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Cliente gráfico Godot 4.6 para o RPG espacial de mercadores [Star Freight](https://github.com/mcp-tool-shop-org/star-freight). Renderiza a tripulação, criaturas e inimigos usando pacotes de sprites em pixel da pipeline [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry).

O motor Python é a fonte de verdade. Este cliente é uma superfície de renderização — ele exibe o que o motor informa através de JSON-RPC sobre stdio.

> O pacote do motor Python permanece atualmente como `portlight` para manter a compatibilidade.
> O nome do produto voltado para o usuário é **Star Freight**.
> A migração do namespace, se desejada, é uma refatoração dedicada posterior.

## Arquitetura

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

- **Ponte do motor**: JSON-RPC 2.0 sobre stdio. O Godot executa `starfreight rpc` como um subprocesso.
- **Carregador de pacotes**: Lê o arquivo manifest.json dos pacotes de sprites importados. Cria CanvasTextures (albedo + normal).
- **Nó de personagem**: Wrapper Sprite2D com alternância de 8 direções e iluminação do mapa normal.

## Pré-requisitos

- [Godot 4.6.1](https://godotengine.org/download) (build padrão, não .NET)
- Python 3.11+ com o `star-freight` instalado
- Windows 11 (plataforma de desenvolvimento primária)

## Início Rápido

1. Abra este projeto no Godot 4.6
2. Pressione F5 para executar — a cena da lista de personagens carrega 3 pacotes de personagens
3. Controles:
- **A/D** ou teclas de seta: rotaciona o personagem selecionado
- **Tab**: alterna entre personagens
- **Espaço**: rotaciona todos os personagens
- **B**: conecta ao motor Python (é necessário ter o `starfreight` instalado)
- **Esc**: sai

## Importando Pacotes de Sprites

Os pacotes são incluídos em `assets/characters/`. Para importar da foundry:

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## Métodos RPC

| Método | Parâmetros | Retorna |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | Dicionário do membro da tripulação |
| `get_campaign` | — | Resumo da campanha |
| `shutdown` | — | `{status}` |

## Exportar contrato

Os pacotes de sprites seguem o contrato de exportação da foundry (v1.0.0):

- 8 direções: frente, frente_esquerda, esquerda, trás_esquerda, trás, trás_direita, direita, frente_direita
- 3 camadas: albedo, normal, profundidade (todos em PNG transparente de 48x48)
- Pivô: centro_inferior
- Manifest: `manifest.json` com checksums SHA-256 para cada arquivo

## Verificar

```bash
bash verify.sh
```

Verifica a estrutura do projeto, os manifests dos pacotes de assets (JSON + versão do esquema), a validade do GDScript e as referências de cena.

## Segurança e Confiança

Este cliente opera **localmente apenas**:

- **Dados acessados**: Arquivos PNG de sprites locais (somente leitura), manifests JSON (somente leitura), mensagens JSON-RPC para o subprocesso Python local.
- **Dados NÃO acessados**: Nenhum serviço em nuvem, nenhuma conta de usuário, nenhuma saída de rede.
- **Nenhuma telemetria** é coletada ou enviada.
- **Nenhum segredo** é lido, armazenado ou transmitido.
- **Subprocesso**: Executa `starfreight rpc` como um processo filho local através de stdio apenas.

Consulte [SECURITY.md](SECURITY.md) para a política de segurança completa.

## Licença

MIT

Desenvolvido por [MCP Tool Shop](https://mcp-tool-shop.github.io/)
