<p align="center">
  <a href="README.ja.md">日本語</a> | <a href="README.zh.md">中文</a> | <a href="README.es.md">Español</a> | <a href="README.md">English</a> | <a href="README.hi.md">हिन्दी</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Client graphique Godot 4.6 pour le RPG spatial de commerce [Star Freight](https://github.com/mcp-tool-shop-org/star-freight). Il affiche les personnages, les créatures et les ennemis en utilisant des ensembles de sprites pixel provenant de la chaîne de traitement [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry).

Le moteur Python est la source de vérité. Ce client est une surface de rendu : il affiche ce que le moteur lui indique via JSON-RPC sur stdio.

> Le paquet du moteur Python reste actuellement `portlight` pour assurer la continuité.
> Le nom du produit visible par l'utilisateur est **Star Freight**.
> La migration des espaces de noms, si souhaitée, sera une refactorisation ultérieure et dédiée.

## Architecture

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

- **Pont vers le moteur**: JSON-RPC 2.0 via stdio. Godot lance `starfreight rpc` en tant que processus enfant.
- **Chargeur de packs**: Lit le fichier manifest.json des ensembles de sprites importés. Crée des CanvasTextures (albédo + normal).
- **Nœud de personnage**: Wrapper Sprite2D avec changement de direction (8 directions) et éclairage de la carte normale.

## Prérequis

- [Godot 4.6.1](https://godotengine.org/download) (version standard, pas .NET)
- Python 3.11+ avec `star-freight` installé
- Windows 11 (plateforme de développement principale)

## Démarrage rapide

1. Ouvrez ce projet dans Godot 4.6.
2. Appuyez sur F5 pour lancer : la scène de présentation charge 3 ensembles de personnages.
3. Contrôles :
- **A/D** ou touches fléchées : faire pivoter le personnage sélectionné.
- **Tab**: parcourir les personnages.
- **Espace**: faire pivoter tous les personnages.
- **B**: se connecter au moteur Python (il faut que `starfreight` soit installé).
- **Échap**: quitter.

## Importation des ensembles de sprites

Les ensembles sont intégrés dans le dossier `assets/characters/`. Pour importer depuis la fonderie :

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## Méthodes RPC

| Méthode | Paramètres | Retour |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | Dictionnaire du membre d'équipage |
| `get_campaign` | — | Résumé de la campagne |
| `shutdown` | — | `{status}` |

## Exportation du contrat

Les ensembles de sprites suivent le contrat d'exportation de la fonderie (v1.0.0) :

- 8 directions : avant, avant_gauche, gauche, arrière_gauche, arrière, arrière_droite, droite, avant_droite
- 3 couches : albédo, normal, profondeur (tous en PNG transparent de 48x48)
- Point de pivot : centre_bas
- Manifeste : `manifest.json` avec les sommes de contrôle SHA-256 pour chaque fichier.

## Vérification

```bash
bash verify.sh
```

Vérifie la structure du projet, les manifestes des ensembles de sprites (JSON + version du schéma), la validité du GDScript et les références de scène.

## Sécurité et confiance

Ce client fonctionne **uniquement localement** :

- **Données consultées**: Fichiers PNG de sprites locaux (lecture seule), manifestes JSON (lecture seule), messages JSON-RPC vers le processus Python local.
- **Données NON consultées**: Pas de services cloud, pas de comptes utilisateurs, pas de trafic réseau sortant.
- **Aucune télémétrie** n'est collectée ou envoyée.
- **Aucun secret** n'est lu, stocké ou transmis.
- **Processus enfant**: Lance `starfreight rpc` en tant que processus enfant local via stdio uniquement.

Consultez [SECURITY.md](SECURITY.md) pour la politique de sécurité complète.

## Licence

MIT

Développé par [MCP Tool Shop](https://mcp-tool-shop.github.io/)
