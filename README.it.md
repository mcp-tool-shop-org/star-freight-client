<p align="center">
  <a href="README.ja.md">日本語</a> | <a href="README.zh.md">中文</a> | <a href="README.es.md">Español</a> | <a href="README.fr.md">Français</a> | <a href="README.hi.md">हिन्दी</a> | <a href="README.md">English</a> | <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Client grafico Godot 4.6 per il gioco di ruolo spaziale [Star Freight](https://github.com/mcp-tool-shop-org/star-freight). Visualizza l'equipaggio, le creature e i nemici utilizzando pacchetti di sprite pixel provenienti dalla pipeline di [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry).

Il motore Python è la fonte di verità. Questo client è una superficie di rendering: visualizza ciò che il motore gli comunica tramite JSON-RPC su stdio.

> Il pacchetto del motore Python rimane attualmente `portlight` per garantire la compatibilità.
> Il nome del prodotto rivolto all'utente è **Star Freight**.
> La migrazione dello spazio dei nomi, se desiderata, è una rifattorizzazione dedicata che verrà eseguita in seguito.

## Architettura

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

- **Ponte del motore**: JSON-RPC 2.0 su stdio. Godot avvia `starfreight rpc` come sottoprocesso.
- **Caricatore di pacchetti**: Legge il file manifest.json dai pacchetti di sprite importati. Crea le CanvasTextures (albedo + normal).
- **Nodo personaggio**: Wrapper Sprite2D con cambio di direzione a 8 direzioni e illuminazione della mappa normale.

## Prerequisiti

- [Godot 4.6.1](https://godotengine.org/download) (build standard, non .NET)
- Python 3.11+ con `star-freight` installato
- Windows 11 (piattaforma di sviluppo principale)

## Guida rapida

1. Apri questo progetto in Godot 4.6
2. Premi F5 per avviare: la scena dell'elenco dei personaggi carica 3 pacchetti di personaggi
3. Controlli:
- **A/D** o tasti freccia: ruota il personaggio selezionato
- **Tab**: passa da un personaggio all'altro
- **Spazio**: ruota tutti i personaggi
- **B**: connettiti al motore Python (è necessario che `starfreight` sia installato)
- **Esc**: esci

## Importazione di pacchetti di sprite

I pacchetti vengono inclusi nella cartella `assets/characters/`. Per importarli dalla foundry:

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## Metodi RPC

| Metodo | Parametri | Risultati |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | dizionario del membro dell'equipaggio |
| `get_campaign` | — | riepilogo della campagna |
| `shutdown` | — | `{status}` |

## Esportazione del contratto

I pacchetti di sprite seguono il contratto di esportazione della foundry (v1.0.0):

- 8 direzioni: fronte, fronte-sinistra, sinistra, retro-sinistra, retro, retro-destra, destra, fronte-destra
- 3 livelli: albedo, normal, profondità (tutti in formato PNG trasparente a 48x48 pixel)
- Punto di ancoraggio: centro-inferiore
- Manifest: `manifest.json` con checksum SHA-256 per ogni file

## Verifica

```bash
bash verify.sh
```

Controlla la struttura del progetto, i manifest dei pacchetti di risorse (JSON + versione dello schema), la validità del GDScript e i riferimenti alle scene.

## Sicurezza e affidabilità

Questo client funziona **solo localmente**:

- **Dati accessibili**: File PNG di sprite locali (solo lettura), manifest JSON (solo lettura), messaggi JSON-RPC al sottoprocesso Python locale
- **Dati NON accessibili**: Nessun servizio cloud, nessun account utente, nessuna connessione di rete in uscita
- **Nessuna telemetria** viene raccolta o inviata
- **Nessun segreto** viene letto, memorizzato o trasmesso
- **Sottoprocesso**: Avvia `starfreight rpc` come processo figlio locale tramite stdio.

Consulta [SECURITY.md](SECURITY.md) per la politica di sicurezza completa.

## Licenza

MIT

Creato da [MCP Tool Shop](https://mcp-tool-shop.github.io/)
