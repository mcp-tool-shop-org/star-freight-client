<p align="center">
  <a href="README.ja.md">日本語</a> | <a href="README.zh.md">中文</a> | <a href="README.md">English</a> | <a href="README.fr.md">Français</a> | <a href="README.hi.md">हिन्दी</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Cliente gráfico de Godot 4.6 para el RPG espacial de comerciantes [Star Freight](https://github.com/mcp-tool-shop-org/star-freight). Renderiza la tripulación, las criaturas y los enemigos utilizando paquetes de sprites de píxeles del pipeline [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry).

El motor de Python es la fuente de verdad. Este cliente es una superficie de renderizado; muestra lo que el motor le indica a través de JSON-RPC sobre stdio.

> El paquete del motor de Python permanece actualmente como `portlight` por motivos de compatibilidad.
> El nombre del producto que ve el usuario es **Star Freight**.
> La migración del espacio de nombres, si se desea, es una refactorización dedicada posterior.

## Arquitectura

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

- **Puente del motor**: JSON-RPC 2.0 sobre stdio. Godot ejecuta `starfreight rpc` como un subproceso.
- **Cargador de paquetes**: Lee el archivo manifest.json de los paquetes de sprites importados. Crea CanvasTextures (albedo + normal).
- **Nodo de personaje**: Wrapper de Sprite2D con cambio de dirección en 8 direcciones e iluminación de mapa normal.

## Requisitos previos

- [Godot 4.6.1](https://godotengine.org/download) (compilación estándar, no .NET)
- Python 3.11+ con `star-freight` instalado
- Windows 11 (plataforma de desarrollo principal)

## Inicio rápido

1. Abra este proyecto en Godot 4.6.
2. Presione F5 para ejecutar; la escena de la lista de personajes carga 3 paquetes de personajes.
3. Controles:
- **A/D** o teclas de flecha: rota al personaje seleccionado.
- **Tab**: cambia entre personajes.
- **Espacio**: rota a todos los personajes.
- **B**: se conecta al motor de Python (debe tener `starfreight` instalado).
- **Esc**: sale.

## Importación de paquetes de sprites

Los paquetes se incluyen en el directorio `assets/characters/`. Para importar desde el "foundry":

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## Métodos RPC

| Método | Parámetros | Retorna |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | Diccionario del miembro de la tripulación |
| `get_campaign` | — | Resumen de la campaña |
| `shutdown` | — | `{status}` |

## Exportación de contrato

Los paquetes de sprites siguen el contrato de exportación "frozen foundry" (v1.0.0):

- 8 direcciones: frontal, frontal_izquierda, izquierda, trasera_izquierda, trasera, trasera_derecha, derecha, frontal_derecha
- 3 capas: albedo, normal, profundidad (todos en formato PNG transparente de 48x48)
- Pivote: centro_inferior
- Manifest: `manifest.json` con sumas de comprobación SHA-256 para cada archivo.

## Verificar

```bash
bash verify.sh
```

Verifica la estructura del proyecto, los manifiestos de los paquetes de activos (JSON + versión del esquema), la validez de GDScript y las referencias de escena.

## Seguridad y confianza

Este cliente opera **únicamente de forma local**:

- **Datos accedidos**: Archivos PNG de sprites locales (solo lectura), manifiestos JSON (solo lectura), mensajes JSON-RPC al subproceso de Python local.
- **Datos NO accedidos**: No hay servicios en la nube, no hay cuentas de usuario, no hay salida de red.
- **No se recopila ni se envía telemetría**.
- **No se leen, almacenan ni transmiten secretos**.
- **Subproceso**: Ejecuta `starfreight rpc` como un proceso secundario local a través de stdio únicamente.

Consulte [SECURITY.md](SECURITY.md) para obtener la política de seguridad completa.

## Licencia

MIT

Creado por [MCP Tool Shop](https://mcp-tool-shop.github.io/)
